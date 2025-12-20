"""
Simple script to test sending notifications to your device
Just run: python test_notification.py
"""

import firebase_admin
from firebase_admin import credentials, messaging

# Initialize Firebase
cred = credentials.Certificate('firebase-service-account.json')
firebase_admin.initialize_app(cred)

# Your FCM token from the app (copy from the console output)
YOUR_FCM_TOKEN = "dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA"

# Create the notification
message = messaging.Message(
    notification=messaging.Notification(
        title='🚀 Boost Expiring Soon!',
        body='Your apartment listing boost will expire in 24 hours. Renew now!',
    ),
    data={
        'listing_id': '123',
        'listing_title': 'Modern Apartment',
        'type': 'boost_expiry',
        'action': 'open_listing'
    },
    token=YOUR_FCM_TOKEN
)

# Send it
try:
    response = messaging.send(message)
    print(f"✅ Notification sent successfully!")
    print(f"Response: {response}")
except Exception as e:
    print(f"❌ Error: {e}")
