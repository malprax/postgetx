import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:postgetx/app/core/config/app_config.dart';
import 'package:postgetx/app/routes/app_routes.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.demoMode) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.science_outlined,
                size: 18, color: colors.onSecondaryContainer),
            const SizedBox(width: 8),
            const Expanded(
                child: Text(
                    'Demo Mode — Data is stored only in this browser and may be reset.')),
            TextButton(
                onPressed: () => Get.toNamed(AppRoutes.settings),
                child: const Text('Settings')),
          ],
        ),
      ),
    );
  }
}
