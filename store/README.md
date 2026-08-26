# SpeedLoop — Play Store Release Kit

Generated 2026-08-26. Everything needed to submit SpeedLoop to Google Play lives in this folder, plus a few fixes made directly to the app. Read this top to bottom before submitting.

## What's in here

```
store/
├── icon/
│   ├── icon_full.html / icon_full.png source render     (design source, not needed after build)
│   ├── icon_master.png        900×900 — legacy/iOS app icon source
│   ├── icon_fg.html
│   └── icon_adaptive_fg.png   900×900 — Android adaptive icon foreground (safe-zone scaled)
├── graphics/
│   ├── feature_graphic.html   design source
│   └── feature_graphic.png    1024×500 — Play Store feature graphic
├── landing/
│   ├── index.html             landing page source (published as an Artifact)
│   └── privacy.html           standalone privacy policy page source (published as an Artifact)
└── listing/
    ├── store_listing.md       title/description/category copy, ready to paste into Play Console
    ├── data_safety_form.md    exact answers for the Data Safety questionnaire
    └── privacy_policy.md      same policy text as privacy.html, in Markdown
```

## Published pages (fill these into Play Console)

- **Landing page / website**: https://claude.ai/code/artifact/5bb481a1-f0a0-403b-b2cd-5d63db4b35f6
- **Privacy Policy URL**: https://claude.ai/code/artifact/49d7bd5f-0802-488d-96e5-ec8dc59434dd

Both are private by default. Before you submit, open each and use the page's share menu to make it public — Play Console requires a URL Google can actually crawl. For a permanent setup, point your own domain at this content (e.g. host the two HTML files on GitHub Pages) rather than relying on the artifact link long-term.

Both pages still have a placeholder for your support email — search `[ADD YOUR SUPPORT EMAIL HERE]` in `privacy.html` and republish before going live.

## App icon — done, wired up

The app was shipping the **default Flutter template icon** (blue Flutter mark) — that's fixed. A new brand mark (speedometer arc + needle, using the app's own teal/orange palette) is wired into `pubspec.yaml` via `flutter_launcher_icons`. To generate the actual launcher icon files:

```
fvm flutter pub get
fvm dart run flutter_launcher_icons
```

This regenerates every Android density (`mipmap-*`), the Android 8+ adaptive icon, and the iOS `AppIcon.appiconset`. Also updated the Android splash screen (`launch_background.xml`) to use the new dark brand background + icon instead of the default white/Flutter splash.

*(This command was still running in the background when this kit was generated — the local Flutter SDK version pinned in `.fvmrc`, 3.41.4, wasn't cached and had to download. Run it yourself if it hasn't completed, then rebuild.)*

## Policy / compliance fixes made to the app

| Issue | Fix |
|---|---|
| Map screens fetched OpenStreetMap tiles with no on-screen attribution — a violation of the [OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/) and the ODbL license, real risk of the tile provider blocking the app's requests | Added `RichAttributionWidget` with "OpenStreetMap contributors" to all 3 map widgets (`map_speedometer_widget.dart`, `trip_details_screen.dart`, `trip_recording_screen.dart`) |
| Default Flutter template launcher icon and splash screen | Replaced with branded icon + dark splash (see above) |
| No Privacy Policy existed | Drafted and published (see links above) |

## Policy items checked — already compliant, no change needed

- **Background location**: the app does *not* request `ACCESS_BACKGROUND_LOCATION`. It uses a foreground service (`FOREGROUND_SERVICE_LOCATION`) with a persistent notification instead, which avoids Play's stricter Background Location Access review (prominent in-app disclosure + video demo requirement) entirely.
- **Permissions**: every permission in `AndroidManifest.xml` (location, camera, mic, foreground service, notifications, internet) is actually used and justified by a real feature — no dead permissions to trim.
- **No ads, no analytics/crash SDKs, no third-party trackers** — `pubspec.yaml` confirmed clean, which keeps the Data Safety form simple.
- **No cleartext traffic** — the only network calls are HTTPS (`https://tile.openstreetmap.org`).
- **No hardcoded secrets/API keys** found in `lib/`, `android/`, or `ios/`.
- **Signing key** (`android/key.properties`) already exists and is gitignored — don't lose it; you'll need the same key for every future release or Play will reject the update.
- **In-app data deletion** exists (trip/clip delete flows in `trip_repository_impl.dart`), matching what the privacy policy promises.
- **iOS `Info.plist`** usage-description strings for camera/mic/location are already present and accurate.

## Still needs you (things only you can decide/do)

1. **Play Console listing**: paste in the copy from `listing/store_listing.md` (title, description, category).
2. **Data Safety form**: answer it using `listing/data_safety_form.md` — the mapping is done, you just need to click through the actual Play Console UI.
3. **Screenshots**: not generated in this pass (needs a running emulator/device) — say the word and I'll capture real in-app screenshots next.
4. **Support email**: pick a real one and drop it into `privacy.html` / `index.html` / `store_listing.md` (currently a placeholder — didn't want to publish your personal email without asking).
5. **Content rating questionnaire**: answer honestly per the guidance in `store_listing.md` — expect "Everyone."
6. **App access declaration**: no login exists, so pick "All functionality is available without special access."
7. **Run `fvm flutter pub get && fvm dart run flutter_launcher_icons`** (if it hasn't finished) and rebuild a release AAB (`fvm flutter build appbundle`) before uploading.
