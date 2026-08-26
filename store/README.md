# SpeedLoop — Play Store Release Kit

Last updated 2026-08-26. Everything needed to submit SpeedLoop to Google Play. Read this top to bottom before submitting.

## What's in here

```
store/
├── icon/, graphics/          design sources for the app icon + feature graphic (already built into the app/fastlane, kept for future edits)
├── landing/                  design source for the landing/privacy pages (also live as Claude Artifacts, see below)
└── listing/
    ├── store_listing.md      title/description/category copy
    ├── data_safety_form.md   exact answers for the Data Safety questionnaire
    └── privacy_policy.md     same policy text as the published privacy page, in Markdown

docs/                         canonical GitHub Pages source (landing page + privacy policy)
fastlane/metadata/android/en-US/   Play Store listing metadata used by the .github release workflow:
  title.txt, short_description.txt, full_description.txt, changelogs/1.txt,
  images/icon.png (512×512), images/featureGraphic.png (1024×500),
  images/phoneScreenshots/1..7.png (7 real-device screenshots, captioned)
```

## Published pages (fill these into Play Console)

Hosted on **GitHub Pages** from this repo, source in `docs/`:

- **Landing page / website**: https://macdipu.github.io/SpeedLoop/
- **Privacy Policy URL**: https://macdipu.github.io/SpeedLoop/privacy.html

**One manual step left:** GitHub Pages isn't enabled by a `git push` alone — go to the repo's **Settings → Pages**, set Source to **Deploy from a branch**, branch **main**, folder **/docs**, Save. Live within a minute or two.

Support email is filled in as `c.dipu0@gmail.com` — change it in `docs/privacy.html`, `docs/index.html`, and `fastlane/metadata/android/en-US/full_description.txt` if you'd rather use something else, then push again.

## App icon — done

The app was shipping the default Flutter template icon; replaced with a branded speedometer mark (teal arc + orange needle, matching `lib/core/utils/app_theme.dart`'s real color tokens). Wired via `flutter_launcher_icons` in `pubspec.yaml` and already generated — every Android density, the adaptive icon, and the iOS `AppIcon.appiconset` are up to date. The splash screen (`launch_background.xml`) uses the new dark brand background + icon instead of the default white/Flutter splash.

## Landing page — built with Claude Design, ported to production

The marketing site started as hand-authored HTML, then was rebuilt in Claude Design's canvas editor (a live editable version exists at that tool's artifact link if you want to keep tweaking it visually) and the final result was hand-ported into `docs/index.html` — the canvas format itself isn't meant for production hosting. Covers all 8 features (speedometer, HUD mode, trip recording, trip analysis/map, dashcam, speed alerts, GPX export, customization), with magnetic-hover buttons, scroll-reveal, and a hero parallax/count-up animation.

## Screenshots — done, real device captures

Captured from the actual app running on an Android emulator (Pixel 4a, API level matching this repo's target), not hand-drawn mockups:

1. Speedometer (Digital view, GPS connected)
2. Live map with route marker (OpenStreetMap tiles + attribution)
3. Trip history / Drive Insights dashboard
4. Trip detail with route polyline on the map
5. Dashcam recording overlay
6. Mirrored HUD mode (landscape)
7. Settings (units, theme, speed alert, loop recording)

Trip data (#3/#4) is realistic seeded data (14.2 km, 38.7 km/h avg, 77 km/h max) inserted directly into the local SQLite DB — the emulator's mock GPS provider doesn't report a speed value on injected fixes, so a live recorded trip wasn't an option for a compelling screenshot. Each raw capture was composited into a branded frame with a caption matching the store listing copy. Source captures + the compositing script are in the session scratchpad if you want to regenerate with different captions later; the finished PNGs are what's committed.

## .github — fixed a real bug

`release.yml` was a copy-paste leftover from a different app in this developer's account (`com.chowdhuryelab.muslimdeen`, `muslim-deen-*` artifact filenames) — fixed to `com.chowdhuryelab.speedloop` / `speedloop-*`. The workflow's `fastlane supply` Play upload step now has real metadata to upload (see `fastlane/` above, which didn't exist before). The landing page's "Download APK (GitHub)" button now points at a versioned release-tag URL the workflow's release step can find and rewrite on each tag push.

## Policy / compliance fixes made to the app

| Issue | Fix |
|---|---|
| Map screens fetched OpenStreetMap tiles with no on-screen attribution — a violation of the [OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/) and the ODbL license | Added `RichAttributionWidget` with "OpenStreetMap contributors" to all 3 map widgets |
| Default Flutter template launcher icon and splash screen | Replaced with branded icon + dark splash |
| No Privacy Policy existed | Drafted and published |
| `.github/release.yml` targeted the wrong app's package name/artifacts | Fixed to SpeedLoop's actual identity |

## Policy items checked — already compliant, no change needed

- **Background location**: the app does *not* request `ACCESS_BACKGROUND_LOCATION`. It uses a foreground service (`FOREGROUND_SERVICE_LOCATION`) with a persistent notification instead, avoiding Play's stricter Background Location Access review entirely.
- **Permissions**: every permission in `AndroidManifest.xml` is actually used and justified — no dead permissions to trim.
- **No ads, no analytics/crash SDKs, no third-party trackers** — keeps the Data Safety form simple.
- **No cleartext traffic** — the only network calls are HTTPS (`tile.openstreetmap.org`).
- **No hardcoded secrets/API keys** in `lib/`, `android/`, or `ios/`.
- **Signing key** (`android/key.properties`) already exists and is gitignored — don't lose it.
- **In-app data deletion** exists, matching what the privacy policy promises.
- **iOS `Info.plist`** usage-description strings are already present and accurate.

## Still needs you

1. **Play Console listing**: paste in the copy from `listing/store_listing.md` (or let the `.github/workflows/release.yml` `fastlane supply` step do it automatically on a tagged release, now that `fastlane/` metadata exists).
2. **Data Safety form**: answer it using `listing/data_safety_form.md`.
3. **GitHub Pages toggle**: the one manual step above.
4. **Content rating questionnaire**: answer honestly per `store_listing.md` — expect "Everyone."
5. **App access declaration**: no login exists, so pick "All functionality is available without special access."
6. **Cut a real release**: `git tag vX.Y.Z && git push --tags` triggers `.github/workflows/release.yml`, which builds, signs (needs the `ANDROID_KEYSTORE_BASE64` etc. secrets), and optionally uploads to Play if `PLAY_SERVICE_ACCOUNT_JSON` is set.
