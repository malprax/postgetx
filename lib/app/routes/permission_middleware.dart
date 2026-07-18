import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../models/role_permission.dart';
import '../../repositories/local_hive_repository.dart';
import 'app_routes.dart';

class PermissionMiddleware extends GetMiddleware {
  PermissionMiddleware(this.permission);
  final AppPermission permission;

  @override
  RouteSettings? redirect(String? route) {
    final repository = Get.find<LocalHiveRepository>();
    if (repository.currentUser == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (!repository.hasPermission(permission)) {
      return const RouteSettings(name: AppRoutes.cashier);
    }
    return null;
  }
}

class LoginSessionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final repository = Get.find<LocalHiveRepository>();
    return repository.currentUser == null
        ? null
        : const RouteSettings(name: AppRoutes.cashier);
  }
}
