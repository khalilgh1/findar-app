# Findar improvement roadmap

The owner wants this done in discrete steps, **stopping for review after each step**. Update the status column and the backlog as work lands.

| Step | Scope | Status |
|---|---|---|
| 1 | Analyze project; write CLAUDE.md + docs; install skills/MCPs/tools (graphify, apple-design, Flutter plugin, mobile-mcp) | done 2026-10-30 |
| 2 | Investigate code + run analysis/tests; find and fix all issues (app + backend) | done 2026-10-30 (see below) |
| 3 | E2E + real-device tests so every flow works (integration_test, mobile-mcp driving the emulator, backend API tests) | done 2026-10-31 (see below; how to run: [testing.md](testing.md)) |
| 4 | Redesign screens/components, app icon, splash with Claude Design; implement it; add motion/animations (use `apple-design` skill for HIG review) | 4a design **approved 2026-11-01**: spec in [design/README.md](design/README.md), [canvas](https://claude.ai/artifact/NXLyPR63DLLKiY4ezRvt4D). 4b implementation not started; follow the plan in design/README.md §5 |
| 5 | Owner tests manually, reports remaining issues | — |

## Step 2 results (2026-10-30)

**Backend** (covered by `api/tests.py`, 21 tests):
- `report-property/` crashed (wrong `Report` field names).
- `owner` / `boosted` were client-writable via create/edit (free boosts, reassigning posts). Now read-only.
- OAuth-created users got the password `oauth_user` (anyone could log in with it). Now unusable password; only the Firebase-verified email is trusted.
- `auth/logout` always returned 400 and never removed the device token.
- Password-reset confirm skipped the 5-attempt limit; old codes stayed valid after a new request.
- Profile update ignored `username` (the app's key) and rejected re-sending your own name.
- `Post.created_at` was `auto_now` (reset on every edit/toggle). Migration `0002_alter_post_created_at`.
- Advanced search: 500 on non-numeric params and on `acos` rounding; added `sort_by=distance`.
- Inactive listings were visible to anyone via `listing-details`.
- Cron: `subscription_renewal` didn't exist; boost-expiry job used wrong relations and an empty queryset; expired boosts never removed.
- `BoostingPlan.save` failed when FCM failed and re-notified on every edit.
- No delete endpoint: `DELETE edit-listing/<id>` added.
- 401 → 403 for "not your listing" (the app treated 401 as an expired token).
- Settings: `SECRET_KEY` / `ALLOWED_HOSTS` from env (old key kept as fallback so tokens stay valid), secure proxy/cookie flags when `DEBUG=False`, SQLite fallback when `PGDATABASE` is unset, Firebase/Chargily keys optional.
- `requirements.txt` re-encoded to UTF-8; dead `config/firebase.py`, `api/trashmaybe.py` removed.

**App**:
- Remote listings always parsed as active + not boosted (`isOnline` vs `is_online`); one bad row emptied a whole list; null bedrooms/type crashed parsing.
- Offline cache dropped server ids, marked every cached listing as the current user's, seeded a fake "Debug Tester" user, never cached my/saved listings. Rewritten; DB v3 drops the corrupt cache.
- Logout threw (un-awaited FCM token passed to `jsonEncode`), re-registered the device instead of removing it, and left per-user caches/cubits (next account saw the previous user's data).
- Token refresh raced and could loop; a dead refresh token left the user stuck (now back to login with a message); network errors during refresh no longer log out.
- Google sign-in bypassed the user cache (profile showed the fake user) and left login on the back stack.
- `AuthCubit` / `ProfileCubit` held separate user copies → one `AuthRepository` in get_it. Viewing another user's profile overwrote your own profile state.
- Edit profile prefilled an empty name (wrong key), so saving always failed validation.
- Property details: bookmark and retry hard-coded to listing #1; fake fallback data ("Modern Family Home", "2,200 sqft"); report was a fake delay + mailto to a personal Gmail (now `report-property/`); call/message buttons did nothing (now `tel:` / `sms:`); not-found state.
- Search: rent/sale and listed-by filters never matched backend values; "Condo" isn't a backend type and "Office" was missing; save button could never unsave.
- Create listing dropped Floors/Rooms, hard-coded bathrooms = 1, ignored Online/Offline, never sent area → now Bedrooms / Bathrooms / Area (m²).
- Create/edit reacted to any `done` from the shared cubit; edit didn't send the address, dropped newly added photos, crashed on unknown building types; delete always reported success; My Listings retry was a no-op and a failed action replaced the list with an error page.
- `BoostCubit` crashed on API errors; FCM listeners registered twice (duplicate foreground notifications); `SetupRepositories()` before `ensureInitialized()`; 10 s timeout vs Render cold start (now 45 s); API bodies logged in release; `path_provider` undeclared.
- Removed 17 dead/duplicate files (RealMain, dummy/property/search/user repos, demo screen, unused widgets/utils, `CreateListingCubit`, `utils/firebase.dart`).

`flutter analyze`: 0 errors, 0 warnings, 177 infos (93 `avoid_print`, 67 deprecated APIs → step 4).
Smoke test: builds and launches on `emulator-5554`; login error path checked. Production API returned 503 that day, so signed-in flows were not run end to end (step 3, against a local backend).

## Step 3 results (2026-10-31)

Test suites (all green): backend `python manage.py test api` — 37 tests (21 regression + 16 flow/contract in `api/test_flows.py`); app `flutter test` — 61 unit/cubit/widget tests; `integration_test/app_flow_test.dart` on `emulator-5554` against a seeded local backend. See [testing.md](testing.md).

Bugs found by the new tests and fixed:
- **Login/register/OAuth responses had no user `id`** (`RegisterSerializer`), so the app stored every user as id 0: account switches never cleared the previous user's cache and offline "My listings" was always empty. Needs a backend redeploy.
- Server error on a fresh install (nothing cached) left the home feed and sponsored carousel spinning forever, and showed "no listings" on Saved / My Listings. The composite repo now rethrows when nothing is cached, so the screens show their error/retry state.
- **Search Results crashed** (`context.select` inside a list `itemBuilder`, introduced in step 2) — red screen in debug, grey box in release.
- Search filters defaulted to ≥2 bedrooms / ≥1 bathroom, silently hiding studios and offices. Now 0 = "Any" and nothing is sent.
- Tapping "Get Started" before the welcome animation finished threw (`AnimationController.forward()` after dispose).
- Profile avatar read AuthCubit's user (set only at login), so a picture chosen at registration never showed. Now reads ProfileCubit (refreshed from the server).
- Home feed didn't show a newly created listing until pull-to-refresh.
- "Get Started" was hard-coded English.
- Save/unsave failures on home cards (offline, saving your own listing) were only `print`ed, so the bookmark silently did nothing. Now a snackbar shows the reason (localized "You're offline…" when offline; `core/utils/save_feedback.dart`).
- `manage.py test` ran against the hosted Neon Postgres when `.env` was present (it created `test_neondb` there). Tests now always use SQLite; `SQLITE_PATH` forces SQLite for local servers.

Verified manually on the emulator (mobile-mcp + adb): register → profile picture (gallery picker + Cloudinary) → home; text search; advanced filters (rent + apartment); create listing with photo + TomTom location (all fields stored correctly); edit listing; make offline/online; boost (plan → payment); report (row stored); call button opens the dialer with the owner's number; Arabic RTL on home/profile; logout → login as another account; edit profile (phone saved); profile picture set server-side shows on the profile; offline (Wi-Fi + data off): cached home feed and cached listing details load, writes show the offline message.

Not covered: Google sign-in (needs a real Google account on the device), password-reset email delivery (SMTP), push notifications (FCM).

Side effects to clean up: two generated test images uploaded to the real Cloudinary account (`profiles/vfm1nlckb5puby3nc5xw`, `listings/bkdl1gmietdwhcfxsgsf`); on 2026-10-31 `manage.py migrate` was run once against the hosted DB by mistake (applied `api.0002`, a SQL no-op that was pending deploy anyway); a `test_neondb` database may be left on the Neon server from earlier test runs.

### New backlog from step 3
- Boost: `boost-listing` creates no `Boosting` row, so boosts never expire; the Boost button stays visible on boosted listings (can pay twice); plan cards promise "analytics" that doesn't exist. Fold into the payments decision.
- Edit listing has no Area field (create does).
- Price formatting is inconsistent: `52000000.0 DZD` (home cards) vs `30,000 DZD` (search/my listings).
- Placeholder avatar `assets/profile.png` is a photo of a person; agent card / profile show it for users without a picture.
- Settings "Contact Us" is placeholder data (+1 (234) 567-890, generic social links).
- `PasswordResetRequestAPI` reveals whether an email has an account.
- Cold start in the debug build takes 10–20 s on the emulator (before the first frame); re-measure in a release build before acting.
- Uncached listing images show an endless spinner offline instead of a placeholder.
- The login success snackbar floats over the bottom bar for 2 s and swallows the first tab tap.
- More hard-coded English: My Listings tabs and menu ("Online", "Make Offline"), avatar sheet ("Choose from Gallery", "Remove Photo"), snackbars.

## Remaining backlog

### Needs a decision
- **Payments are not real.** `boost-listing` accepts any card details and boosts; the app sends full card number + CVV to our server. Chargily keys exist but are unused. Needs a Chargily checkout + webhook flow, and the app should stop collecting card data.
- Deploy: redeploy the backend (login/register now return the user `id`; `api.0002` is already applied); set `SECRET_KEY` and `ALLOWED_HOSTS` on Render. Optional: add `rest_framework_simplejwt.token_blacklist` to `INSTALLED_APPS` + migrate so logout revokes refresh tokens.
- `save_listing` mutates on GET (kept for app compatibility).

### Code health
- `findar_app/.env` is bundled as a Flutter asset → TomTom key ships in the APK (OK only if app-restricted). Cloudinary unsigned preset + API key hard-coded in `cloudinary_service.dart`.
- Many hard-coded English strings remain (snackbars, dialogs, Online/Offline options, agent card fallbacks).
- Saved state still duplicated across `RecentCubit` / `SponsoredCubit` (`savedIds`) and `SavedListingsCubit`.
- Password-reset screens and `ProfileCubit.fetchUserById` call services directly (convention: via repository).
- `print` logging (93 sites); deprecated Material APIs (67).
- `pubspec.yaml`: placeholder description; unused-looking deps (`group_button`, `main_button`, `cloudinary_flutter` / `cloudinary_url_gen`). `applicationId` still `com.example.findar`. AGP/Gradle/Kotlin upgrade pending.
- Pipfile vs requirements.txt — pick one. Root `main.py`, `pyproject.toml`, `.python-version`, `temp_app/` are scaffolding leftovers.
- `similar_properties_list.dart` unused (similar listings were mock data).
