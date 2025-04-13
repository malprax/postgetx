// routes/app_pages.dart
import 'package:get/get.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/dashboard/dashboard_page.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.LOGIN, page: () => LoginPage()),
    GetPage(name: Routes.REGISTER, page: () => RegisterPage()),
    GetPage(name: Routes.DASHBOARD, page: () => DashboardPage()),
  ];
}
