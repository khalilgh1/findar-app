from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Boosting, CustomUser

def check_almost_expired_boostings():
    from .models import Post
    from .services import reminder_boosting_expiry_notification
    from django.utils import timezone
    from datetime import timedelta

    now = timezone.now()
    reminder_threshold = now + timedelta(days=1)

    almost_expired_posts = Boosting.objects.filter(
        expires_at__lte=reminder_threshold,
        expires_at__gt=now,
        notified = False
    )

    almost_expired_posts.update(notified=True)

    for post in almost_expired_posts:
        user = post.owner
        device_tokens = user.devicetoken_set.all()
        for token_obj in device_tokens:
            reminder_boosting_expiry_notification(token_obj.token, post.id)

def engagement_reminder():
    from .models import CustomUser ,DeviceToken
    from .services import send_user_notification
    from django.utils import timezone
    from datetime import timedelta

    now = timezone.now()
    engagement_threshold = now - timedelta(days=1)

    users_to_remind = CustomUser.objects.filter(
        last_active__lte=engagement_threshold
    )

    for user in users_to_remind:
        device_tokens = DeviceToken.objects.filter(user=user)
        for device_token in device_tokens:
            try:
                send_user_notification(
                    device_token.token,
                    "We miss you at FinDAR!",
                    "It's been a while since your last engagement. Check out new listings today!"
                )
            except DeviceToken.DoesNotExist:
                continue

