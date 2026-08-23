# SpeedLoop - GPS Speedometer & Trip Analysis

A production-ready Flutter application for tracking real-time speed, recording trips, and analyzing driving data. Built with Vertical Slice Architecture and Clean Architecture principles.

## 🚀 Features

*   **Real-time GPS Tracking:** Monitor live speed, maximum speed, average speed, heading, and altitude.
*   **Trip Recording:** Start, stop, and save trips. The app logs location points continuously during an active trip.
*   **Background Location Tracking:** Continues to record trip data seamlessly even when the app is in the background or the screen is locked.
*   **Trip Analysis & Map Integration:** View historical trips with detailed metrics (duration, distance, top speed, average speed) and visualize the driven route on an interactive OpenStreetMap.
*   **Dashcam Video Overlay:** Record video using the device camera with real-time speed, location, and timestamp watermarks overlaid. Features loop recording with auto-deletion of oldest files when storage limits are reached.
*   **GPX Export & Import:** Export recorded trips to standard `.gpx` format for use in other GIS tools, and import existing GPX files to view them in the app.
*   **HUD (Head-Up Display) Mode:** A mirrored UI mode designed to be reflected on the car's windshield for safe night driving, complete with speed limit visual warnings.
*   **Speed Limit Alerts:** Configurable audio (Text-to-Speech) and visual warnings when exceeding user-defined speed limits.
*   **Local Persistence:** Robust, offline-first data storage using **Drift (SQLite)**.
*   **Settings Management:** Customizable preferences (e.g., speed units, themes, languages).
*   **State Management:** Reactive clean UI powered by **GetX**.

## 🏗️ Technical Stack

*   **Framework:** Flutter (Dart)
*   **Architecture:** Vertical Slice Architecture + Clean Architecture
*   **State Management & Routing:** GetX
*   **Database:** Drift (SQLite)
*   **Location:** Geolocator & Flutter Background Service
*   **Maps:** Flutter Map & LatLong2
*   **Camera:** Camera plugin & FFMPEG (for video overlays)
*   **Audio:** Flutter TTS

## 🏃 Getting Started

1.  Ensure you have **FVM** (Flutter Version Management) installed.
2.  Run `fvm flutter pub get` to fetch dependencies.
3.  Run `fvm dart run build_runner build --delete-conflicting-outputs` to generate Drift database files.
4.  Run `fvm flutter run` to start the app.
