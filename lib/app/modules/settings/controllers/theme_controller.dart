import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/app/data/providers/local/theme_preferences_provider.dart';

enum AppThemePreference { light, dark, auto }

class ThemeController extends GetxController {
  ThemeController(this._preferences);

  static const boxName = ThemePreferencesProvider.boxName;

  final ThemePreferencesProvider _preferences;
  final preference = AppThemePreference.dark.obs;

  static Future<ThemeController> create() async {
    final preferences = await ThemePreferencesProvider.create();
    final controller = ThemeController(preferences);
    controller.load();
    return controller;
  }

  ThemeMode get themeMode => switch (preference.value) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.auto => ThemeMode.system,
      };

  void load() {
    final saved = _preferences.read(
      fallback: AppThemePreference.dark.name,
    );
    preference.value = AppThemePreference.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => AppThemePreference.dark,
    );
  }

  Future<void> select(AppThemePreference value) async {
    preference.value = value;
    await _preferences.write(value.name);
    Get.changeThemeMode(themeMode);
  }
}
