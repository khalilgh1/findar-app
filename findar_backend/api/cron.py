from datetime import timedelta

from django.utils import timezone

from .models import Boosting, CustomUser, DeviceToken
from .services import reminder_boosting_expiry_notification, send_user_notification


def check_almost_expired_boostings():
    now = timezone.now()
    reminder_threshold = now + timedelta(days=1)

    # Materialise before flagging: updating `notified` first would make the
    # lazy queryset (filtered on notified=False) come back empty.
    almost_expired = list(
        Boosting.objects.select_related('post__owner').filter(
            expires_at__lte=reminder_threshold,
            expires_at__gt=now,
            notified=False,
        )
    )
    Boosting.objects.filter(id__in=[b.id for b in almost_expired]).update(notified=True)

    for boosting in almost_expired:
        for device in DeviceToken.objects.filter(user=boosting.post.owner):
            try:
                reminder_boosting_expiry_notification(device.token, boosting.post_id)
            except Exception as e:
                print(f"Boost expiry reminder failed for token {device.id}: {e}")


def expire_boostings():
    """Un-boost posts whose last boosting has expired."""
    now = timezone.now()
    from .models import Post

    expired_posts = Post.objects.filter(boosted=True).exclude(
        boosting__expires_at__gt=now
    ).filter(boosting__isnull=False)
    expired_posts.update(boosted=False)


def engagement_reminder():
    engagement_threshold = timezone.now() - timedelta(days=1)

    users_to_remind = CustomUser.objects.filter(last_active__lte=engagement_threshold)

    for device in DeviceToken.objects.filter(user__in=users_to_remind):
        try:
            send_user_notification(
                device.token,
                "We miss you at FinDAR!",
                "It's been a while since your last engagement. Check out new listings today!"
            )
        except Exception as e:
            print(f"Engagement reminder failed for token {device.id}: {e}")


def subscription_renewal():
    """Daily job referenced by CRONJOBS: remind owners and expire old boosts."""
    check_almost_expired_boostings()
    expire_boostings()
