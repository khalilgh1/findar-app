from django.apps import AppConfig
import firebase_admin
from firebase_admin import credentials
import os
from django.conf import settings

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'

    def ready(self):
        if not firebase_admin._apps:
            cred = credentials.Certificate(
                os.path.join(
                    settings.BASE_DIR,
                    "serviceAccountKey.json"
                )
            )
            firebase_admin.initialize_app(cred)