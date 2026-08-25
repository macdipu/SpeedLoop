/// main.dart — App entry point
/// Sets up GetMaterialApp with:
///   - Dark/Light theming
///   - GetX routing
///   - Flutter localizations (30+ languages)
///   - Root dependency binding
///   - Background trip-worker initialisation
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/background_location_service.dart';

import 'app_pages.dart';
import 'core/utils/app_theme.dart';
import 'core/localization/app_translations.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers that need to persist data on startup
  Get.put(SettingsController());

  // Lock to portrait by default (HUD mode overrides temporarily)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const SpeedLoopApp());

  // Service configuration is not needed to paint the first frame. startTrip
  // awaits the same memoized future, so an immediate tap cannot race it.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(BackgroundLocationService.init().catchError((Object _) {}));
  });
}

class SpeedLoopApp extends StatelessWidget {
  const SpeedLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    final settings = Get.find<SettingsController>();

    return Obx(() => GetMaterialApp(
          title: 'SpeedLoop',
          debugShowCheckedModeBanner: false,

          // Theme (Reactive)
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              settings.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,

          // Localization
          translations: AppTranslations(),
          locale: settings.locale.value,
          fallbackLocale: const Locale('en'),

          // Localization — 30+ languages
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('pt'),
            Locale('ru'),
            Locale('zh'),
            Locale('ja'),
            Locale('ko'),
            Locale('ar'),
            Locale('hi'),
            Locale('bn'),
            Locale('tr'),
            Locale('nl'),
            Locale('pl'),
            Locale('sv'),
            Locale('da'),
            Locale('fi'),
            Locale('nb'),
            Locale('cs'),
            Locale('sk'),
            Locale('hu'),
            Locale('ro'),
            Locale('bg'),
            Locale('uk'),
            Locale('id'),
            Locale('ms'),
            Locale('vi'),
            Locale('th'),
          ],

          // GetX Routing
          initialRoute: Routes.home,
          getPages: AppPages.pages,
          initialBinding: AppBinding(),

          // Default transition
          defaultTransition: Transition.cupertino,
        ));
  }
}
