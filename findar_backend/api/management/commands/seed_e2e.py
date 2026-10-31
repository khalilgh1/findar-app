"""Deterministic data for the app's end-to-end tests.

    SQLITE_PATH=e2e.sqlite3 PGDATABASE= python manage.py migrate
    SQLITE_PATH=e2e.sqlite3 PGDATABASE= python manage.py seed_e2e
    SQLITE_PATH=e2e.sqlite3 PGDATABASE= python manage.py runserver 0.0.0.0:8000

Accounts (password for all: Passw0rdX), mirrored in
findar_app/integration_test/e2e_config.dart:
    buyer@findar.test   e2e_buyer   individual
    seller@findar.test  e2e_seller  agency      owns every seeded listing
    fresh@findar.test   e2e_fresh   individual  no listings, nothing saved
"""
from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from api.models import CustomUser, DeviceToken, Post, Report, SavedPosts

PASSWORD = "Passw0rdX"

USERS = [
    ("buyer@findar.test", "e2e_buyer", "individual", "0555100100"),
    ("seller@findar.test", "e2e_seller", "agency", "0555200200"),
    ("fresh@findar.test", "e2e_fresh", "individual", "0555300300"),
]

# (title, price, listing_type, building_type, bedrooms, bathrooms, area, boosted, lat, lng, address)
LISTINGS = [
    ("E2E Villa Hydra", 52000000, "sale", "villa", 5, 3, 320.0, True, 36.7417, 3.0327, "Hydra, Algiers"),
    ("E2E Flat Bab Ezzouar", 65000, "rent", "apartment", 3, 1, 90.0, True, 36.7213, 3.1832, "Bab Ezzouar, Algiers"),
    ("E2E Studio Oran", 30000, "rent", "studio", 1, 1, 35.0, False, 35.6971, -0.6308, "Oran"),
    ("E2E House Blida", 18000000, "sale", "house", 4, 2, 210.0, False, 36.4700, 2.8277, "Blida"),
    ("E2E Office Didouche", 120000, "rent", "office", 0, 2, 140.0, False, 36.7650, 3.0500, "Didouche Mourad, Algiers"),
    ("E2E Flat Kouba", 45000, "rent", "apartment", 2, 1, 70.0, False, 36.7300, 3.0800, "Kouba, Algiers"),
]


class Command(BaseCommand):
    help = "Reset a local SQLite database to the e2e fixture set."

    def handle(self, *args, **options):
        engine = settings.DATABASES["default"]["ENGINE"]
        if "sqlite" not in engine:
            raise CommandError(f"Refusing to wipe a non-SQLite database ({engine}).")

        for model in (Report, SavedPosts, DeviceToken, Post):
            model.objects.all().delete()
        CustomUser.objects.filter(email__endswith="@findar.test").delete()

        users = {}
        for email, username, account_type, phone in USERS:
            users[username] = CustomUser.objects.create_user(
                email=email, username=username, password=PASSWORD,
                phone=phone, account_type=account_type,
            )

        seller = users["e2e_seller"]
        for i, (title, price, lt, bt, beds, baths, area, boosted, lat, lng, addr) in enumerate(LISTINGS):
            Post.objects.create(
                owner=seller, title=title, price=price, listing_type=lt, building_type=bt,
                bedrooms=beds, bathrooms=baths, livingrooms=1, area=area, boosted=boosted,
                latitude=lat, longitude=lng, address=addr,
                description=f"{title}: seeded for end-to-end tests.",
                main_pic=f"https://picsum.photos/seed/findar{i}/800/600",
                pics=[f"https://picsum.photos/seed/findar{i}b/800/600"],
            )

        self.stdout.write(self.style.SUCCESS(
            f"Seeded {len(USERS)} users and {len(LISTINGS)} listings (password {PASSWORD})."
        ))
