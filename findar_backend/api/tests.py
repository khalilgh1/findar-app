from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth.hashers import make_password
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from .models import (
    Boosting, BoostingPlan, CustomUser, DeviceToken, PasswordResetOTP, Post, Report,
)


def make_user(email="owner@example.com", username="owner_user", **extra):
    return CustomUser.objects.create_user(
        email=email, username=username, password="Passw0rdX",
        phone="0555000000", account_type="individual", **extra,
    )


def make_post(owner, **extra):
    data = dict(
        owner=owner, title="Nice flat", price=1000, description="desc",
        address="Algiers", latitude=36.75, longitude=3.06,
        listing_type="rent", building_type="apartment",
    )
    data.update(extra)
    return Post.objects.create(**data)


class AuthedTestCase(TestCase):
    def setUp(self):
        self.owner = make_user()
        self.other = make_user(email="other@example.com", username="other_user")
        self.client = APIClient()
        self.client.force_authenticate(self.owner)
        self.other_client = APIClient()
        self.other_client.force_authenticate(self.other)


class ListingWriteTests(AuthedTestCase):
    def test_create_ignores_client_owner_and_boosted(self):
        res = self.client.post("/api/create-listing/", {
            "title": "t", "price": 5, "description": "d",
            "listing_type": "sale", "building_type": "house",
            "owner": self.other.id, "boosted": True,
        }, format="json")
        self.assertEqual(res.status_code, 201, res.data)
        post = Post.objects.get(id=res.data["id"])
        self.assertEqual(post.owner, self.owner)
        self.assertFalse(post.boosted)

    def test_edit_cannot_boost_or_reassign(self):
        post = make_post(self.owner)
        res = self.client.put(f"/api/edit-listing/{post.id}",
                              {"boosted": True, "owner": self.other.id, "title": "new"},
                              format="json")
        self.assertEqual(res.status_code, 200, res.data)
        post.refresh_from_db()
        self.assertEqual(post.title, "new")
        self.assertFalse(post.boosted)
        self.assertEqual(post.owner, self.owner)

    def test_edit_by_non_owner_is_403(self):
        post = make_post(self.owner)
        res = self.other_client.put(f"/api/edit-listing/{post.id}", {"title": "x"}, format="json")
        self.assertEqual(res.status_code, 403)

    def test_delete_listing(self):
        post = make_post(self.owner)
        self.assertEqual(self.other_client.delete(f"/api/edit-listing/{post.id}").status_code, 403)
        self.assertEqual(self.client.delete(f"/api/edit-listing/{post.id}").status_code, 200)
        self.assertFalse(Post.objects.filter(id=post.id).exists())

    def test_created_at_does_not_change_on_update(self):
        post = make_post(self.owner)
        created = post.created_at
        self.client.post(f"/api/toggle_active_listing/{post.id}")
        post.refresh_from_db()
        self.assertFalse(post.active)
        self.assertEqual(post.created_at, created)


class ListingReadTests(AuthedTestCase):
    def test_inactive_listing_details_only_for_owner(self):
        post = make_post(self.owner, active=False)
        self.assertEqual(self.client.get(f"/api/listing-details/{post.id}").status_code, 200)
        self.assertEqual(self.other_client.get(f"/api/listing-details/{post.id}").status_code, 404)

    def test_advanced_search_same_point_and_distance_sort(self):
        near = make_post(self.owner, title="near")
        make_post(self.owner, title="far", latitude=36.80, longitude=3.10)
        make_post(self.owner, title="out of radius", latitude=35.0, longitude=0.6)
        res = self.client.get("/api/advanced-search/", {
            "latitude": near.latitude, "longitude": near.longitude, "sort_by": "distance",
        })
        self.assertEqual(res.status_code, 200, res.data)
        self.assertEqual([p["title"] for p in res.data], ["near", "far"])

    def test_advanced_search_bad_number_is_400(self):
        res = self.client.get("/api/advanced-search/", {"min_price": "abc"})
        self.assertEqual(res.status_code, 400)


class ReportTests(AuthedTestCase):
    def test_report_creates_row(self):
        post = make_post(self.owner)
        res = self.other_client.post("/api/report-property/",
                                     {"property_id": post.id, "issue_description": "scam"},
                                     format="json")
        self.assertEqual(res.status_code, 201, res.data)
        report = Report.objects.get()
        self.assertEqual(report.reporter_user, self.other)
        self.assertEqual(report.reported_user, self.owner)
        self.assertEqual(report.description, "scam")

    def test_report_missing_fields_is_400(self):
        res = self.other_client.post("/api/report-property/", {"property_id": 1}, format="json")
        self.assertEqual(res.status_code, 400)


class ProfileTests(AuthedTestCase):
    def test_update_username_sent_as_username(self):
        res = self.client.put("/api/users/profile/", {"username": "renamed_user"}, format="json")
        self.assertEqual(res.status_code, 200, res.data)
        self.owner.refresh_from_db()
        self.assertEqual(self.owner.username, "renamed_user")

    def test_resubmitting_own_username_is_allowed(self):
        res = self.client.put("/api/users/profile/",
                              {"username": self.owner.username, "phone": "0555111111"},
                              format="json")
        self.assertEqual(res.status_code, 200, res.data)

    def test_taken_username_is_rejected(self):
        res = self.client.put("/api/users/profile/", {"username": self.other.username}, format="json")
        self.assertEqual(res.status_code, 400)


class AuthTests(TestCase):
    def test_login_error_is_json_object(self):
        make_user()
        res = APIClient().post("/api/auth/login",
                               {"email": "owner@example.com", "password": "wrong"}, format="json")
        self.assertEqual(res.status_code, 400)
        self.assertIn("message", res.data)

    def test_logout_succeeds_and_removes_device_token(self):
        user = make_user()
        DeviceToken.objects.create(user=user, token="tok")
        client = APIClient()
        client.force_authenticate(user)
        res = client.post("/api/auth/logout", {"device_token": "tok", "refresh": "garbage"}, format="json")
        self.assertEqual(res.status_code, 200)
        self.assertFalse(DeviceToken.objects.filter(token="tok").exists())

    @patch("api.views.firebase_auth.verify_id_token")
    def test_oauth_user_has_unusable_password(self, verify):
        verify.return_value = {"email": "g@example.com", "name": "Google User"}
        res = APIClient().post("/api/auth/oauth/", {"id_token": "x", "provider": "google"}, format="json")
        self.assertEqual(res.status_code, 200, res.data)
        user = CustomUser.objects.get(email="g@example.com")
        self.assertFalse(user.has_usable_password())
        res = APIClient().post("/api/auth/login",
                               {"email": "g@example.com", "password": "oauth_user"}, format="json")
        self.assertEqual(res.status_code, 400)


class PasswordResetTests(TestCase):
    def setUp(self):
        self.user = make_user()

    @patch("api.views.send_reset_code_email")
    def test_new_request_invalidates_old_codes(self, _send):
        old = PasswordResetOTP.objects.create(user=self.user, code_hash=make_password("111111"))
        APIClient().post("/api/auth/password-reset/request/", {"email": self.user.email}, format="json")
        old.refresh_from_db()
        self.assertTrue(old.used)

    def test_confirm_enforces_attempt_limit(self):
        PasswordResetOTP.objects.create(user=self.user, code_hash=make_password("123456"), attempts=5)
        res = APIClient().post("/api/auth/password-reset/confirm/", {
            "email": self.user.email, "code": "123456", "new_password": "NewPassw0rd",
        }, format="json")
        self.assertEqual(res.status_code, 400)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("Passw0rdX"))


class CronTests(TestCase):
    @patch("api.models.new_individual_boosting_plans_notification")
    @patch("api.cron.reminder_boosting_expiry_notification")
    def test_expiry_reminder_reaches_owner_devices(self, remind, _plan_notif):
        from .cron import check_almost_expired_boostings

        owner = make_user()
        DeviceToken.objects.create(user=owner, token="device-1")
        post = make_post(owner, boosted=True)
        plan = BoostingPlan.objects.create(plan_type="basic", target_audience="individuals", duration=7)
        boosting = Boosting.objects.create(boost_plan=plan, post=post,
                                           expires_at=timezone.now() + timedelta(hours=5))

        check_almost_expired_boostings()

        remind.assert_called_once_with("device-1", post.id)
        boosting.refresh_from_db()
        self.assertTrue(boosting.notified)

    @patch("api.models.new_individual_boosting_plans_notification")
    def test_expired_boost_is_removed(self, _plan_notif):
        from .cron import expire_boostings

        owner = make_user()
        expired = make_post(owner, boosted=True, title="expired")
        manual = make_post(owner, boosted=True, title="no boosting rows")
        plan = BoostingPlan.objects.create(plan_type="basic", target_audience="individuals", duration=7)
        Boosting.objects.create(boost_plan=plan, post=expired,
                                expires_at=timezone.now() - timedelta(days=1))

        expire_boostings()

        expired.refresh_from_db()
        manual.refresh_from_db()
        self.assertFalse(expired.boosted)
        self.assertTrue(manual.boosted)

    @patch("api.models.new_agency_boosting_plans_notification", side_effect=RuntimeError("fcm down"))
    def test_plan_saves_even_if_push_fails(self, _notif):
        BoostingPlan.objects.create(plan_type="gold", target_audience="agencies", duration=30)
        self.assertEqual(BoostingPlan.objects.count(), 1)
