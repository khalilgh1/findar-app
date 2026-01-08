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
            service_account_json = config('SERVICEACCOUNTKEY')
            service_account_dict = json.loads(service_account_json)
            cred = credentials.Certificate(service_account_dict)
            firebase_admin.initialize_app(cred)