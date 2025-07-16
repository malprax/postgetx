// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:postgetx/bindings/auth_binding.dart';
import 'package:postgetx/bindings/dashboard_binding.dart';
import 'package:postgetx/modules/profile/views/profile_view.dart';
import 'package:postgetx/modules/users/views/user_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.users,
      page: () => const UsersView(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
    ),
  ];
}
