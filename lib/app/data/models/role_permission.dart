enum AppPermission {
  accessCashier,
  createTransaction,
  holdOrder,
  saveOrder,
  resumeOrder,
  viewOrders,
  cancelOpenOrder,
  refundCompletedOrder,
  softDeleteOrder,
  restoreOrder,
  permanentDeleteOrder,
  manageProducts,
  manageCategories,
  manageInventory,
  manageCustomers,
  manageExpenses,
  manageCapitalProtection,
  viewReports,
  manageSettings,
  manageUsers,
  viewAuditLog,
  viewTrash,
}

abstract final class UserRole {
  static const owner = 'owner';
  static const staff = 'staff';
}

abstract final class RolePermissions {
  static const owner = <AppPermission>{
    AppPermission.accessCashier,
    AppPermission.createTransaction,
    AppPermission.holdOrder,
    AppPermission.saveOrder,
    AppPermission.resumeOrder,
    AppPermission.viewOrders,
    AppPermission.cancelOpenOrder,
    AppPermission.refundCompletedOrder,
    AppPermission.softDeleteOrder,
    AppPermission.restoreOrder,
    AppPermission.manageProducts,
    AppPermission.manageCategories,
    AppPermission.manageInventory,
    AppPermission.manageCustomers,
    AppPermission.manageExpenses,
    AppPermission.manageCapitalProtection,
    AppPermission.viewReports,
    AppPermission.manageSettings,
    AppPermission.manageUsers,
    AppPermission.viewAuditLog,
    AppPermission.viewTrash,
  };

  static const staff = <AppPermission>{
    AppPermission.accessCashier,
    AppPermission.createTransaction,
    AppPermission.holdOrder,
    AppPermission.saveOrder,
    AppPermission.resumeOrder,
    AppPermission.viewOrders,
    AppPermission.cancelOpenOrder,
    AppPermission.manageCustomers,
  };

  static Set<AppPermission> forRole(String? role) => switch (role) {
        UserRole.owner => owner,
        UserRole.staff => staff,
        _ => const {},
      };

  static bool allows(String? role, AppPermission permission) =>
      forRole(role).contains(permission);
}
