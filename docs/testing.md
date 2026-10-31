# Testing Findar

Three layers. Run the first two before every commit; run the device suite before a release or after touching auth, listings or navigation.

| Layer | Where | Runs on | Command |
|---|---|---|---|
| Backend API | `findar_backend/api/tests.py` (regressions), `api/test_flows.py` (app-shaped journeys + response contracts) | SQLite, in-process | `python manage.py test api` |
| App unit / cubit | `findar_app/test/` | Dart VM (no device) | `flutter test` |
| App on device | `findar_app/integration_test/` | Android emulator + local backend | see below |

## Backend

```bash
cd findar_backend
python manage.py test api
```

`manage.py test` always uses SQLite, even if `.env` points at the hosted Postgres (set `FINDAR_TEST_POSTGRES=1` to opt in). `test_flows.py` uses real JWTs from `auth/login`/`auth/register` and the exact paths in `ApiConfig`; its `POST_KEYS` / `USER_KEYS` sets are the contract the app's parsers rely on (`test/helpers/fixtures.dart` mirrors them on the app side).

## App unit tests

```bash
cd findar_app
flutter test
```

- `test/core/` — `parseListing` against a real backend payload, `FindarApiService` (token refresh, single-flight refresh, error flattening) via `package:http/testing.dart`, `CompositeListingRepository` (offline-first rules) with mocktail, `LocalListingRepository` on real SQLite (`sqflite_common_ffi`), `AuthRepository` session handling.
- `test/logic/` — cubits with `bloc_test` against a mocked `ListingRepository`.
- `FindarApiService` / `AuthService` take an optional `http.Client` for this; the app uses the default.

## On the emulator

**Never point this at production**: the flows create, save and edit data. `SQLITE_PATH` forces SQLite regardless of `.env` (in PowerShell, `$env:PGDATABASE=''` *deletes* the variable, so `.env`'s Postgres would win — don't rely on it).

```powershell
# 1. Local backend with fixture data (re-seed before every run)
cd findar_backend
$env:SQLITE_PATH='e2e.sqlite3'
python manage.py migrate
python manage.py seed_e2e          # refuses to run on a non-SQLite database
python manage.py runserver 0.0.0.0:8000

# 2. Emulator (see the run-findar skill), then
cd findar_app
flutter test integration_test -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Fixture accounts (password `Passw0rdX`), from `api/management/commands/seed_e2e.py` / `integration_test/e2e_config.dart`:

| Email | Username | Type | Notes |
|---|---|---|---|
| buyer@findar.test | e2e_buyer | individual | nothing saved |
| seller@findar.test | e2e_seller | agency | owns the 6 seeded listings (2 boosted) |
| fresh@findar.test | e2e_fresh | individual | spare account |

`integration_test/app_flow_test.dart` drives: welcome → login → home (sponsored + recent) → search bar → Search Results → details (real owner, no fake data) → save → Saved tab → unsave → logout → seller login → My Listings → make offline → Offline tab → make online → saved state not inherited → logout. Re-seed before each run.

Flows that need system UI (image picker, Google sign-in, `tel:`/`sms:` intents, notification permission) aren't automatable with `integration_test`; they were checked by driving the emulator with mobile-mcp — see "Step 3 results" in [roadmap.md](roadmap.md).
