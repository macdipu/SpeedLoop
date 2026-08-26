# Play Console — Data Safety Form Answers

Fill this in under **Play Console → App content → Data safety**. Based on the actual permissions and network calls in the codebase (checked 2026-08-26): no ads SDK, no analytics SDK, no account/login, no backend server — everything stays on-device except OpenStreetMap tile requests.

## Does your app collect or share any of the required user data types?
**Yes** (because location is transmitted to the OpenStreetMap tile server to draw the map — that counts as "shared" even though we don't run our own backend).

## Data types

### Location
- **Approximate location**: Collected — NOT shared *(only precise is actually used; you can omit this row if the console lets you pick just Precise)*
- **Precise location**: Collected, and **Shared** with 1 third party (map tile provider)
  - Purpose: **App functionality** (rendering the live map / route)
  - Is this data processed ephemerally? **No** (it's stored locally in the trip database, so answer "no" here — ephemeral only covers data that's used transiently and not persisted)
  - Is data collection required or optional? **Required** (core feature — speed tracking and mapping don't work without it)
  - Data encrypted in transit: **Yes** (tile requests are HTTPS)
  - User can request data deletion: **Yes** — in-app delete trip, or clear app data/uninstall

### Photos and videos
- Dashcam clips are recorded and stored **only on-device**. They are never transmitted by the app.
- **Do not declare this as "collected"** under Play's definition, since collected/shared means data leaves the device via the app. Local-only storage is exempt.
- Exception: if you later add cloud backup/sync for clips, you must add this row and declare it.

### Files and docs (GPX export)
- GPX export and video share use the OS share sheet at the user's explicit action, sending the file only to a destination the user personally selects.
- This is **user-initiated data transfer**, not "collection" by the app, so it does not need to be declared, per Play's Data Safety help center guidance on user-initiated actions.

### App activity, App info and performance, Device or other IDs, Personal info, Financial info, Health, Messages, Web browsing
- **None collected.** No analytics, crash reporting, or ad SDKs are present in `pubspec.yaml`.

## Security practices section
- Data is encrypted in transit: **Yes**
- You can request that data be deleted: **Yes**
- Committed to Play Families Policy: **N/A** (not a Families app)
- Independent security review: **No** (skip unless you've had one)

## Data sold to third parties?
**No.**

## Is all of the user data collected by your app encrypted in transit?
**Yes** — all network calls (OSM tiles) are HTTPS.

## Do you provide a way for users to request their data be deleted?
**Yes** — in-app trip/clip deletion, plus standard Android "Clear app data" / uninstall, since there is no server-side account to separately purge.

---
**Note:** Google's Data Safety form wording changes periodically — cross-check the live form fields against this table before submitting, and re-run this checklist any time you add a new SDK, permission, or network call.
