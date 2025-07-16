import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:postgetx/routes/app_routes.dart';
import 'package:postgetx/themes/app_theme.dart';
import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialBinding: InitialBinding(),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? Routes.dashboard
          : Routes.login,
      getPages: AppPages.routes,
    );
  }
}
