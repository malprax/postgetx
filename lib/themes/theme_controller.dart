import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppThemePreference { light, dark, auto }

class ThemeController extends GetxController {
  ThemeController(this._box);
  static const boxName = 'retail_pos_preferences';
  static const _key = 'themePreference';
  final Box<dynamic> _box;
  final preference = AppThemePreference.dark.obs;

  static Future<ThemeController> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    final controller = ThemeController(box);
    controller.load();
    return controller;
  }

  ThemeMode get themeMode => switch (preference.value) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.auto => ThemeMode.system,
      };

  void load() {
    final saved = _box.get(_key, defaultValue: AppThemePreference.dark.name);
    preference.value = AppThemePreference.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => AppThemePreference.dark,
    );
  }

  Future<void> select(AppThemePreference value) async {
    preference.value = value;
    await _box.put(_key, value.name);
    Get.changeThemeMode(themeMode);
  }
}
