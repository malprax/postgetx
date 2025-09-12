// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:postgetx/bindings/app_bindings.dart';
import 'package:postgetx/firebase_options.dart';
import 'package:postgetx/routes/app_pages.dart';
import 'package:postgetx/themes/app_theme.dart';

import 'modules/auth/controllers/auth_controller.dart';
import 'modules/dashboard/views/dashboard_admin_view.dart';
import 'modules/dashboard/views/dashboard_customer_view.dart';
import 'modules/dashboard/views/dashboard_guest_view.dart';
import 'modules/dashboard/views/dashboard_staff_view.dart';

void dumpFirebaseOptions() {
  final o = Firebase.app().options;
  // >>> Cocokkan semua ini dengan project di Console tempat koleksi orders terlihat <<<
  debugPrint('FB projectId=${o.projectId}');
  debugPrint('FB appId=${o.appId}');
  debugPrint('FB apiKey=${o.apiKey}');
  debugPrint('FB messagingSenderId=${o.messagingSenderId}');
  debugPrint('FB storageBucket=${o.storageBucket}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  dumpFirebaseOptions();

  // Inisialisasi AuthController sebelum build
  Get.put(AuthController());

  runApp(const RetailApp());
}

class RetailApp extends StatelessWidget {
  const RetailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();

      // Belum login
      if (auth.firebaseUser.value == null) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: AppBindings(),
          getPages: AppPages.routes,
          initialRoute: '/login',
        );
      }

      // Sudah login tapi user model belum selesai dimuat
      if (!auth.isUserModelLoaded.value) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: AppBindings(),
          getPages: AppPages.routes,
          home: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      // Sudah login dan user model sudah tersedia
      String role = auth.currentUserModel.value?.role ?? 'guest';

      Widget home;
      switch (role) {
        case 'admin':
          home = const DashboardAdminView();
          break;
        case 'staff':
          home = const DashboardStaffView();
          break;
        case 'customer':
          home = const DashboardCustomerView();
          break;
        default:
          home = const DashboardGuestView();
      }

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialBinding: AppBindings(),
        getPages: AppPages.routes,
        home: home,
      );
    });
  }
}
