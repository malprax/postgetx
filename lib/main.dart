import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'package:postgetx/app/data/providers/local/loyalty_configuration_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/settings/controllers/loyalty_configuration_controller.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalHiveRepository();
  await repository.initialize();
  Get.put<LocalHiveRepository>(repository, permanent: true);

  final loyaltyConfigurationProvider =
      await LoyaltyConfigurationProvider.create();

  final loyaltyConfigurationController = LoyaltyConfigurationController(
    loyaltyConfigurationProvider,
    repository,
  )..load();

  Get.put<LoyaltyConfigurationController>(
    loyaltyConfigurationController,
    permanent: true,
  );

  final themeController = await ThemeController.create();
  Get.put<ThemeController>(themeController, permanent: true);
  runApp(const RetailApp());
}
