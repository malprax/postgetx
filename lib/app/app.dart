import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'routes/workspace_route_metadata.dart';
import 'modules/workspace/controllers/workspace_controller.dart';
import 'theme/app_theme.dart';

class RetailApp extends StatelessWidget {
  const RetailApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.productName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          initialBinding: InitialBinding(),
          getPages: AppPages.pages,
          initialRoute: AppRoutes.login,
          routingCallback: (routing) {
            final destination =
                WorkspaceRouteMetadata.tryFromRoute(routing?.current);
            if (destination != null &&
                Get.isRegistered<WorkspaceController>()) {
              Get.find<WorkspaceController>().syncDestination(destination);
            }
          },
        ));
  }
}
