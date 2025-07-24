// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:postgetx/modules/audit/views/audit_log_view.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';
import 'package:postgetx/modules/auth/views/forgot_password_view.dart';
import 'package:postgetx/modules/dashboard/views/dashboard_admin_view.dart';
import 'package:postgetx/modules/dashboard/views/dashboard_customer_view.dart';
import 'package:postgetx/modules/dashboard/views/dashboard_guest_view.dart';
import 'package:postgetx/modules/dashboard/views/dashboard_staff_view.dart';
import 'package:postgetx/modules/loyalty/views/loyalty_view.dart';

import 'package:postgetx/modules/orders/views/order_view.dart';
import 'package:postgetx/modules/menu/views/category_view.dart';
import 'package:postgetx/modules/pos/views/pos_view.dart';
import 'package:postgetx/modules/preorder/views/preorder_view.dart';
import 'package:postgetx/modules/profile/views/profile_view.dart';
import 'package:postgetx/modules/stock/views/stock_view.dart';
import 'package:postgetx/modules/tracking/views/tracking_view.dart';

import 'package:postgetx/modules/users/views/user_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(
        enableRoleSelection: false,
      ),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordView(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () {
        final role =
            Get.find<AuthController>().currentUserModel.value?.role ?? 'guest';

        switch (role) {
          case 'admin':
            return const DashboardAdminView();
          case 'staff':
            return const DashboardStaffView();
          case 'customer':
            return const DashboardCustomerView();
          default:
            return const DashboardGuestView();
        }
      },
    ),
    GetPage(
      name: Routes.users,
      page: () => const UsersView(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: Routes.auditlogs,
      page: () => const AuditLogView(),
    ),
    // GetPage(
    //   name: Routes.report,
    //   page: () => const ReportView(),
    // ),
    GetPage(
      name: Routes.category,
      page: () => const CategoryView(),
    ),
    GetPage(
      name: Routes.pos,
      page: () => const PosView(),
    ),
    GetPage(
      name: Routes.stock,
      page: () => StockView(),
    ),
    GetPage(
      name: Routes.orders,
      page: () => OrderView(),
    ),
    GetPage(
      name: Routes.loyalty,
      page: () => LoyaltyView(),
    ),
    GetPage(
      name: Routes.preorder,
      page: () => PreorderView(),
    ),
    GetPage(
      name: Routes.tracking,
      page: () => TrackingView(),
    ),
    GetPage(
      name: Routes.audit,
      page: () => AuditLogView(),
    ),
  ];
}
