from django.apps import AppConfig
import firebase_admin
from firebase_admin import credentials
import os
import json
from django.conf import settings
from decouple import config

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'

    def ready(self):
        if not firebase_admin._apps:
            # Load service account key from environment variable
            cred = credentials.Certificate(
                settings.FIREBASE_SERVICE_ACCOUNT
            )
            firebase_admin.initialize_app(cred)