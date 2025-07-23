import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:postgetx/bindings/app_bindings.dart';
import 'package:postgetx/firebase_options.dart';
import 'package:postgetx/routes/app_routes.dart';

import 'package:postgetx/themes/app_theme.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RetailApp());
}

class RetailApp extends StatelessWidget {
  const RetailApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retail Management System',
      theme: AppTheme.light,
      initialRoute: Routes.initial,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
    );
  }
}
