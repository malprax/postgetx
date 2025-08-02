// lib/routes/app_routes.dart
abstract class Routes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';

  static const users = '/users';
  static const profile = '/profile';
  static const auditlogs = '/audit-logs';
  // static const report = '/report';

  static const category = '/category';
  static const pos = '/pos';
  static const stock = '/stock';
  static const orders = '/orders';
  static const orderHistory = '/order-history';

  static const loyalty = '/loyalty';
  static const preorder = '/preorder';
  static const tracking = '/tracking';
  static const audit = '/audit';

  static const initial = dashboard;
}
