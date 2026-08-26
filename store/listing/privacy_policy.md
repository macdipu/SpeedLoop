# SpeedLoop Privacy Policy

**Last updated:** August 26, 2026

Chowdhury eLab ("we", "us", "our") built the SpeedLoop app ("the App") as a free, offline-first GPS speedometer, trip recorder, and dashcam. This policy explains what data the App accesses, how it is used, and your choices.

## Summary

SpeedLoop is designed to work entirely on your device. Trip history, GPS tracks, and dashcam recordings are stored locally in the App's private storage and are **never uploaded to our servers**, because we don't operate any servers that receive your data. We do not sell data, run ads, or use third-party analytics or advertising SDKs.

## Information the App Accesses

| Data | Why it's accessed | Where it goes |
|---|---|---|
| **Precise location (GPS)** | To calculate live speed, record your route, and show your position on the map during a trip. | Stays on your device in the local trip database. Map tile requests send the visible map area (not your exact identity) to OpenStreetMap's tile servers so map imagery can be displayed — see "Map Tiles" below. |
| **Camera** | To record dashcam video with a speed/location/time overlay, only while you start a recording. | Video files are written to local app storage on your device. Never transmitted anywhere by us. |
| **Microphone** | To include audio in dashcam clips, only while a recording is active. | Same as camera — stored locally in the video file only. |
| **Notifications** | To show a persistent notification while a trip is being recorded in the background, as required by Android. | Local notification only; no data leaves the device. |

We do not access your contacts, photos outside the app's own dashcam folder, messages, or any other app's data.

## Background Location

SpeedLoop can keep recording your trip after you lock the screen or switch apps, but **only after you tap "Start Trip."** This is implemented using an Android foreground service with a visible, persistent notification, not the special "background location" permission — so the App never tracks you without an active recording session, and you can stop it at any time from the notification or in-app.

## Map Tiles (OpenStreetMap)

The in-app map is drawn using free map tiles from OpenStreetMap. Displaying the map sends the coordinates of the visible map area to `tile.openstreetmap.org` over HTTPS, the same way any map app fetches map imagery. This is required for the map to render and is governed by the [OpenStreetMap Privacy Policy](https://osmfoundation.org/wiki/Privacy_Policy). We do not attach your identity to these requests beyond what's inherent to any internet request (e.g., your IP address, visible to the tile provider, not to us).

## Data You Choose to Export or Share

Trip data can be exported as a `.gpx` file and dashcam clips can be shared using your device's native share sheet, but only when you explicitly tap "Export" or "Share." These actions send data only to the destination you pick (e.g., your files app, email, or another app you choose) — SpeedLoop itself never automatically uploads or transmits this data.

## Data Storage and Deletion

All trip records, GPS tracks, and dashcam clips are stored locally in a SQLite database and local files under the App's private storage. You can delete individual trips or clips from within the App, or remove all App data at once via **Android Settings → Apps → SpeedLoop → Storage → Clear Data**, or by uninstalling the App.

## Children's Privacy

SpeedLoop is not directed at children under 13 and we do not knowingly collect information from children.

## Third-Party Services

The only third-party service the App communicates with is the OpenStreetMap tile service described above, used solely to display map imagery. SpeedLoop does not integrate any advertising, analytics, or crash-reporting SDKs.

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated "Last updated" date.

## Contact Us

Questions about this policy or your data can be sent to:

**Chowdhury eLab**
Email: c.dipu0@gmail.com
