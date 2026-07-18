import 'dart:math';

import 'package:get/get.dart';

import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/expense_model.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/data/models/local_notification_model.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/data/repositories/pos_repository.dart';
import 'package:postgetx/app/data/repositories/loyalty_repository.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/routes/app_routes.dart';
import '../../../routes/browser_route_sync.dart';
import '../../../routes/workspace_route_metadata.dart';
import '../../../data/models/customer_model.dart';

class ProductSale {
  const ProductSale(this.name, this.quantity);
  final String name;
  final int quantity;
}

class WorkspaceController extends GetxController {
  WorkspaceController(
    this.repository,
    this.printer,
    this.loyaltyRepository,
  );

  final PosRepository repository;
  final PrinterService printer;
  final LoyaltyRepository loyaltyRepository;

  final products = <MenuItemModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final orders = <OrderModel>[].obs;
  final customers = <CustomerModel>[].obs;
  final loyaltyBalances = <String, int>{}.obs;
  final expenses = <ExpenseModel>[].obs;
  final notifications = <LocalNotificationModel>[].obs;
  final trashOrders = <OrderModel>[].obs;
  final cart = <CartItemModel>[].obs;
  final resumedOrder = Rxn<OrderModel>();
  final selectedCategory = ''.obs;
  final activeDestination = WorkspaceRouteMetadata.checkout.obs;
  final sidebarCollapsed = false.obs;
  final search = ''.obs;
  final page = 1.obs;
  final loading = true.obs;
  final processingOrder = false.obs;
  final discountType = DiscountType.percentage.obs;
  final discountValue = 10.0.obs;
  final taxType = TaxType.percentage.obs;
  final taxValue = 10.0.obs;
  final salesRange = 'Today'.obs;
  final receiptRange = 'Today'.obs;
  final orderFilter = 'All'.obs;
  final notificationFilter = 'All'.obs;
  static const pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    loading.value = true;
    final results = await Future.wait([
      repository.getProducts(),
      repository.getCategories(),
      repository.getTransactions(includeDeleted: true),
      repository.getCustomers(),
      repository.getExpenses(),
      repository.getNotifications(),
    ]);
    products.assignAll(results[0] as List<MenuItemModel>);
    categories.assignAll(results[1] as List<CategoryModel>);
    final allOrders = results[2] as List<OrderModel>;
    orders.assignAll(allOrders.where((order) => !order.isDeleted));
    trashOrders.assignAll(allOrders.where((order) => order.isDeleted));
    customers.assignAll(results[3] as List<CustomerModel>);

    final balances = await Future.wait(
      customers.map(
        (customer) => loyaltyRepository.getBalance(customer.id),
      ),
    );

    loyaltyBalances.assignAll(
      Map<String, int>.fromIterables(
        customers.map((customer) => customer.id),
        balances,
      ),
    );

    expenses.assignAll(results[4] as List<ExpenseModel>);
    notifications.assignAll(results[5] as List<LocalNotificationModel>);
    loading.value = false;
  }

  List<MenuItemModel> get filteredProducts => products.where((product) {
        final categoryMatches = selectedCategory.isEmpty ||
            product.categoryId == selectedCategory.value;
        final term = search.value.toLowerCase();
        return categoryMatches &&
            (term.isEmpty ||
                product.name.toLowerCase().contains(term) ||
                product.sku.toLowerCase().contains(term));
      }).toList();
  int get pageCount => max(1, (filteredProducts.length / pageSize).ceil());
  List<MenuItemModel> get visibleProducts {
    if (page.value > pageCount) page.value = pageCount;
    final start = (page.value - 1) * pageSize;
    return filteredProducts.skip(start).take(pageSize).toList();
  }

  void selectCategory(String id) {
    selectedCategory.value = id;
    page.value = 1;
  }

  void setSearch(String value) {
    search.value = value;
    page.value = 1;
  }

  void setPage(int value) => page.value = value.clamp(1, pageCount);
  String get activePageTitle => activeDestination.value.title;
  UserModel? get currentUser => repository is LocalHiveRepository
      ? (repository as LocalHiveRepository).currentUser
      : null;
  bool can(AppPermission permission) => repository is LocalHiveRepository
      ? (repository as LocalHiveRepository).hasPermission(permission)
      : false;

  bool canOpenDestination(WorkspaceDestination destination) =>
      can(destination.permission);

  List<WorkspaceDestination> get visibleDestinations =>
      WorkspaceRouteMetadata.destinations.where(canOpenDestination).toList();

  void syncDestination(WorkspaceDestination destination) {
    if (activeDestination.value.route != destination.route) {
      activeDestination.value = destination;
    }
  }

  void selectSection(String title) {
    final destination = WorkspaceRouteMetadata.fromTitle(title);
    if (!canOpenDestination(destination)) {
      _showOperationError('Your role cannot access ${destination.title}.');
      return;
    }
    syncDestination(destination);
    final currentRoute = Get.currentRoute.split('?').first;
    if ((currentRoute == AppRoutes.cashier ||
            currentRoute.startsWith('${AppRoutes.cashier}/')) &&
        currentRoute != destination.route) {
      publishBrowserRoute(destination.route);
      Get.toNamed(destination.route);
    }
  }

  void toggleSidebar() => sidebarCollapsed.toggle();
  void setDiscount(DiscountType type, double value) {
    discountType.value = type;
    discountValue.value = type == DiscountType.percentage
        ? value.clamp(0, 100)
        : value.clamp(0, double.infinity);
  }

  void setTax(TaxType type, double value) {
    taxType.value = type;
    taxValue.value = switch (type) {
      TaxType.none => 0,
      TaxType.percentage => value.clamp(0, 100),
      TaxType.fixedAmount => value.clamp(0, double.infinity),
    };
  }

  void setSalesRange(String value) => salesRange.value = value;
  void setReceiptRange(String value) => receiptRange.value = value;

  void addProduct(MenuItemModel product) {
    if (product.stock <= 0 || product.variants.isEmpty) return;
    final index = cart.indexWhere((item) => item.id == product.id);
    if (index < 0) {
      cart.add(CartItemModel(
          id: product.id,
          name: product.name,
          size: product.variants.first.size,
          price: product.variants.first.price,
          quantity: 1));
    } else if (cart[index].quantity < product.stock) {
      cart[index].quantity++;
      cart.refresh();
    }
  }

  void changeQuantity(String id, int delta) {
    final index = cart.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final stock = products.firstWhere((item) => item.id == id).stock;
    cart[index].quantity = (cart[index].quantity + delta).clamp(0, stock);
    if (cart[index].quantity == 0) {
      cart.removeAt(index);
    } else {
      cart.refresh();
    }
  }

  void removeCartItem(String id) => cart.removeWhere((item) => item.id == id);
  void clearCart() {
    cart.clear();
    resumedOrder.value = null;
  }

  Future<void> cancelCart() async {
    clearCart();
  }

  PosTotals get totals => const PosTotalCalculator().calculate(
        items: cart,
        discountType: discountType.value,
        discountValue: discountValue.value,
        taxType: taxType.value,
        taxValue: taxValue.value,
      );
  PosTotals totalsForPayment(double amountReceived) =>
      const PosTotalCalculator().calculate(
        items: cart,
        discountType: discountType.value,
        discountValue: discountValue.value,
        taxType: taxType.value,
        taxValue: taxValue.value,
        amountPaid: amountReceived,
      );

  Future<OrderModel?> saveOrder(
      {String status = OrderStatus.completed,
      String receiptStatus = ReceiptState.pending,
      bool print = false,
      double? amountReceived,
      String paymentMethod = 'cash',
      String? customerId,
      String? customerName,
      String notes = ''}) async {
    if (cart.isEmpty || processingOrder.value) return null;
    processingOrder.value = true;
    final now = DateTime.now();
    final source = resumedOrder.value;
    final calculation = status == OrderStatus.completed
        ? totalsForPayment(amountReceived ?? totals.total)
        : totals;
    final actor = currentUser;
    final order = OrderModel(
      id: source?.id ?? 'order-${now.microsecondsSinceEpoch}',
      orderId: source?.orderId ??
          'T-${now.millisecondsSinceEpoch.toString().substring(6)}',
      items: cart.map((item) => CartItemModel.fromMap(item.toMap())).toList(),
      subtotal: calculation.subtotal,
      discountType: calculation.discountType,
      discountValue: calculation.discountValue,
      discount: calculation.discountAmount,
      taxableAmount: calculation.taxableAmount,
      taxType: calculation.taxType,
      taxValue: calculation.taxValue,
      taxAmount: calculation.taxAmount,
      totalAmount: calculation.total,
      paid: status == OrderStatus.completed ? calculation.amountPaid : 0,
      amountReceived:
          status == OrderStatus.completed ? calculation.amountPaid : 0,
      amountApplied: status == OrderStatus.completed ? calculation.total : 0,
      change: status == OrderStatus.completed ? calculation.change : 0,
      paymentMethod:
          status == OrderStatus.completed ? paymentMethod : 'pending',
      paidAt: status == OrderStatus.completed ? now : null,
      createdAt: now,
      createdBy: actor?.id ?? '',
      createdByName: actor?.name ?? '',
      customerId: customerId ?? source?.customerId,
      customerName: customerName ?? source?.customerName,
      notes: notes.isEmpty ? source?.notes ?? '' : notes,
      status: status,
      receiptStatus: receiptStatus,
      sourceOrderId: source?.id,
    );
    try {
      final result = status == OrderStatus.completed
          ? await repository
              .completeSale(order.copyWith(status: OrderStatus.draft))
          : await repository.saveOpenOrder(order);
      if (!result.isSuccess) {
        _showOperationError(result.message ?? 'The order could not be saved.');
        return null;
      }
      clearCart();
      await refreshData();
      if (print && result.value != null) {
        await printReceipt(result.value!);
      }
      if (Get.context != null) {
        Get.snackbar(
            status == OrderStatus.completed
                ? 'Payment complete'
                : 'Order saved',
            order.orderId,
            snackPosition: SnackPosition.BOTTOM);
      }
      return result.value;
    } finally {
      processingOrder.value = false;
    }
  }

  Future<void> printReceipt(OrderModel order) async {
    try {
      await printer.printOrder(order);
      await repository.updateReceiptStatus(order.id, ReceiptState.printed);
    } catch (_) {
      await repository.updateReceiptStatus(order.id, ReceiptState.failed);
      _showOperationError(
          'The sale was saved, but the receipt preview could not be opened.');
    }
    await refreshData();
  }

  void _showOperationError(String message) {
    if (Get.context == null) return;
    Get.snackbar(
      'Order not changed',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> resumeOpenOrder(OrderModel order) async {
    if (!can(AppPermission.resumeOrder)) {
      return _showOperationError('Your role cannot resume orders.');
    }
    if (!OrderStatus.open.contains(order.status)) return;
    if (cart.isNotEmpty) {
      _showOperationError(
          'Clear or save the current cart before resuming another order.');
      return;
    }
    cart.assignAll(
        order.items.map((item) => CartItemModel.fromMap(item.toMap())));
    setDiscount(order.discountType, order.discountValue);
    setTax(order.taxType, order.taxValue);
    resumedOrder.value = order;
    selectSection('Checkout');
  }

  Future<void> cancelOpenOrder(String id, String reason) async {
    final result = await repository.cancelOpenOrder(id, reason);
    if (!result.isSuccess) return _showOperationError(result.message!);
    await refreshData();
  }

  Future<void> refundOrder(String id, String reason) async {
    if (processingOrder.value) return;
    processingOrder.value = true;
    try {
      final result = await repository.refundSale(id, reason);
      if (!result.isSuccess) return _showOperationError(result.message!);
      await refreshData();
      if (Get.context != null) {
        Get.snackbar('Refund completed', 'Stock was restored exactly once.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      processingOrder.value = false;
    }
  }

  Future<void> saveProduct(
      {String? id,
      required String name,
      required String categoryId,
      required double price,
      required int stock,
      required int threshold,
      required String sku,
      String imageBase64 = '',
      String imageMimeType = '',
      String imageName = ''}) async {
    final category = categories.firstWhere((item) => item.id == categoryId);
    if (id == null) {
      await repository.addProduct(
          name: name,
          categoryId: categoryId,
          categoryName: category.name,
          variants: [MenuVariant(size: 'Regular', price: price)],
          sku: sku,
          stock: stock,
          lowStockThreshold: threshold,
          imageBase64: imageBase64,
          imageMimeType: imageMimeType,
          imageName: imageName);
    } else {
      final current = products.firstWhere((item) => item.id == id);
      await repository.updateProduct(current.copyWith(
          name: name,
          categoryId: categoryId,
          categoryName: category.name,
          variants: [MenuVariant(size: 'Regular', price: price)],
          stock: stock,
          lowStockThreshold: threshold,
          sku: sku,
          imageBase64: imageBase64,
          imageMimeType: imageMimeType,
          imageName: imageName));
    }
    await refreshData();
  }

  Future<void> deleteProduct(String id) async {
    cart.removeWhere((item) => item.id == id);
    await repository.deleteProduct(id);
    await refreshData();
  }

  Future<void> setStock(MenuItemModel product, int stock) async {
    await repository.updateProduct(product.copyWith(stock: stock));
    await refreshData();
  }

  Future<void> saveCategory(
      {String? id, required String name, required String iconName}) async {
    if (id == null) {
      await repository.addCategory(name, iconName: iconName);
    } else {
      await repository.updateCategory(id, name, iconName: iconName);
    }
    await refreshData();
  }

  Future<void> deleteCategory(String id) async {
    if (products.any((p) => p.categoryId == id)) {
      throw StateError('Move or delete products in this category first.');
    }
    await repository.deleteCategory(id);
    await refreshData();
  }

  Future<void> saveCustomer({
    String? id,
    required String name,
    required String email,
    String phone = '',
    String whatsapp = '',
    String address = '',
    String notes = '',
  }) async {
    if (id == null) {
      await repository.createCustomer(
        CustomerModel(
          name: name.trim(),
          membershipId: '',
          phone: phone.trim(),
          normalizedPhone: '',
          whatsapp: whatsapp.trim(),
          normalizedWhatsapp: '',
          email: email.trim(),
          address: address.trim(),
          notes: notes.trim(),
          createdAt: DateTime.now(),
        ),
      );
    } else {
      final existing = await repository.getCustomerById(id);

      if (existing == null) {
        throw StateError('Customer was not found.');
      }

      await repository.updateCustomer(
        existing.copyWith(
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          whatsapp: whatsapp.trim(),
          address: address.trim(),
          notes: notes.trim(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    await refreshData();
  }

  int loyaltyBalanceFor(String customerId) {
    return loyaltyBalances[customerId] ?? 0;
  }

  Future<List<LoyaltyLedgerEntry>> loyaltyLedgerFor(
    String customerId,
  ) {
    return loyaltyRepository.getLedger(
      customerId: customerId,
    );
  }

  Future<void> deleteCustomer(String id) async {
    final result = await repository.deleteCustomer(id);

    if (!result.isSuccess) {
      _showOperationError(
        result.message ?? 'Customer could not be deleted.',
      );
      return;
    }

    await refreshData();
  }

  Future<void> deleteOrder(String id) async {
    final result = await repository.deleteOpenOrder(id);
    if (!result.isSuccess) return _showOperationError(result.message!);
    await refreshData();
  }

  Future<void> softDeleteOrder(String id, String reason) async {
    final result = await repository.softDeleteOrder(id, reason);
    if (!result.isSuccess) return _showOperationError(result.message!);
    await refreshData();
  }

  Future<void> restoreOrder(String id) async {
    final result = await repository.restoreOrder(id);
    if (!result.isSuccess) return _showOperationError(result.message!);
    await refreshData();
  }

  int get unreadNotificationCount =>
      notifications.where((item) => !item.isRead).length;
  List<LocalNotificationModel> get latestNotifications =>
      notifications.take(5).toList();
  List<LocalNotificationModel> get filteredNotifications =>
      notificationFilter.value == 'Unread'
          ? notifications.where((item) => !item.isRead).toList()
          : notifications;

  Future<void> markNotification(
      LocalNotificationModel notification, bool isRead) async {
    await repository.markNotificationRead(notification.id, isRead: isRead);
    await refreshData();
  }

  Future<void> markAllNotificationsRead() async {
    await repository.markAllNotificationsRead();
    await refreshData();
  }

  Future<void> openNotification(LocalNotificationModel notification) async {
    await markNotification(notification, true);
    final destination = WorkspaceRouteMetadata.tryFromRoute(notification.route);
    if (destination != null && canOpenDestination(destination)) {
      selectSection(destination.title);
    }
  }

  List<OrderModel> get filteredOrders => switch (orderFilter.value) {
        'Held' => orders.where((o) => o.status == OrderStatus.held).toList(),
        'Saved' => orders.where((o) => o.status == OrderStatus.saved).toList(),
        'Completed' =>
          orders.where((o) => o.status == OrderStatus.completed).toList(),
        'Cancelled' =>
          orders.where((o) => o.status == OrderStatus.cancelled).toList(),
        _ => orders,
      };

  Future<void> saveExpense(
      {String? id,
      required String title,
      required double amount,
      required String category}) async {
    await repository.saveExpense(ExpenseModel(
        id: id ?? 'expense-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        amount: amount,
        category: category,
        createdAt: DateTime.now()));
    await refreshData();
  }

  Future<void> deleteExpense(String id) async {
    await repository.deleteExpense(id);
    await refreshData();
  }

  List<MenuItemModel> get inventoryAlerts =>
      products.where((p) => p.stock <= p.lowStockThreshold).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));
  List<OrderModel> get todayOrders => orders.where((o) {
        final n = DateTime.now();
        return o.createdAt.year == n.year &&
            o.createdAt.month == n.month &&
            o.createdAt.day == n.day &&
            o.status == OrderStatus.completed;
      }).toList();
  List<OrderModel> get yesterdayOrders => orders.where((o) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        return o.createdAt.year == yesterday.year &&
            o.createdAt.month == yesterday.month &&
            o.createdAt.day == yesterday.day &&
            o.status == OrderStatus.completed;
      }).toList();
  List<OrderModel> ordersForRange(String range) {
    final completed =
        orders.where((order) => order.status == OrderStatus.completed);
    if (range == 'All time') return completed.toList();
    if (range == '7 days') {
      final start = DateTime.now().subtract(const Duration(days: 7));
      return completed
          .where((order) => order.createdAt.isAfter(start))
          .toList();
    }
    return todayOrders;
  }

  List<OrderModel> receiptOrdersForRange(String range) {
    if (range == 'All time') return orders.toList();
    if (range == '7 days') {
      final start = DateTime.now().subtract(const Duration(days: 7));
      return orders.where((order) => order.createdAt.isAfter(start)).toList();
    }
    final now = DateTime.now();
    return orders
        .where((order) =>
            order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day)
        .toList();
  }

  double get todaySales =>
      todayOrders.fold(0, (sum, order) => sum + order.totalAmount);
  double get yesterdaySales =>
      yesterdayOrders.fold(0, (sum, order) => sum + order.totalAmount);
  double salesTotalForRange(String range) =>
      ordersForRange(range).fold(0, (sum, order) => sum + order.totalAmount);
  int itemsSoldForRange(String range) => ordersForRange(range)
      .expand((order) => order.items)
      .fold(0, (sum, item) => sum + item.quantity);
  double get salesChangePercent {
    if (yesterdaySales == 0) return todaySales == 0 ? 0 : 100;
    return (todaySales - yesterdaySales) / yesterdaySales * 100;
  }

  int get itemsSold => todayOrders
      .expand((order) => order.items)
      .fold(0, (sum, item) => sum + item.quantity);
  int receiptCount(String status) =>
      orders.where((o) => o.receiptStatus == status).length;
  int receiptCountForRange(String status, String range) =>
      receiptOrdersForRange(range)
          .where((order) => order.receiptStatus == status)
          .length;
  List<ProductSale> get topProducts {
    final quantities = <String, ProductSale>{};
    for (final order
        in orders.where((o) => o.status == OrderStatus.completed)) {
      for (final item in order.items) {
        final old = quantities[item.id];
        quantities[item.id] =
            ProductSale(item.name, (old?.quantity ?? 0) + item.quantity);
      }
    }
    final values = quantities.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    return values.take(5).toList();
  }
}
