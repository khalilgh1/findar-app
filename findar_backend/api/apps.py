from django.apps import AppConfig
import firebase_admin
from firebase_admin import credentials
from django.conf import settings


class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'

    def ready(self):
        # Without a service account (local dev, tests) Firebase stays
        # uninitialised; OAuth and push calls then fail gracefully.
        if not firebase_admin._apps and settings.FIREBASE_SERVICE_ACCOUNT:
            cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT)
            firebase_admin.initialize_app(cred)
