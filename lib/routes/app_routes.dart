import 'package:get/get.dart';
import 'package:postgetx/views/auth/login_view.dart';
import '../views/dashboard/dashboard_view.dart';

class AppPages {
  static const INITIAL = '/login'; // Initial route (e.g., Login page)

  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        // Bind any login-related controllers
      }),
    ),
    GetPage(
      name: '/dashboard',
      page: () => DashboardView(),
      binding: BindingsBuilder(() {
        // Bind any dashboard-related controllers
      }),
    ),
  ];
}
