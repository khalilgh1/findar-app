# Findar improvement roadmap

The owner wants this done in discrete steps, **stopping for review after each step**. Update the status column and the backlog as work lands.

| Step | Scope | Status |
|---|---|---|
| 1 | Analyze project; write CLAUDE.md + docs; install skills/MCPs/tools (graphify, apple-design, Flutter plugin, mobile-mcp) | done 2026-10-30 |
| 2 | Investigate code + run analysis/tests; find and fix all issues (app + backend) | not started |
| 3 | E2E + real-device tests so every flow works (integration_test, mobile-mcp driving the emulator, backend API tests) | not started |
| 4 | Redesign screens/components, app icon, splash with Claude Design; implement it; add motion/animations (use `apple-design` skill for HIG review) | not started |
| 5 | Owner tests manually, reports remaining issues | — |

## Issue backlog (seeded during step 1 — verify before fixing)

### Bugs / API mismatches
- `logout` calls `/api/auth/logout/` but backend route is `auth/logout` (no slash) → POST 404 (APPEND_SLASH can't redirect POSTs).
- `RemoteListingRepository.deleteListing` sends DELETE to `edit-listing/<id>`, which only allows PUT → 405. No delete endpoint on backend.
- `ApiConfig.notificationsListEndpoint` (`notifications/list/`) has no backend route.
- `report-property/` exists on backend but report bottom sheet may not call it — check.
- `CompositeListingRepository` caches listings via `createListing` on the local repo, which drops `id`, `additionalImages`, lat/lng, area, etc. → offline details may be wrong.
- `CreateListingCubit` is provided globally but unused.
- `main.dart` calls `SetupRepositories()` before `WidgetsFlutterBinding.ensureInitialized()`.

### Security
- Django `SECRET_KEY` hardcoded in settings; `ALLOWED_HOSTS = ["*"]`; no CORS/HTTPS settings for production.
- `findar_app/.env` is bundled as a Flutter asset → the TomTom key ships inside the APK (acceptable only if the key is domain/app-restricted).
- Payment screen validates card numbers client-side; confirm no real card data is handled/stored and that Chargily integration is server-side.
- `CustomUser.__str__` / `Post.__str__` print debug info on every call.

### Code health
- `flutter analyze`: 0 errors, 9 warnings, 242 infos (baseline).
- Unreferenced files: `RealMain.dart`, `core/constants/constants.dart`, `core/extensions/localization_extension.dart`, `core/repositories/{dummy_listing_repo,property_repository,search_repository,user_repository}.dart`, `core/services/implemented_network_service.dart`, `core/utils/l10n_helper.dart`, `core/widgets/{cached_image,label,loading_overlay,range_slider}.dart`, `features/profile/profile.dart`, `features/demoscreen.dart` (routed but demo).
- No Flutter tests; `api/tests.py` empty; `api/trashmaybe.py` dead.
- `print` logging everywhere, including `ApiConfig.enableApiLogging = true` in release.
- `pubspec.yaml`: description placeholder, unused-looking deps (`group_button`, `main_button`, `cloudinary_flutter`/`cloudinary_url_gen` vs. manual HTTP upload) — verify.
- `requirements.txt` is UTF-16; Pipfile also present — pick one.
- Android Gradle: AGP 8.11 / Gradle 8.14 / Kotlin 2.2.20 flagged by Flutter as soon-unsupported (template now uses AGP 9.1 / Gradle 9.3.1 / Kotlin 2.4). `applicationId` is still `com.example.findar`.
- Root `main.py`, `pyproject.toml`, `.python-version`, `temp_app/` are scaffolding leftovers.
