import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<dynamic> box;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('retail-theme-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'theme-${DateTime.now().microsecondsSinceEpoch}');
  });
  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test('light dark and auto selections apply immediately', () async {
    final controller = ThemeController(box);
    expect(controller.preference.value, AppThemePreference.dark);
    expect(controller.themeMode, ThemeMode.dark);
    await controller.select(AppThemePreference.light);
    expect(controller.themeMode, ThemeMode.light);
    await controller.select(AppThemePreference.dark);
    expect(controller.themeMode, ThemeMode.dark);
    await controller.select(AppThemePreference.auto);
    expect(controller.themeMode, ThemeMode.system);
  });

  test('theme preference persists in its separate box', () async {
    final first = ThemeController(box);
    await first.select(AppThemePreference.dark);
    final restored = ThemeController(box)..load();
    expect(restored.preference.value, AppThemePreference.dark);
  });
}
