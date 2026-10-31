"""End-to-end API flows, driven the way the Flutter app drives them.

Unlike tests.py (which mostly uses force_authenticate), these go through the
real login/register endpoints and send `Authorization: Bearer <access>`,
using the exact paths in findar_app/lib/core/config/api_config.dart.
"""
from unittest.mock import patch

from django.test import TestCase
from rest_framework.test import APIClient

from .models import BoostingPlan, CustomUser, DeviceToken, PasswordResetOTP, Post, Report, SavedPosts

# Keys the app reads in RemoteListingRepository.parseListing / PropertyListing.
POST_KEYS = {
    "id", "owner", "owner_details", "title", "price", "description", "address",
    "created_at", "active", "boosted", "main_pic", "pics", "latitude",
    "longitude", "bedrooms", "bathrooms", "livingrooms", "area",
    "listing_type", "building_type",
}
OWNER_KEYS = {"id", "username", "email", "phone", "profile_pic", "account_type"}
# User.fromJson in auth_repository.dart.
USER_KEYS = {"id", "username", "email", "phone", "profile_pic", "account_type"}

PASSWORD = "Passw0rdX"


def register(username, email, account_type="individual"):
    """POST /api/auth/register like RegisterScreen; returns (client, payload)."""
    res = APIClient().post("/api/auth/register", {
        "username": username, "email": email, "phone": "0555123456",
        "password": PASSWORD, "account_type": account_type,
    }, format="json")
    assert res.status_code == 200, res.data
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {res.data['data']['access']}")
    return client, res.data["data"]


def listing_body(**extra):
    """Body built by RemoteListingRepository.createListing."""
    body = {
        "title": "Bright flat in Hydra", "description": "Two bedrooms, sea view",
        "price": 45000.0, "bedrooms": 2, "bathrooms": 1,
        "listing_type": "rent", "building_type": "apartment", "active": True,
        "main_pic": "https://res.cloudinary.com/demo/main.jpg",
        "pics": ["https://res.cloudinary.com/demo/1.jpg"],
        "address": "Hydra, Algiers", "latitude": 36.75, "longitude": 3.06,
        "area": 85.5,
    }
    body.update(extra)
    return body


class AuthFlowTests(TestCase):
    def test_register_login_refresh_me_logout(self):
        client, data = register("flow_user", "flow@example.com", account_type="Agency")
        self.assertTrue(USER_KEYS <= set(data["user"]), data["user"])
        self.assertEqual(data["user"]["account_type"], "agency")

        # Login (LoginScreen → AuthRepository.login)
        res = APIClient().post("/api/auth/login",
                               {"email": "flow@example.com", "password": PASSWORD}, format="json")
        self.assertEqual(res.status_code, 200)
        self.assertTrue(res.data["success"])
        tokens = res.data["data"]
        self.assertTrue({"access", "refresh", "user"} <= set(tokens))
        self.assertEqual(tokens["user"]["id"], data["user"]["id"])
        self.assertNotIn("password", tokens["user"])

        # Refresh (AuthService.refreshToken): rotating refresh tokens.
        res = APIClient().post("/api/auth/refresh", {"refresh": tokens["refresh"]}, format="json")
        self.assertEqual(res.status_code, 200, res.data)
        self.assertIn("access", res.data)
        self.assertIn("refresh", res.data)

        # Bad refresh token → 401 (the app ends the session on 400/401).
        res = APIClient().post("/api/auth/refresh", {"refresh": "garbage"}, format="json")
        self.assertIn(res.status_code, (400, 401))

        authed = APIClient()
        authed.credentials(HTTP_AUTHORIZATION=f"Bearer {res.data.get('access', tokens['access'])}")
        self.assertEqual(authed.post("/api/auth/me").data["email"], "flow@example.com")

        # Device registration (NotificationService) then logout removes it.
        self.assertEqual(authed.post("/api/notifications/register-device/",
                                     {"token": "fcm-1"}, format="json").status_code, 201)
        self.assertEqual(authed.post("/api/notifications/register-device/",
                                     {"token": "fcm-1"}, format="json").status_code, 200)
        res = authed.post("/api/auth/logout",
                          {"device_token": "fcm-1", "refresh": tokens["refresh"]}, format="json")
        self.assertEqual(res.status_code, 200)
        self.assertFalse(DeviceToken.objects.filter(token="fcm-1").exists())

    def test_device_token_moves_to_the_new_account(self):
        a, _ = register("first_user", "a@example.com")
        b, _ = register("second_user", "b@example.com")
        a.post("/api/notifications/register-device/", {"token": "shared"}, format="json")
        b.post("/api/notifications/register-device/", {"token": "shared"}, format="json")
        self.assertEqual(DeviceToken.objects.get(token="shared").user.email, "b@example.com")

    def test_register_validation_errors_are_field_keyed(self):
        register("taken_name", "taken@example.com")
        res = APIClient().post("/api/auth/register", {
            "username": "ab", "email": "taken@example.com", "phone": "12",
            "password": "short", "account_type": "individual",
        }, format="json")
        self.assertEqual(res.status_code, 400)
        # FindarApiService._extractErrorMessage flattens {field: [msg]}.
        self.assertTrue({"username", "email", "phone", "password"} <= set(res.data), res.data)

    def test_unauthenticated_requests_get_401(self):
        for path in ("/api/recent-listings/", "/api/my_listings/", "/api/saved-listings/",
                     "/api/users/profile/"):
            self.assertEqual(APIClient().get(path).status_code, 401, path)
        bad = APIClient()
        bad.credentials(HTTP_AUTHORIZATION="Bearer not-a-jwt")
        self.assertEqual(bad.get("/api/recent-listings/").status_code, 401)

    @patch("api.views.send_reset_code_email")
    def test_password_reset_flow(self, send):
        register("reset_user", "reset@example.com")
        res = APIClient().post("/api/auth/password-reset/request/",
                               {"email": "reset@example.com"}, format="json")
        self.assertEqual(res.status_code, 200)
        code = send.call_args[0][1]

        verify = APIClient().post("/api/auth/password-reset/verify/",
                                  {"email": "reset@example.com", "code": "000000" if code != "000000" else "111111"},
                                  format="json")
        self.assertEqual(verify.status_code, 400)
        verify = APIClient().post("/api/auth/password-reset/verify/",
                                  {"email": "reset@example.com", "code": code}, format="json")
        self.assertEqual(verify.status_code, 200)

        weak = APIClient().post("/api/auth/password-reset/confirm/", {
            "email": "reset@example.com", "code": code, "new_password": "weak",
        }, format="json")
        self.assertEqual(weak.status_code, 400)

        done = APIClient().post("/api/auth/password-reset/confirm/", {
            "email": "reset@example.com", "code": code, "new_password": "NewPassw0rd",
        }, format="json")
        self.assertEqual(done.status_code, 200)

        # Code is single-use; new password works, old one doesn't.
        again = APIClient().post("/api/auth/password-reset/confirm/", {
            "email": "reset@example.com", "code": code, "new_password": "OtherPassw0rd",
        }, format="json")
        self.assertEqual(again.status_code, 400)
        login = lambda pw: APIClient().post("/api/auth/login",
                                            {"email": "reset@example.com", "password": pw},
                                            format="json").status_code
        self.assertEqual(login("NewPassw0rd"), 200)
        self.assertEqual(login(PASSWORD), 400)
        self.assertFalse(PasswordResetOTP.objects.filter(used=False).exists())


class ListingLifecycleTests(TestCase):
    """Seller posts, buyer finds/saves/reports, seller edits/toggles/boosts/deletes."""

    def setUp(self):
        self.seller, seller_data = register("seller_one", "seller@example.com", "agency")
        self.buyer, _ = register("buyer_one", "buyer@example.com")
        self.seller_id = seller_data["user"]["id"]
        self.assertEqual(self.seller_id, CustomUser.objects.get(email="seller@example.com").id)

    def create(self, **extra):
        res = self.seller.post("/api/create-listing/", listing_body(**extra), format="json")
        self.assertEqual(res.status_code, 201, res.data)
        return res.data

    def test_full_lifecycle(self):
        created = self.create()
        pid = created["id"]
        self.assertEqual(set(created), POST_KEYS)
        self.assertEqual(set(created["owner_details"]), OWNER_KEYS)
        self.assertEqual(created["owner_details"]["account_type"], "agency")

        # Home feed (RecentCubit) + rent tab filter.
        recent = self.buyer.get("/api/recent-listings/").data
        self.assertEqual([p["id"] for p in recent], [pid])
        self.assertEqual(self.buyer.get("/api/recent-listings/", {"listing_type": "sale"}).data, [])
        self.assertEqual(len(self.buyer.get("/api/recent-listings/", {"q": "hydra"}).data), 1)

        # Search with the params the filter screen sends.
        res = self.buyer.get("/api/advanced-search/", {
            "latitude": "36.75", "longitude": "3.06", "min_price": "1000.0",
            "max_price": "50000.0", "listing_type": "rent", "building_type": "apartment",
            "num_bedrooms": "2", "num_bathrooms": "1", "min_sqft": "50.0",
            "max_sqft": "100.0", "listed_by": "agency", "sort_by": "price_asc",
        })
        self.assertEqual(res.status_code, 200, res.data)
        self.assertEqual([p["id"] for p in res.data], [pid])
        self.assertEqual(self.buyer.get("/api/advanced-search/", {"listed_by": "individual"}).data, [])

        # Details, save, saved list, unsave.
        details = self.buyer.get(f"/api/listing-details/{pid}")
        self.assertEqual(details.status_code, 200)
        self.assertEqual(details.data["owner_details"]["phone"], "0555123456")
        self.assertEqual(self.buyer.get(f"/api/save_listing/{pid}").status_code, 200)
        self.assertEqual(self.buyer.get(f"/api/save_listing/{pid}").data["message"],
                         "Listing already saved")
        self.assertEqual(self.seller.get(f"/api/save_listing/{pid}").status_code, 400)
        self.assertEqual([p["id"] for p in self.buyer.get("/api/saved-listings/").data], [pid])

        # Report (ReportBottomSheet).
        res = self.buyer.post("/api/report-property/",
                              {"property_id": pid, "issue_description": "Fake photos"}, format="json")
        self.assertEqual(res.status_code, 201)
        self.assertEqual(Report.objects.get().post_id, pid)

        # Seller: my listings, edit (EditListingScreen body), toggle offline.
        mine = self.seller.get("/api/my_listings/").data
        self.assertEqual([p["id"] for p in mine["active"]], [pid])
        res = self.seller.put(f"/api/edit-listing/{pid}", {
            "title": "Renovated flat", "price": 50000.0, "address": "Hydra",
            "bedrooms": 3, "bathrooms": 2, "listing_type": "sale",
            "building_type": "apartment", "active": True,
            "main_pic": created["main_pic"], "pics": created["pics"] + ["https://x/2.jpg"],
        }, format="json")
        self.assertEqual(res.status_code, 200, res.data)
        self.assertEqual(res.data["title"], "Renovated flat")
        self.assertEqual(len(res.data["pics"]), 2)
        self.assertEqual(self.buyer.put(f"/api/edit-listing/{pid}", {"title": "x"},
                                        format="json").status_code, 403)

        res = self.seller.post(f"/api/toggle_active_listing/{pid}", {}, format="json")
        self.assertEqual(res.data["active"], False)
        self.assertEqual(self.buyer.get("/api/recent-listings/").data, [])
        self.assertEqual(self.buyer.get("/api/saved-listings/").data, [],
                         "inactive listings drop out of saved lists")
        self.assertEqual(self.buyer.get(f"/api/listing-details/{pid}").status_code, 404)
        mine = self.seller.get("/api/my_listings/").data
        self.assertEqual(([p["id"] for p in mine["active"]], [p["id"] for p in mine["inactive"]]),
                         ([], [pid]))
        self.seller.post(f"/api/toggle_active_listing/{pid}", {}, format="json")

        # Boost (PaymentConfirmationScreen) → sponsored carousel.
        self.assertEqual(self.seller.post(f"/api/boost-listing/{pid}", {}, format="json").status_code, 400)
        self.assertEqual(self.buyer.post(f"/api/boost-listing/{pid}", {
            "card_number": "4242424242424242", "card_holder": "B", "expiry_date": "12/30", "cvv": "123",
        }, format="json").status_code, 403)
        res = self.seller.post(f"/api/boost-listing/{pid}", {
            "card_number": "4242424242424242", "card_holder": "Seller", "expiry_date": "12/30",
            "cvv": "123",
        }, format="json")
        self.assertEqual(res.status_code, 200)
        self.assertEqual([p["id"] for p in self.buyer.get("/api/sponsored-listings/").data], [pid])

        # Unsave, then delete.
        self.assertEqual(self.buyer.delete(f"/api/save_listing/{pid}").status_code, 200)
        self.assertEqual(self.buyer.delete(f"/api/save_listing/{pid}").status_code, 404)
        self.assertEqual(self.seller.delete(f"/api/edit-listing/{pid}").status_code, 200)
        self.assertEqual(self.buyer.get(f"/api/listing-details/{pid}").status_code, 404)
        self.assertFalse(SavedPosts.objects.exists())

    def test_create_validation(self):
        res = self.seller.post("/api/create-listing/",
                               listing_body(building_type="condo"), format="json")
        self.assertEqual(res.status_code, 400)
        self.assertIn("building_type", res.data)
        res = self.seller.post("/api/create-listing/", {"title": "only a title"}, format="json")
        self.assertEqual(res.status_code, 400)
        self.assertTrue({"price", "description"} <= set(res.data))

    def test_create_offline_listing_is_hidden(self):
        pid = self.create(active=False)["id"]
        self.assertEqual(self.buyer.get("/api/recent-listings/").data, [])
        self.assertEqual(self.buyer.get(f"/api/get-listing/{pid}").status_code, 404)
        self.assertEqual([p["id"] for p in self.seller.get("/api/my_listings/").data["inactive"]], [pid])

    def test_all_building_types_from_the_app_are_accepted(self):
        # create_listing.dart / filtering.dart building types.
        for bt in ("house", "apartment", "villa", "studio", "office"):
            self.create(building_type=bt, title=bt)
            res = self.buyer.get("/api/advanced-search/", {"building_type": bt.title()})
            self.assertEqual([p["title"] for p in res.data], [bt])

    def test_search_sorting(self):
        self.create(title="cheap", price=1000, area=40)
        self.create(title="pricey", price=9000, area=120)
        titles = lambda sort: [p["title"] for p in
                               self.buyer.get("/api/advanced-search/", {"sort_by": sort}).data]
        self.assertEqual(titles("price_asc"), ["cheap", "pricey"])
        self.assertEqual(titles("price_desc"), ["pricey", "cheap"])
        self.assertEqual(titles("area_desc"), ["pricey", "cheap"])
        self.assertEqual(titles("date_newest"), ["pricey", "cheap"])
        self.assertEqual(titles("date_oldest"), ["cheap", "pricey"])
        # distance without a location falls back to newest first instead of 500.
        self.assertEqual(titles("distance"), ["pricey", "cheap"])

    def test_missing_ids_are_404(self):
        for method, path in (("get", "/api/listing-details/999"), ("get", "/api/get-listing/999"),
                             ("get", "/api/save_listing/999"), ("put", "/api/edit-listing/999"),
                             ("post", "/api/toggle_active_listing/999"),
                             ("post", "/api/boost-listing/999"), ("get", "/api/users/999/profile/")):
            res = getattr(self.buyer, method)(path, {}, format="json")
            self.assertEqual(res.status_code, 404, path)
        res = self.buyer.post("/api/report-property/",
                              {"property_id": 999, "issue_description": "x"}, format="json")
        self.assertEqual(res.status_code, 404)


class ProfileFlowTests(TestCase):
    def setUp(self):
        self.client_a, _ = register("profile_user", "p@example.com")
        self.client_b, _ = register("viewer_user", "v@example.com")
        self.client_a.post("/api/create-listing/", listing_body(), format="json")
        self.client_a.post("/api/create-listing/", listing_body(title="hidden", active=False),
                           format="json")

    def test_own_profile_shape(self):
        res = self.client_a.get("/api/users/profile/")
        self.assertEqual(res.status_code, 200)
        self.assertTrue(res.data["success"])
        data = res.data["data"]
        self.assertTrue({"id", "credits", *USER_KEYS} <= set(data), data)
        self.assertNotIn("password", data)
        self.assertEqual([p["title"] for p in data["listings"]], ["Bright flat in Hydra"])

    def test_edit_profile_and_picture(self):
        res = self.client_a.put("/api/users/profile/", {
            "username": "profile_user", "phone": "0555999999", "email": "p@example.com",
            "profile_pic": "https://res.cloudinary.com/demo/me.jpg",
        }, format="json")
        self.assertEqual(res.status_code, 200, res.data)
        self.assertEqual(res.data["data"]["phone"], "0555999999")
        self.assertEqual(res.data["data"]["profile_pic"], "https://res.cloudinary.com/demo/me.jpg")

        res = self.client_a.put("/api/users/profile/", {"email": "new@example.com"}, format="json")
        self.assertEqual(res.status_code, 400)
        res = self.client_a.put("/api/users/profile/", {"phone": "abc"}, format="json")
        self.assertEqual(res.status_code, 400)

    def test_public_profile_hides_private_fields_and_inactive_listings(self):
        uid = CustomUser.objects.get(email="p@example.com").id
        res = self.client_b.get(f"/api/users/{uid}/profile/")
        self.assertEqual(res.status_code, 200)
        self.assertNotIn("password", res.data["user"])
        self.assertEqual([p["title"] for p in res.data["listings"]], ["Bright flat in Hydra"])


class HealthTests(TestCase):
    def test_health_check_is_public(self):
        self.assertEqual(APIClient().get("/api/health-check").status_code, 200)

    @patch("api.models.new_individual_boosting_plans_notification")
    def test_boost_plan_creation_notifies_once(self, notif):
        plan = BoostingPlan.objects.create(plan_type="basic", target_audience="individuals", duration=7)
        plan.duration = 14
        plan.save()
        notif.assert_called_once()
