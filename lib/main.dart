import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'repositories/local_hive_repository.dart';
import 'themes/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalHiveRepository();
  await repository.initialize();
  Get.put<LocalHiveRepository>(repository, permanent: true);
  final themeController = await ThemeController.create();
  Get.put<ThemeController>(themeController, permanent: true);
  runApp(const RetailApp());
}
