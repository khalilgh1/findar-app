from firebase_admin import messaging , credentials
from firebase_admin.messaging import UnregisteredError
from django.core.mail import EmailMessage
import firebase_admin
import os



def send_topic_notification(topic: str, title: str, body: str, data=None):
    from config import settings
        
    if not firebase_admin._apps:
        cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT)
        firebase_admin.initialize_app(cred)

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        topic=topic,
    )

    response = messaging.send(message)
    return response

def send_user_notification(token: str, title: str, body: str, data=None):
    from config import settings

    if not firebase_admin._apps:
        cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT)
        firebase_admin.initialize_app(cred)

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
    )

    response = None
    try:
        response = messaging.send(message)
    except UnregisteredError:
        from api.models import DeviceToken
        DeviceToken.objects.filter(token=token).delete()
    return response

def new_agency_boosting_plans_notification():
    title = "New Boosting Plans Available!"
    body = "Check out our latest boosting plans to enhance your posts' visibility."
    data = {"type": "new_boosting_plans"}

    response = send_topic_notification("agency", title, body, data)
    return response

def new_individual_boosting_plans_notification():
    title = "New Boosting Plans Available!"
    body = "Check out our latest boosting plans to enhance your posts' visibility."
    data = {"type": "new_boosting_plans"}

    response = send_topic_notification("individual", title, body, data)
    return response

def reminder_boosting_expiry_notification(user_token: str, post_id: int):
    title = "Boosting Plan Expiry Reminder"
    body = "Your post's boosting plan is about to expire. Renew now to maintain visibility!"
    data = {"type": "boosting_expiry_reminder", "post_id": str(post_id)}

    response = send_user_notification(user_token, title, body, data)
    return response

def send_email(to, subject, body):
    email = EmailMessage(
        subject=subject,
        body=body,
        to=[to],
    )
    email.send(fail_silently=False)

def send_reset_code_email(email, code):
    subject = "Your FinDAR password reset code"
    body = f"""
Hi,

Your FinDAR password reset code is:

{code}

This code will expire in 10 minutes.
If you did not request this, ignore this email.

— FinDAR Team
"""
    send_email(email, subject, body)

def send_register_otp_email(email, code):
    subject = "Your FinDAR registration OTP code"
    body = f"""
Hi,

Your FinDAR registration OTP code is:

{code}

This code will expire in 10 minutes.
If you did not request this, ignore this email.

— FinDAR Team
"""
    send_email(email, subject, body)