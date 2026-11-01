# Findar redesign: implementation spec (step 4b)

The design was approved by the owner on 2026-11-01. This file has everything needed to build it in `findar_app/` without the original chat.

- **Canvas (visual source)**: https://claude.ai/artifact/NXLyPR63DLLKiY4ezRvt4D (Claude Design, slug `ae4c8883-4a74-402f-aa01-6bfe85b6530e`, owner-private). It has 29 artboards on 5 pages, with blue sticky notes holding the motion specs.
- **Exact values**: [generator/gen.py](generator/gen.py) produced every artboard. Each screen is an `s_<name>()` function, and the shared pieces are helpers (`feature_card`, `row_card`, `type_card`, `hero_search`, `glass_tile`, `wave_header`, `tabbar`, …). When a pixel value, colour or string is in doubt, read the function. Functions in the "v3 overrides" block near the end replace earlier ones with the same name.
- **Brand files**: [brand/](brand/): vector mark (blue / ink / white), 1024 app icon, Android adaptive foreground (432, mark inside the 66% safe zone, background `#0A5FC2`).

## 1. Foundations

### Colour tokens
| Token | Light | Dark | Use |
|---|---|---|---|
| bg | `#FFFFFF` | `#0E1014` | screen background |
| surf | `#F3F4F6` | `#1B1E24` | fields, chips, inactive tiles |
| line | `#E4E6EA` | `#2B2F37` | borders, dividers |
| ink | `#111317` | `#F2F3F5` | text and the **primary button fill** |
| muted | `#5B6170` | `#A3A9B5` | secondary text (passes 4.5:1) |
| accent (Findar blue) | `#0A5FC2` | `#6AA6F0` | links, selection, active tab, icons in tiles |
| accentT (blue tint) | `#E7EFFA` | `#16263B` | selected cards, icon circles, header tint |
| btn / btnText | `#111317` / `#FFF` | `#F2F3F5` / `#111317` | primary pill button |
| amber | `#F5B341` | same | **boosted only**: badge, boost icon, "Most chosen" |
| green / greenT | `#11734A` / `#E3F3EA` | `#5CC78F` / `#14281E` | online, success, password rules |
| red / redT | `#B42318` / `#FDECEA` | `#F28B82` / `#3A1A18` | delete, log out, errors |
| scrim | `rgba(17,19,23,.5)` | `rgba(0,0,0,.6)` | behind sheets |

Brand gradient (hero cards, icon tile, Post button, selected plan tile): `linear 140°: #1C74DB 0% → #0A5FC2 40% → #0B3A80 100%`.
Dark promo cards ("List your property", "Boost a listing"): `linear 135°: #222938 → #111317`.

Rules: there is one ink primary button per screen. Secondary buttons are outlined (bg + 1px line). Blue is used for selection and links, never for a second primary. The only exception is the blue "accent" button kind in the generator, and none of the screens currently use it.

### Type
- **Manrope** (Latin) and **IBM Plex Sans Arabic** (ar). Bundle both as asset fonts rather than `google_fonts`, so offline-first works (weights 400/500/600/700/800 for Manrope, 400/500/600/700 for Plex Arabic). Pick the family by locale.
- Scale: screen title 30/800 (−0.03em) · listing title 24/800 · hero title 29/800 · section header 19/800 (−0.02em) · price 20/800 (card), 21 (details bar) · body 15/500–600 · meta 13/600 · tab label 11 (800 active, 600 inactive) · overline 12/800, uppercase, +0.06em.

### Shape and spacing
- Radius: pills 999 · cards and photos 20 · hero / promo cards 24–28 · fields 16 · thumbnails 14 · icon tiles ≈30% of size · bottom sheets 28 (top corners).
- 4-pt grid, screen padding 20, section gap 20–24, card inner padding 14–18.
- Touch targets ≥ 44: icon buttons 44 (40 inside cards), buttons 52 (48 secondary row), number pills 48×44.
- Icons: outline, stroke 1.8 (2–2.4 when active or small), 20/24 px, rounded caps and joins. Filled only for the saved bookmark and the active Saved tab. The generator's `ICONS` dict has the SVG paths. Use `flutter_svg` with these paths, or the closest Material Symbols Rounded (outlined) equivalents.

### Prices
One formatter everywhere: thin-space thousands plus `DA` (Arabic `دج`), e.g. `52 000 000 DA`. Rent appends a muted `/ month` (`/ شهر`). Build it as a single `PriceText` widget, so the old `52000000.0 DZD` vs `30,000 DZD` mismatch can't come back.

## 2. Decoration system (the "glass" look)
These come from the owner's reference app and replaced an earlier tile pattern and skyline drawing, which the owner rejected. Build them as reusable widgets in `core/widgets/decor/`:

| Widget | Recipe (see the generator helper of the same name) |
|---|---|
| `SoftTop` | Top tint `accentT → bg` (height 200–300) + 3 concentric rings (r 80/120/160, accent at 14/10/6% opacity) off the top-right corner + a 150px accent circle at 5% on the left. Used behind tab-screen headers, auth screens and settings. |
| `Rings` | Concentric stroke circles (1.2px, accent, decreasing opacity). A `CustomPainter`. |
| `GlassTile` | Rounded square (radius 30% of size) rotated −12…+12°, holding one icon. **On blue**: fill `white 40%→10%` (145°), border white 45%, shadow `0 12 26 rgba(4,30,70,.3)`, backdrop blur 8, white icon. **On light**: fill `bg→surf`, 1px line border, soft shadow, blue icon. |
| `Bubble` / `Sparkle` | White 35% circles with an inner 1px white ring; a 4-point star at 40–60% opacity. |
| `BlueCard` | Brand gradient + 2 big white circles (8% and 7%) + rings at the top-right. Base for the hero search, auth art cards and the icon tile. |
| `GlassTag` | Pill, 34 high, white 15% fill, white 35% border, blur 6, 13/700 white text, slight rotation. Tappable. |
| `WaveHeader` | Light tint + rings + 3 layered waves at the bottom (accent 14%, accent 28%, solid `#0A5FC2`). Used by Profile (h 400) and Owner profile (h 300). Wave paths are in `wave_header()`. |
| `SpotIllustration` | Tinted disc + 2 rings + 2 small light glass tiles + a sparkle around a centre icon. Used for empty/error states and Boost confirmed. |
| `TypeCard` | 136×148 card: corner circle (116, accentT) top-end, small circle bottom-start, sparkle, 52 icon circle, 30 chevron circle at the top-end, label at the bottom. |
| Floating tab bar | See screens. |

Keep decoration behind content (`Stack`, decorations first, `IgnorePointer`) and keep text contrast. Under reduced motion, decorations stay but don't animate.

## 3. Screens
Every route in `main.dart` is covered. Board = canvas artboard file. The 4-tab bottom bar becomes a 5-slot floating bar.

| Board | Route / Dart file | Notes |
|---|---|---|
| Splash, Splash dark | `/landing`, `features/landing/` + native splash | White (dark: `#0E1014`) with tint top and bottom, rings around a 116 gradient icon tile, 4 light glass tiles (pin, bookmark, key, home), lowercase **findar** wordmark 40/800, tagline "Your property marketplace", thin progress bar. Native splash (`flutter_native_splash`) shows only the tile on bg; Flutter then animates the rest. |
| Welcome | `/landing` (Get started step) | Full-bleed photo (top 520) + white lockup + "Find a place to call home." Bottom sheet: copy, **Log in** + **Create account** buttons, "or", **Continue with Google**. No Apple or Facebook. |
| Log in | `/login` | Blue art card (150) with glass tiles, "Welcome back", email, password (eye toggle), Forgot password?, Log in, Google, Register link. |
| Register | `/register` | Account type as two selectable cards (Individual / Agency), full name, email, phone, password + live rule chips (8+, upper, lower, number). Sticky "Complete registration". |
| Profile photo | `/profile-picture-setup` | Rings + glass tiles around a dashed 168 circle, gradient camera badge, Choose from gallery / Take a photo, Skip. |
| Forgot password | `/forgot-password` | Art card, email, "Code sent" success strip, code field, Verify code, Resend. |
| Reset password | `/reset-password` | Art card, new + confirm, rule chips, sticky "Update password". |
| **Home** (Main) | `/home`, `features/home/` | Header: "Hello, {name}" + lockup (blue mark), settings button. **Hero search card** (290): title "Find your next place", glass search pill (opens search) with white filter button, floating hashtag chips (a static list of cities/types that run a quick search). **"List your property" banner** → create listing. **Browse by type**: horizontal TypeCards (House, Apartment, Villa, Studio, Office) → search results filtered by type. **Sponsored** carousel (296 cards, Boosted badge, bookmark). **Recent listings** rows. Remove the old All/Sale/Rent chip row (the hero and filters cover it). |
| Advanced search | `/filtering` | Close + "Advanced search" + Reset. Segmented Any/For sale/For rent, location, type chips with icons, price range slider + min/max DA fields, bedrooms and bathrooms pills (Any,1,2,3,4+; Any = send nothing), min area m², listed by Anyone/Owner/Agency. Sticky "Show results". No price histogram (there's no data for it). |
| Search results | `/search-results` | Back + query pill + filter button with an active-count badge, removable active-filter chips, "N results" + sort menu (Newest; `sort_by` supports distance), full-width cards. |
| Property details | `/property-details` | 380 photo carousel (back, bookmark, "1 / n"), 28-radius sheet overlapping by 28: badges (Boosted, For sale, type), title, location + "Listed n days ago" (`created_at`), 3 stat tiles, description clamped to 4 lines + Read more, "Listed by" owner card (initials avatar, name, account type, View profile, SMS button), "Report this listing" link. Sticky bar: price + **Call**. No map and no similar listings (those were mock data). |
| Report sheet | details bottom sheet | Radio cards: Fraudulent listing, Inaccurate information, Inappropriate content, No longer available; optional details; Send report. |
| Saved | `/saved-listings` | SoftTop, "Saved" + count, 2-column grid, filled bookmarks. |
| Owner profile | `/user-profile` | WaveHeader 300 (back, avatar, name, Agency/Individual pill), Message + Call, listings grid. |
| My listings | `/my-listings` | SoftTop, title + ink "+" button, segmented Online · n / Offline · n, cards with status pill (green dot) + Boosted badge + "⋯" menu: Edit, Boost (**hidden when already boosted**), Make offline/online, Delete (red, confirm). |
| New / edit listing | `/create-listing`, `/edit-listing` | Same screen. Photos row (Add tile, thumbs with remove, first = "Cover"), title, description, Sale/Rent segmented, type chips, price + DA, bedrooms/bathrooms steppers, **area m² (edit must have it too)**, TomTom location autocomplete with suggestion dropdown, "Visible to buyers" switch. Sticky "Publish listing" / "Save changes". Edit adds "Delete listing" at the bottom. |
| Boost plans | `/sponsorship-plans` | Listing mini card, plan cards (icon tile: bolt/star/building, corner circle, radio, `[PRICE] DA · [N] days` from `BoostingPlan`, feature checks). **Drop the analytics features** (they don't exist). Sticky "Continue to payment". |
| Checkout | `/payment-confirmation` | Order summary card + payment method Edahabia / CIB + "You'll finish on Chargily's secure payment page. Findar never sees your card details." + "Pay [PRICE] DA". **Needs the backend Chargily checkout and webhook first** (roadmap "Payments are not real"). Until then keep the current form behind the new look or block boosting; ask the owner. |
| Boost confirmed | after payment | Spot illustration with amber bolt, "Your listing is boosted", "{title} now appears in Sponsored until {end}", View listing / Done. |
| Profile | `/profile` | WaveHeader 400: "Profile" + settings, avatar (initials when there's no photo; **never the stock person photo**) with camera badge, name, email, account-type pill, white "Edit profile" pill. Stats card: Listings / Online / Saved. Dark "Boost a listing" card → plans. Contact card (phone, email). My listings preview (2) + See all. Log out lives in Settings. |
| Edit profile | `/edit-profile` | Avatar + Change photo, full name, email, phone, sticky Save changes. |
| Settings | `/settings` | Grouped cards: Appearance (dark-mode switch), Language (radio list: English / العربية / Français), Contact us (`[SUPPORT PHONE]`, `[SUPPORT EMAIL]`, real values needed from the owner), Account (Log out, red). |
| Shared states | everywhere | Skeleton rows (surf blocks), offline banner (wifi-off, "You're offline", Retry), empty (spot + title + body + Browse listings), error (spot + Try again), dark snackbar with Undo. |
| Home dark / Home Arabic | | Same widgets with dark tokens / RTL + Plex Arabic. Use `EdgeInsetsDirectional` and `PositionedDirectional` everywhere. Decorations mirror. |
| App icon and logo, Foundations | | Brand and token reference. |

### Floating tab bar (all 4 tab screens)
A rounded pill (h 70, radius 35, inset 14 from the sides and 18 from the bottom, bg white 94% / dark `rgba(27,30,36,.94)`, blur 16, 1px line, shadow `0 14 34 rgba(17,19,23,.14)`). Order: Home · Saved · **Post** · My listings · Profile. Post is a 60 gradient circle raised 34px with a 5px bg-coloured ring, a white "+", and the label "Post" (ar "انشر"). It opens Create listing. Active tab is blue with label weight 800. Content gets ≥120 bottom padding, plus a fade (`transparent → bg`) behind the bar.

## 4. Motion (from the canvas sticky notes)
- **Splash**: the tile springs in (0.9→1), the house outline draws then the inner f (stroke reveal 450 ms each, 120 ms overlap), rings ripple out once, glass tiles drift in 8px then bob ±3px over a 4 s loop, the progress bar loops during the session check, then the tile becomes a Hero into the Welcome header logo.
- **Auth**: field focus border → blue 150 ms; rule chips tick green (scale 0.6→1, 180 ms); the submit button morphs into a 52 circle with a spinner; errors shake 3× over 300 ms + haptic.
- **Home hero**: hashtag chips float ±4px (5–7 s, offset phases) and pause while scrolling; the search pill expands into the search screen (shared element); type cards press to 0.97, chevron nudges 2px.
- **Card → details**: photo Hero 300 ms (emphasized decelerate); the sheet slides up 24px and fades in after 80 ms.
- **Lists**: first load staggers fade + 12px rise, 40 ms apart, max 6; skeleton shimmer 1.2 s. **Bookmark**: scale 1→1.25→1 spring + fill + light haptic + snackbar with Undo.
- **Filters and sheets**: segmented thumb slides 220 ms; chips cross-fade 150 ms; result count rolls; sheets spring up, scrim 200 ms, drag to dismiss.
- **Listing actions**: menu scales from the "⋯" (0.9→1, 160 ms); make offline dims the card and bumps the Offline count; delete collapses height 220 ms.
- **Boost**: selected plan ring grows 180 ms; success spot springs in, bolt pops, one soft haptic.
- **Tabs**: Post button 0.94→1.04→1 spring, opens Create listing as a bottom sheet route; tab switch fade-through 200 ms; theme change cross-fade 250 ms; language change 200 ms fade.
- **Reduced motion** (`MediaQuery.disableAnimations`): every slide, scale and Hero becomes a 150 ms cross-fade; no shimmer or floating.

## 5. Implementation plan
1. **Assets and packages**: add `flutter_svg`, `flutter_native_splash`, `flutter_launcher_icons` (dev). Bundle the Manrope and IBM Plex Sans Arabic TTFs. Export PNGs from `brand/*.svg` (1024 icon; adaptive foreground + bg `#0A5FC2`; splash tile). Replace `assets/Findar.png` / `.svg` usages. Also set `applicationId` (still `com.example.findar`) if the owner agrees.
2. **Theme**: rewrite `core/theme/color_schemes.dart` and `app_theme.dart` from the tokens (light + dark). Add a `ThemeExtension` for the extra tokens (accentT, amber, green, surf, line, gradients). Text theme from the scale. Component themes: `FilledButton` = ink pill 52, `OutlinedButton` = outlined pill, `InputDecorationTheme` = surf fill radius 16 with a blue focus border, `ChipTheme`, `SegmentedButton`/custom segmented control, `BottomSheetTheme` radius 28. This also clears most of the 67 deprecated-API infos.
3. **Shared widgets**: `PriceText`, `ListingFeatureCard`, `ListingRowCard`, `ListingGridTile`, `SaveButton`, `BoostedBadge`, `StatusPill`, `StatTile`, `InitialsAvatar`, `PillSegmented`, `NumberPills`, `Stepper`, `AppField`, `SectionHeader`, `MenuRow`/settings group card, `FloatingTabBar`, the decor widgets from §2, plus skeleton, offline, empty and error states.
4. **Screens** in this order: Home → Details → Search/Filters/Results → Saved → My listings → Create/Edit → Profile/Owner/Edit profile → Settings → Auth flow → Boost plans/Checkout/Done → Splash/Welcome.
5. **Strings**: every new string goes into `app_en.arb`, `app_ar.arb` and `app_fr.arb`, then `flutter gen-l10n`. New keys include hero title, "List your property", "Sell or rent it out on Findar", "Browse by type", "Post", "Boost a listing", "Show up in Sponsored and higher in search", "See plans", "Visible to buyers", "Cover", "Code sent…", "Listed {n} days ago", "Most chosen", the Chargily note, the empty/offline copy, and the hashtag list. Also localize the hard-coded strings listed in the roadmap backlog. Arabic strings used on the canvas are in `HOME_AR` / `AR_LIST` in the generator.
6. **Motion** (§4), with the reduced-motion fallback.
7. **Verify**: `flutter analyze`, `flutter test` (update widget tests that look for old texts/keys), integration test on `emulator-5554`, screenshots in light, dark and Arabic via mobile-mcp. Then run an **apple-design** skill review. Stop for owner review afterwards (step 5 = owner manual testing).

## 6. Decisions and open items
- Checkout via Chargily needs backend work plus an owner decision (see Checkout row).
- Plan price and duration come from `BoostingPlan` (the duration unit is unclear in the model; confirm days).
- Support phone and email for Settings → Contact us are not known; ask the owner.
- Hashtag chips: a static curated list (cities + types) for now.
- The Post tab is a new entry point to Create listing (approved).
- Placeholder copy on the canvas (`[Owner's description…]`, `[END DATE]`, sample names, sample listings) is illustrative only.
