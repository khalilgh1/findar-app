# Findar — CLAUDE.md

Real-estate marketplace (Algeria-focused): sellers/agencies post listings (house, apartment, villa, studio, office) for rent or sale; buyers browse, filter, save, and contact owners. Listings can be "boosted" (sponsored) via paid plans.

## Repo layout

| Path | What | Stack |
|---|---|---|
| `findar_app/` | Mobile app (main product) | Flutter 3.47 / Dart 3.13, flutter_bloc (Cubits), get_it, sqflite |
| `findar_backend/` | REST API, deployed at `https://findar-app.onrender.com` | Django 5.2, DRF, SimpleJWT, PostgreSQL, firebase_admin (FCM) |
| `findar_website/` | Marketing landing page (vercel) | Next.js 16, React 19, Tailwind 4 |
| `docs/` | Project docs for Claude sessions — read before big changes | — |
| `main.py`, `pyproject.toml`, `temp_app/` | uv scaffold leftovers, not part of the product | — |

Deep dives: [docs/architecture.md](docs/architecture.md) (layers, data flow, API map) · [docs/testing.md](docs/testing.md) (test layers, e2e setup) · [docs/roadmap.md](docs/roadmap.md) (the 4-step improvement plan, status, known-issue backlog).

## Commands

```bash
# Flutter app (run from findar_app/)
flutter pub get
flutter analyze                      # after step 2 (2026-10-30): 0 errors, 0 warnings, 177 infos
flutter test                         # 61 unit/cubit/widget tests (test/)
flutter test integration_test -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000   # needs seeded local backend, see docs/testing.md
flutter gen-l10n                     # regenerate lib/l10n/app_localizations*.dart from .arb files
dart run build_runner build --delete-conflicting-outputs   # regenerate *.g.dart (json_serializable)
flutter run -d emulator-5554         # see the run-findar skill for emulator boot + gotchas
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # point app at a local backend

# Backend (run from findar_backend/; deps in requirements.txt — file is UTF-16 encoded)
python manage.py runserver
python manage.py test api            # 37 tests; always SQLite (never the .env Postgres)
$env:SQLITE_PATH='e2e.sqlite3'; python manage.py seed_e2e   # local e2e data; SQLITE_PATH forces SQLite
```

Backend reads a `.env` (gitignored): `DEBUG`, `SECRET_KEY`, `ALLOWED_HOSTS`, `PGDATABASE/PGUSER/PGPASSWORD/PGHOST/PGSSLMODE/PGCHANNELBINDING`, `EMAIL`, `APP_PASSWORD`, `FIREBASE_SERVICE_ACCOUNT_JSON` (JSON string), `CHARGILY_API_KEY`, `CHARGILY_SECRET_KEY`. All optional locally: without `PGDATABASE` it uses SQLite; without the Firebase JSON, OAuth and push are disabled.

App needs `findar_app/.env` (gitignored, bundled as an asset) with `TOMTOM_API_KEY`.

## App architecture (short)

- Entry: `lib/main.dart` → `SetupRepositories()` (get_it, `core/di/service_locator.dart`) → dotenv → `AuthManager().init()` (tokens in flutter_secure_storage) → Firebase + FCM → `MainApp` with ~15 global `BlocProvider`s and named routes in `onGenerateRoute`.
- Layers: `features/<feature>/screens|widgets` (UI) → `logic/cubits/*` (state) → `core/repositories/*` → `core/services/*` (HTTP, Cloudinary, TomTom, Firebase).
- `ListingRepository` (abstract) is implemented by `CompositeListingRepository` = local sqflite cache (`LocalListingRepository`, rows keyed by server id) + `RemoteListingRepository` (`parseListing` maps API payloads). Offline-first: cubits pass an `onUpdate` callback that fires with cached data, then remote data.
- HTTP goes through `FindarApiService` (auto JWT refresh on 401). Endpoints are centralized in `core/config/api_config.dart`.
- Images upload directly from the app to Cloudinary (unsigned preset); backend stores URLs only.
- i18n: en / ar / fr via `.arb` in `lib/l10n/`. RTL must work for Arabic.
- Theme: `core/theme/` (light/dark, `ThemeProvider` via provider package).

## Conventions

- New UI strings go in all three `.arb` files, then `flutter gen-l10n`. Never hardcode user-facing text.
- New endpoints: add to `ApiConfig`, call via `FindarApiService`, expose through a repository, consume from a Cubit. Screens never call services directly.
- Backend views are function-based DRF views with `@permission_classes([IsAuthenticated])`; URLs in `api/urls.py` mostly have no trailing slash — match exactly in `ApiConfig`.
- Don't edit generated files: `lib/l10n/app_localizations*.dart`, `*.g.dart`, `firebase_options.dart`, platform `generated_plugin*` files.
- Code style: match surrounding code. The codebase uses `print` for logging today; prefer `debugPrint`/`log` in new code.

## Gotchas

- Android build: SDK at `C:\Android`. firebase_core/auth compile against SDK 34; if `Cannot query the value of this provider` appears, `platforms/android-34/android.jar` is missing. Java and Kotlin JVM targets must both be 17. Details in the `run-findar` skill.
- Emulator `wamid_pixel` sometimes sticks "offline" — kill qemu and cold-boot (`-no-snapshot-load`).
- Session: `AuthRepository` (get_it singleton) owns login/logout; `AuthManager.onSessionExpired` sends the user to login; `resetUserSession()` (`logic/session_reset.dart`) clears user-scoped global cubits.
- Local backend runs: set `SQLITE_PATH`, never blank `PGDATABASE` — in PowerShell `$env:X=''` deletes the var and `.env` (hosted Postgres) wins.
- Two `.gitignore` levels; `findar_app/.env` and `findar_backend/.env` must never be committed.

## Token-efficient navigation (use these before reading files)

- **graphify**: knowledge graph of all code in `graphify-out/` (gitignored, local). Start with `graphify-out/GRAPH_REPORT.md`, or `graphify query "<question>"`, `graphify explain "<Symbol>"`, `graphify affected "<Symbol>"`, `graphify path "A" "B"`. After significant code changes run `graphify update .` (local AST, no LLM) to refresh. Ignore rules: `.graphifyignore`.
- **Dart MCP server** (from the `dart-flutter` plugin): analyzer, run tests, hot reload, widget tree inspection, runtime errors, pub.dev search — prefer it over shelling out when available.
- **mobile-mcp** (`.mcp.json`): drive the running Android emulator (tap, type, screenshot, accessibility tree) for e2e checks.
- Skills: `run-findar` (launch app on emulator), `apple-design` (HIG-based UI review/redesign — use for step 4), plugin `flutter-*`/`dart-*` skills (widget/integration tests, architecture, l10n, static analysis).
