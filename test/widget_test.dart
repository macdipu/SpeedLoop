// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speedloop/main.dart';
import 'package:speedloop/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(SettingsController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeedLoopApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify app builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
