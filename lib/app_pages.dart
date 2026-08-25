/// GetX Route Configuration
/// Defines app routes, pages, and dependency bindings.
/// Architecture: each feature has its own Binding class for DI.
library;

import 'package:get/get.dart';

import '../features/speedometer/presentation/screens/speedometer_screen.dart';
import '../features/speedometer/presentation/controllers/speedometer_controller.dart';
import '../features/trip/presentation/screens/trip_recording_screen.dart';
import '../features/trip/presentation/screens/trip_history_screen.dart';
import '../features/trip/presentation/screens/trip_details_screen.dart';
import '../features/trip/presentation/controllers/trip_controller.dart';
import '../features/analysis/presentation/screens/trip_analysis_screen.dart';
import '../features/analysis/presentation/controllers/analysis_controller.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/dashcam/presentation/screens/dashcam_screen.dart';
import '../features/dashcam/presentation/controllers/dashcam_controller.dart';
import '../core/database/app_database.dart';
import '../core/shared_widgets/home_shell.dart';

// ---------------------------------------------------------------------------
// Route name constants
// ---------------------------------------------------------------------------
abstract class Routes {
  static const home = '/';
  static const speedometer = '/speedometer';
  static const tripRecording = '/trip/recording';
  static const tripHistory = '/trip/history';
  static const tripDetails = '/trip/details';
  static const tripAnalysis = '/trip/analysis';
  static const settings = '/settings';
  static const dashcam = '/dashcam';
}

// ---------------------------------------------------------------------------
// App Pages — maps routes to pages + bindings
// ---------------------------------------------------------------------------
class AppPages {
  static final pages = [
    GetPage(
      name: Routes.home,
      page: () => const HomeShell(),
    ),
    GetPage(
      name: Routes.speedometer,
      page: () => SpeedometerScreen(),
      binding: SpeedometerBinding(),
    ),
    GetPage(
      name: Routes.tripRecording,
      page: () => TripRecordingScreen(),
      binding: TripBinding(),
    ),
    GetPage(
      name: Routes.tripHistory,
      page: () => const TripHistoryScreen(),
      binding: TripBinding(),
    ),
    GetPage(
      name: Routes.tripDetails,
      page: () => const TripDetailsScreen(),
    ),
    GetPage(
      name: Routes.tripAnalysis,
      page: () => const TripAnalysisScreen(),
      binding: AnalysisBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.dashcam,
      page: () => DashcamScreen(),
      binding: DashcamBinding(),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Bindings
// ---------------------------------------------------------------------------

/// Root app binding — registers singletons shared across the app.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Database as permanent singleton
    Get.put<AppDatabase>(AppDatabase(), permanent: true);
  }
}

/// Speedometer feature binding
class SpeedometerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeedometerController>(() => SpeedometerController());
  }
}

/// Trip feature binding
class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripController>(() => TripController());
  }
}

/// Analysis feature binding
class AnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalysisController>(() => AnalysisController());
  }
}

/// Settings feature binding
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

/// Dashcam feature binding
class DashcamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashcamController>(() => DashcamController());
  }
}
