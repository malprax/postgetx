import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:postgetx/bindings/app_bindings.dart';
import 'package:postgetx/firebase_options.dart';
import 'package:postgetx/modules/dashboard/views/dashboard_staff_view.dart';
import 'package:postgetx/routes/app_pages.dart';
import 'package:postgetx/themes/app_theme.dart';

import 'modules/auth/controllers/auth_controller.dart';
import 'modules/dashboard/views/dashboard_admin_view.dart';
import 'modules/dashboard/views/dashboard_customer_view.dart';
import 'modules/dashboard/views/dashboard_guest_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RetailApp());
}

class RetailApp extends StatelessWidget {
  const RetailApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthController());

    return Obx(() {
      // Belum login → tampilkan dashboard guest
      if (auth.firebaseUser.value == null) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: AppBindings(),
          getPages: AppPages.routes,
          home: const DashboardGuestView(),
        );
      }

      // Sudah login tapi user model belum dimuat → loading spinner
      if (!auth.isUserModelLoaded.value) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      // Sudah login dan user model sudah tersedia → arahkan berdasarkan role
      final role = auth.currentUserModel.value?.role;
      Widget homePage;

      if (role == 'admin') {
        homePage = const DashboardAdminView();
      } else if (role == 'customer') {
        homePage = const DashboardCustomerView();
      } else if (role == 'staff') {
        homePage = const DashboardStaffView();
      } else {
        // fallback untuk role lain seperti staff atau undefined
        homePage = const DashboardGuestView();
      }

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialBinding: AppBindings(),
        getPages: AppPages.routes,
        home: homePage,
      );
    });
  }
}
