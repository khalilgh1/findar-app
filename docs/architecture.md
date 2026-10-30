# Findar architecture

Snapshot as of 2026-10-30 (start of the improvement plan). Update this file when structure changes.

## System overview

```
Flutter app ──HTTPS/JWT──▶ Django REST API (Render) ──▶ PostgreSQL
    │                            │
    ├─▶ Cloudinary (direct unsigned image upload; URLs sent to API)
    ├─▶ TomTom (location autocomplete / geocoding, key from app .env)
    ├─▶ Firebase Auth + Google Sign-In (OAuth → POST /api/auth/oauth/)
    └◀─ Firebase Cloud Messaging ◀── backend firebase_admin (topic + per-device pushes, cron reminders)
```

## Flutter app (`findar_app/lib`)

```
main.dart                 bootstrap, global BlocProviders, named routes (onGenerateRoute)
core/
  config/api_config.dart  base URL (--dart-define API_BASE_URL) + every endpoint path
  di/service_locator.dart get_it registrations
  services/               FindarApiService (HTTP + JWT refresh), AuthService, AuthManager (secure-storage tokens),
                          CloudinaryService, TomTomService, FirebaseOAuthService, NotificationService (FCM + local notifs)
  repositories/           ListingRepository (abstract) → CompositeListingRepository(Local sqflite, Remote API)
                          AuthRepository, LocalUserStore
  models/                 PropertyListing (json_serializable), SponsorshipPlan, ReturnResult
  theme/                  light/dark ThemeData, ThemeProvider (provider pkg)
  widgets/                shared widgets (PropertyCard, buttons, shimmer, bottom bar, sort/filter …)
data/dbhelper.dart        sqflite schema: listings cache table + users table
features/<area>/          screens + widgets per feature (auth, home, search, property_details, create_listing,
                          listings (my listings, edit, sponsorship plans, payment), saved, profile, settings, landing/splash)
logic/cubits/             one Cubit per concern (see table)
l10n/                     app_en/ar/fr.arb → generated app_localizations*.dart
```

### Cubits → consumers

| Cubit | Used by |
|---|---|
| AuthCubit | login, register, profile picture setup, edit profile, profile avatar |
| RecentCubit / SponsoredCubit (`home/`) | home, categories, sponsored carousel |
| SearchCubit + SortCubit | filtering, search results |
| PropertyDetailsCubit | property details, PropertyCard (save toggle), home, saved, my listings |
| ListingsCubit / MyListingsCubit | create/edit listing, my listings, profile |
| CreateListingCubit | registered globally but **no screen uses it** |
| SavedListingsCubit | saved listings |
| ProfileCubit | profile, edit profile, other user's profile |
| ProfilePictureSetupCubit | post-register picture step |
| BoostCubit | payment confirmation (boost purchase) |
| LanguageCubit / SettingsCubit | settings (locale, prefs) |

### Data flow (offline-first listings)

1. Cubit calls `ListingRepository.getX(onUpdate: emitLoaded)`.
2. Composite repo reads sqflite cache → `onUpdate(local)` if non-empty.
3. If `InternetConnection.hasInternetAccess`, fetch remote → re-cache (recent listings only) → `onUpdate(remote)`.
4. Writes (create/edit/delete/toggle/save) require connectivity, else `NetworkException`.

### Navigation

Named routes only (`Navigator.pushNamed`), args passed via `settings.arguments` for `/edit-listing`, `/sponsorship-plans`, `/payment-confirmation`, `/user-profile`, `/property-details`. Initial route `/landing` (splash) decides login vs home. Bottom bar (`core/layout/bottom_bar.dart`) uses `pushNamedAndRemoveUntil` between `/home`, `/saved-listings`, `/my-listings`, `/profile`.

## Django backend (`findar_backend`)

- `config/settings.py` — env via python-decouple, PostgreSQL, JWT (30 min access / 30 day refresh, rotating), Gmail SMTP for password-reset OTP, django-crontab jobs (`api.cron.engagement_reminder` 10:00, `subscription_renewal` 20:00).
- `api/models.py` — `CustomUser` (email login, phone, profile_pic URL, account_type individual|agency, credits), `Post` (listing; main_pic + pics JSON, lat/lng, rooms, area, listing_type rent|sale, building_type, active, boosted), `SavedPosts`, `Report`, `BoostingPlan`, `Boosting` (expires_at), `PasswordResetOTP`, `DeviceToken`.
- `api/views.py` — function-based DRF views; `api/serializers.py`; `api/services.py` (FCM + email helpers); `api/auth_backend.py` (email auth backend).
- Seed/utility scripts at root: `seed_listings.py`, `seed_test_data.py`, `create_test_users.py`, `create_boost_plans.py`, `test_chargily.py`.
- `api testing/` — Bruno request collection for manual API testing.

### API map (all under `/api/`)

| Path | Method | Notes |
|---|---|---|
| `health-check` | GET | public |
| `auth/login`, `login/` | POST | email + password → JWT pair |
| `auth/register`, `register/` | POST | |
| `auth/oauth/` | POST | Firebase ID token → JWT pair |
| `auth/logout` | POST | app calls `auth/logout/` (trailing slash mismatch) |
| `auth/me` | POST | |
| `auth/token/`, `auth/refresh` | POST | SimpleJWT obtain / custom refresh |
| `auth/password-reset/{request,verify,confirm}/` | POST | email OTP flow |
| `notifications/register-device/` | POST | FCM token |
| `create-listing/` | POST | |
| `get-listing/<id>`, `listing-details/<id>` | GET | |
| `edit-listing/<id>` | PUT | app's `deleteListing` also calls this path with DELETE → 405 |
| `my_listings/` | GET | active + inactive |
| `toggle_active_listing/<id>` | POST | |
| `boost-listing/<id>` | POST | spends credits for a plan |
| `save_listing/<id>` | GET (save) / DELETE (unsave) | |
| `saved-listings/` | GET | |
| `sponsored-listings/`, `recent-listings/` | GET | |
| `advanced-search/` | GET | query params: price, type, rooms, area, lat/lng, sort |
| `users/profile[/]` | GET/PUT (APIView) | own profile |
| `users/<id>/profile/` | GET | public profile |
| `report-property/` | POST | not called by the app |
| — | — | app references `notifications/list/`, which does not exist |
