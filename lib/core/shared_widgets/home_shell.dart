/// HomeShell — Bottom navigation shell that hosts the main feature tabs.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speedloop/core/utils/app_theme.dart';
import 'package:speedloop/features/speedometer/presentation/screens/speedometer_screen.dart';
import 'package:speedloop/features/speedometer/presentation/controllers/speedometer_controller.dart';
import 'package:speedloop/features/trip/presentation/screens/trip_recording_screen.dart';
import 'package:speedloop/features/trip/presentation/screens/trip_history_screen.dart';
import 'package:speedloop/features/trip/presentation/controllers/trip_controller.dart';
import 'package:speedloop/features/dashcam/presentation/screens/dashcam_screen.dart';
import 'package:speedloop/features/dashcam/presentation/controllers/dashcam_controller.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  // Cached screen instances — created once, reused across rebuilds.
  late final SpeedometerScreen _speedometerScreen = SpeedometerScreen();
  late final TripRecordingScreen _tripRecordingScreen = TripRecordingScreen();
  late final TripHistoryScreen _tripHistoryScreen = const TripHistoryScreen();
  // Dashcam is created lazily — only after user first taps the tab.
  DashcamScreen? _dashcamScreen;

  @override
  void initState() {
    super.initState();
    Get.put(SpeedometerController());
    Get.put(TripController());
    // DashcamController created on demand when user first taps the tab.
  }

  void _onTabSelected(int index) {
    setState(() {
      if (index == 3 && _dashcamScreen == null) {
        // First visit: register controller and cache screen instance.
        Get.put(DashcamController());
        _dashcamScreen = DashcamScreen();
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _speedometerScreen,
          _tripRecordingScreen,
          _tripHistoryScreen,
          // Only built once the user taps the Dashcam tab; kept alive after that.
          _dashcamScreen ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.cardBorderColor, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.speed_outlined),
              selectedIcon: Icon(Icons.speed),
              label: 'Speed',
            ),
            NavigationDestination(
              icon: Icon(Icons.radio_button_unchecked),
              selectedIcon: Icon(Icons.radio_button_checked),
              label: 'Record',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam),
              label: 'Dashcam',
            ),
          ],
        ),
      ),
    );
  }
}
