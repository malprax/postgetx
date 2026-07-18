import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'app_routes.dart';

class WorkspaceDestination {
  const WorkspaceDestination({
    required this.title,
    required this.route,
    required this.icon,
    required this.permission,
  });

  final String title;
  final String route;
  final IconData icon;
  final AppPermission permission;
}

abstract final class WorkspaceRouteMetadata {
  static const checkout = WorkspaceDestination(
    title: 'Checkout',
    route: AppRoutes.cashier,
    icon: AppIcons.checkout,
    permission: AppPermission.accessCashier,
  );
  static const orders = WorkspaceDestination(
    title: 'Orders',
    route: AppRoutes.orders,
    icon: AppIcons.orders,
    permission: AppPermission.viewOrders,
  );
  static const products = WorkspaceDestination(
    title: 'Products',
    route: AppRoutes.products,
    icon: AppIcons.products,
    permission: AppPermission.manageProducts,
  );
  static const inventory = WorkspaceDestination(
    title: 'Inventory',
    route: AppRoutes.inventory,
    icon: AppIcons.inventory,
    permission: AppPermission.manageInventory,
  );
  static const customers = WorkspaceDestination(
    title: 'Customers',
    route: AppRoutes.customers,
    icon: AppIcons.customers,
    permission: AppPermission.manageCustomers,
  );
  static const reports = WorkspaceDestination(
    title: 'Reports',
    route: AppRoutes.reports,
    icon: AppIcons.reports,
    permission: AppPermission.viewReports,
  );
  static const expenses = WorkspaceDestination(
    title: 'Expenses',
    route: AppRoutes.expenses,
    icon: AppIcons.expenses,
    permission: AppPermission.manageExpenses,
  );
  static const settings = WorkspaceDestination(
    title: 'Settings',
    route: AppRoutes.settings,
    icon: AppIcons.settings,
    permission: AppPermission.manageSettings,
  );
  static const notifications = WorkspaceDestination(
    title: 'Notifications',
    route: AppRoutes.notifications,
    icon: Icons.notifications_outlined,
    permission: AppPermission.viewOrders,
  );
  static const trash = WorkspaceDestination(
    title: 'Trash',
    route: AppRoutes.trash,
    icon: Icons.restore_from_trash_outlined,
    permission: AppPermission.viewTrash,
  );

  static const destinations = <WorkspaceDestination>[
    checkout,
    orders,
    products,
    inventory,
    customers,
    reports,
    expenses,
    settings,
    notifications,
    trash,
  ];

  static WorkspaceDestination? tryFromRoute(String? route) {
    if (route == null) return null;
    final normalized = route.split('?').first.replaceFirst(RegExp(r'/$'), '');
    for (final destination in destinations) {
      if (destination.route == normalized ||
          (destination == checkout && normalized == '${AppRoutes.cashier}/')) {
        return destination;
      }
    }
    return null;
  }

  static WorkspaceDestination fromTitle(String title) =>
      destinations.firstWhere(
        (destination) => destination.title == title,
        orElse: () => checkout,
      );
}
