import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import '../../../../models/role_permission.dart';
import '../../../data/models/customer_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/core/services/product_image_service.dart';
import '../../../../utils/rupiah_formatter.dart';
import '../../../shared/forms/form_validators.dart';
import '../../../shared/widgets/malprax_form_field.dart';
import '../../../shared/widgets/malprax_panel.dart';
import '../../../shared/widgets/malprax_table.dart';
import '../../../shared/widgets/category_icon_picker.dart';
import '../../../shared/widgets/product_image_field.dart';
import '../../../shared/widgets/product_visual.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/category_icon_registry.dart';
import '../controllers/workspace_controller.dart';

class CrudSection extends GetView<WorkspaceController> {
  const CrudSection({super.key, required this.section});
  final String section;

  @override
  Widget build(BuildContext context) => switch (section) {
        'Products' => _products(context),
        'Inventory' => _inventory(context),
        'Customers' => _customers(context),
        'Orders' => _orders(context),
        'Expenses' => _expenses(context),
        'Notifications' => _notifications(context),
        'Trash' => _trash(context),
        _ => const SizedBox.shrink(),
      };

  Widget _header(
          String title, String action, VoidCallback onPressed, Widget body,
          {VoidCallback? secondary, String? secondaryLabel}) =>
      MalpraxPanel(
        title: title,
        trailing: Wrap(spacing: 8, children: [
          if (secondary != null)
            OutlinedButton.icon(
                onPressed: secondary,
                icon: const Icon(Icons.category_outlined),
                label: Text(secondaryLabel!)),
          FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(action)),
        ]),
        child: body,
      );

  Widget _products(BuildContext context) => Obx(() => _header(
        'Product Management',
        'Add Product',
        () => _productDialog(context),
        MalpraxTable(
            columns: const [
              'Product',
              'SKU',
              'Category',
              'Price',
              'Stock',
              'Actions'
            ],
            rows: controller.products
                .map((product) => [
                      Row(children: [
                        ProductVisual(
                          product: product,
                          category: controller.categories
                              .where((c) => c.id == product.categoryId)
                              .firstOrNull,
                          size: 38,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                            child: Text(product.name,
                                maxLines: 2, overflow: TextOverflow.ellipsis)),
                      ]),
                      Text(product.sku),
                      Text(product.categoryName ?? '—'),
                      Text(RupiahFormatter.format(
                          product.variants.firstOrNull?.price ?? 0)),
                      Text('${product.stock}'),
                      _actions(
                          onEdit: () => _productDialog(context, product),
                          onDelete: () => _confirm(
                              context,
                              'Delete product?',
                              product.name,
                              () => controller.deleteProduct(product.id))),
                    ])
                .toList()),
        secondary: () => _categoryDialog(context),
        secondaryLabel: 'Categories',
      ));

  Widget _inventory(BuildContext context) => Obx(() => _header(
        'Inventory Control',
        'New Product',
        () => _productDialog(context),
        MalpraxTable(
            columns: const [
              'Product',
              'SKU',
              'Stock',
              'Threshold',
              'Status',
              'Actions'
            ],
            rows: controller.products
                .map((product) => [
                      Row(children: [
                        ProductVisual(
                          product: product,
                          category: controller.categories
                              .where((c) => c.id == product.categoryId)
                              .firstOrNull,
                          size: 36,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                            child: Text(product.name,
                                overflow: TextOverflow.ellipsis)),
                      ]),
                      Text(product.sku),
                      Text('${product.stock}'),
                      Text('${product.lowStockThreshold}'),
                      Text(
                          product.stock == 0
                              ? 'Out of stock'
                              : product.stock <= product.lowStockThreshold
                                  ? 'Low stock'
                                  : 'Healthy',
                          style: TextStyle(
                              color: product.stock <= product.lowStockThreshold
                                  ? AppColors.warning
                                  : AppColors.success)),
                      Wrap(children: [
                        IconButton(
                            tooltip: 'Adjust stock',
                            onPressed: () => _stockDialog(context, product),
                            icon: const Icon(Icons.tune)),
                        IconButton(
                            tooltip: 'Edit product',
                            onPressed: () => _productDialog(context, product),
                            icon: const Icon(Icons.edit_outlined))
                      ]),
                    ])
                .toList()),
      ));

  Widget _customers(BuildContext context) => Obx(() => _header(
        'Customer Directory',
        'Add Customer',
        () => _customerDialog(context),
        MalpraxTable(
            columns: const ['Name', 'Email', 'Role', 'Status', 'Actions'],
            rows: controller.customers
                .map((customer) => [
                      Text(customer.name),
                      Text(customer.email),
                      Text(customer.membershipId),
                      Text(customer.phone.trim().isEmpty
                          ? 'No phone'
                          : customer.phone),
                      _actions(
                          onEdit: () => _customerDialog(context, customer),
                          onDelete: () => _confirm(
                              context,
                              'Delete customer?',
                              customer.name,
                              () => controller.deleteCustomer(customer.id))),
                    ])
                .toList()),
      ));

  Widget _orders(BuildContext context) => Obx(() => _header(
        'Order History',
        'New Sale',
        () => controller.selectSection('Checkout'),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ['All', 'Held', 'Saved', 'Completed', 'Cancelled']
                .map((filter) => ChoiceChip(
                      key: ValueKey('order-filter-${filter.toLowerCase()}'),
                      label: Text(filter),
                      selected: controller.orderFilter.value == filter,
                      onSelected: (_) => controller.orderFilter.value = filter,
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          MalpraxTable(
              columns: const [
                'Order',
                'Date',
                'Items',
                'Total',
                'Status',
                'Actions'
              ],
              rows: controller.filteredOrders
                  .map((order) => [
                        Text(order.orderId),
                        Text(DateFormat('dd MMM yyyy, HH:mm')
                            .format(order.createdAt)),
                        Text(
                            '${order.items.fold(0, (sum, item) => sum + item.quantity)}'),
                        Text(RupiahFormatter.format(order.totalAmount)),
                        Text(order.status.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: order.status == OrderStatus.refunded ||
                                        order.status == OrderStatus.cancelled
                                    ? AppColors.danger
                                    : order.status == OrderStatus.completed
                                        ? AppColors.success
                                        : AppColors.warning)),
                        Wrap(children: [
                          IconButton(
                              tooltip: 'View order details',
                              onPressed: () =>
                                  _orderDetailDialog(context, order),
                              icon: const Icon(Icons.info_outline)),
                          if (order.status == OrderStatus.completed ||
                              order.status == OrderStatus.refunded)
                            IconButton(
                                tooltip: 'Print receipt',
                                onPressed: () =>
                                    controller.printer.printOrder(order),
                                icon: const Icon(Icons.print_outlined)),
                          if (OrderStatus.open.contains(order.status) &&
                              controller.can(AppPermission.resumeOrder)) ...[
                            IconButton(
                                tooltip: 'Resume order',
                                onPressed: () =>
                                    controller.resumeOpenOrder(order),
                                icon: const Icon(Icons.play_arrow_rounded)),
                            IconButton(
                                tooltip: 'Cancel open order',
                                onPressed: () =>
                                    _cancelOrderDialog(context, order),
                                icon: const Icon(Icons.cancel_outlined,
                                    color: AppColors.warning)),
                          ],
                          if (order.status == OrderStatus.completed &&
                              !order.stockRestored &&
                              controller
                                  .can(AppPermission.refundCompletedOrder))
                            IconButton(
                                tooltip: 'Refund sale',
                                onPressed: () =>
                                    _refundDialog(context, order.id),
                                icon: const Icon(Icons.currency_exchange,
                                    color: AppColors.danger)),
                          if (controller.can(AppPermission.softDeleteOrder))
                            IconButton(
                                tooltip: 'Move order to Trash',
                                onPressed: () =>
                                    _softDeleteDialog(context, order),
                                icon: const Icon(
                                    Icons.restore_from_trash_outlined,
                                    color: AppColors.danger)),
                        ]),
                      ])
                  .toList()),
        ]),
      ));

  Future<void> _cancelOrderDialog(
      BuildContext context, OrderModel order) async {
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Open Order'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  '${order.orderId} will remain in history. Stock will not change.'),
              const SizedBox(height: AppSpacing.md),
              MalpraxFormField(
                key: const ValueKey('cancellation-reason'),
                controller: reason,
                label: 'Cancellation Reason',
                hint: 'Example: Customer changed their mind',
                maxLines: 3,
                validator: (value) =>
                    FormValidators.required(value, 'Cancellation reason'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          FilledButton(
            key: const ValueKey('confirm-order-cancellation'),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await controller.cancelOpenOrder(order.id, reason.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    reason.dispose();
  }

  Future<void> _softDeleteDialog(BuildContext context, OrderModel order) async {
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Order to Trash'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${order.orderId} can be restored later by an Owner.'),
              const SizedBox(height: AppSpacing.md),
              MalpraxFormField(
                key: const ValueKey('soft-delete-reason'),
                controller: reason,
                label: 'Reason',
                hint: 'Example: Duplicate record',
                maxLines: 3,
                validator: (value) =>
                    FormValidators.required(value, 'Delete reason'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          FilledButton(
            key: const ValueKey('confirm-move-to-trash'),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await controller.softDeleteOrder(order.id, reason.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    reason.dispose();
  }

  Future<void> _orderDetailDialog(BuildContext context, OrderModel order) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(order.orderId),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _detail('Status', order.status.toUpperCase()),
                    _detail('Customer', order.customerName ?? 'Not assigned'),
                    _detail('Notes', order.notes.isEmpty ? '—' : order.notes),
                    _detail(
                        'Payment method', order.paymentMethod.toUpperCase()),
                    _detail('Amount received',
                        RupiahFormatter.format(order.amountReceived)),
                    _detail('Amount applied',
                        RupiahFormatter.format(order.amountApplied)),
                    _detail('Change', RupiahFormatter.format(order.change)),
                    if (order.cancellationReason != null)
                      _detail('Cancellation reason', order.cancellationReason!),
                    if (order.refundReason != null)
                      _detail('Refund reason', order.refundReason!),
                  ]),
            ),
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      );

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 132,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(value)),
        ]),
      );

  Widget _notifications(BuildContext context) => Obx(() => MalpraxPanel(
        title: 'All Notifications',
        trailing: TextButton.icon(
          key: const ValueKey('mark-all-notifications-read'),
          onPressed: controller.unreadNotificationCount == 0
              ? null
              : controller.markAllNotificationsRead,
          icon: const Icon(Icons.done_all),
          label: const Text('Mark all read'),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'All', label: Text('All')),
              ButtonSegment(value: 'Unread', label: Text('Unread')),
            ],
            selected: {controller.notificationFilter.value},
            onSelectionChanged: (value) =>
                controller.notificationFilter.value = value.first,
          ),
          const SizedBox(height: AppSpacing.md),
          if (controller.filteredNotifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: Text('No notifications in this filter.')),
            )
          else
            ...controller.filteredNotifications.map((notification) => Container(
                  key: ValueKey('notification-${notification.id}'),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  color: notification.isRead
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: .08),
                  child: ListTile(
                    leading: Icon(_notificationIcon(notification.type),
                        color: notification.severity == 'warning'
                            ? AppColors.warning
                            : notification.severity == 'success'
                                ? AppColors.success
                                : AppColors.primary),
                    title: Text(notification.title),
                    subtitle: Text(
                        '${notification.message}\n${notification.actorName} · ${DateFormat('dd MMM, HH:mm').format(notification.createdAt)}'),
                    isThreeLine: true,
                    onTap: () => controller.openNotification(notification),
                    trailing: IconButton(
                      tooltip: notification.isRead
                          ? 'Mark as unread'
                          : 'Mark as read',
                      onPressed: () => controller.markNotification(
                          notification, !notification.isRead),
                      icon: Icon(notification.isRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.done),
                    ),
                  ),
                )),
        ]),
      ));

  IconData _notificationIcon(String type) => switch (type) {
        'lowStock' || 'outOfStock' => Icons.inventory_2_outlined,
        'transactionCompleted' => Icons.check_circle_outline,
        'transactionRefunded' => Icons.currency_exchange,
        'recordSoftDeleted' => Icons.restore_from_trash_outlined,
        _ => Icons.notifications_outlined,
      };

  Widget _trash(BuildContext context) => Obx(() => MalpraxPanel(
        title: 'Owner Trash',
        child: controller.trashOrders.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: Text('Trash is empty.')),
              )
            : MalpraxTable(
                columns: const [
                  'Entity',
                  'Record',
                  'Deleted',
                  'Deleted By',
                  'Reason',
                  'Action'
                ],
                rows: controller.trashOrders
                    .map((order) => [
                          const Text('Order'),
                          Text(order.orderId),
                          Text(order.deletedAt == null
                              ? '—'
                              : DateFormat('dd MMM yyyy, HH:mm')
                                  .format(order.deletedAt!)),
                          Text(order.deletedBy ?? '—'),
                          Text(order.deleteReason ?? '—'),
                          FilledButton.icon(
                            key: ValueKey('restore-order-${order.id}'),
                            onPressed: () => controller.restoreOrder(order.id),
                            icon: const Icon(Icons.restore),
                            label: const Text('Restore'),
                          ),
                        ])
                    .toList(),
              ),
      ));

  Future<void> _refundDialog(BuildContext context, String orderId) async {
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Refund completed sale'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                  'Returned products will be added back to stock exactly once.'),
              const SizedBox(height: 12),
              MalpraxFormField(
                controller: reason,
                label: 'Refund Reason',
                hint: 'Example: Customer returned sealed goods',
                helperText: 'This reason is stored in the local order history.',
                autofocus: true,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    FormValidators.required(value, 'Refund reason'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Sale')),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await controller.refundOrder(orderId, reason.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    reason.dispose();
  }

  Widget _expenses(BuildContext context) => Obx(() => _header(
        'Expense Management',
        'Add Expense',
        () => _expenseDialog(context),
        MalpraxTable(
            columns: const [
              'Description',
              'Category',
              'Date',
              'Amount',
              'Actions'
            ],
            rows: controller.expenses
                .map((expense) => [
                      Text(expense.title),
                      Text(expense.category),
                      Text(DateFormat('dd MMM yyyy').format(expense.createdAt)),
                      Text(RupiahFormatter.format(expense.amount)),
                      _actions(
                          onEdit: () => _expenseDialog(context, expense.id,
                              expense.title, expense.amount, expense.category),
                          onDelete: () => _confirm(
                              context,
                              'Delete expense?',
                              expense.title,
                              () => controller.deleteExpense(expense.id))),
                    ])
                .toList()),
      ));

  Widget _actions(
          {required VoidCallback onEdit, required VoidCallback onDelete}) =>
      Wrap(children: [
        IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined)),
        IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger))
      ]);

  Future<void> _confirm(BuildContext context, String title, String detail,
      Future<void> Function() action) async {
    final yes = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
                    title: Text(title),
                    content: Text(detail),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'))
                    ])) ??
        false;
    if (yes) await action();
  }

  Future<void> _productDialog(BuildContext context,
      [MenuItemModel? product]) async {
    final name = TextEditingController(text: product?.name ?? '');
    final sku = TextEditingController(text: product?.sku ?? '');
    final price = TextEditingController(
        text: '${product?.variants.firstOrNull?.price ?? ''}');
    final stock = TextEditingController(text: '${product?.stock ?? 10}');
    final threshold =
        TextEditingController(text: '${product?.lowStockThreshold ?? 5}');
    final formKey = GlobalKey<FormState>();
    var categoryId =
        product?.categoryId ?? controller.categories.firstOrNull?.id;
    var imageBase64 = product?.imageBase64 ?? '';
    var imageMimeType = product?.imageMimeType ?? '';
    var imageName = product?.imageName ?? '';
    var processingImage = false;
    String? imageError;
    final imageService = ProductImageService();
    await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                    title:
                        Text(product == null ? 'Add Product' : 'Edit Product'),
                    content: SizedBox(
                        width: 560,
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                MalpraxFormField(
                                    key: const ValueKey('product-name-field'),
                                    controller: name,
                                    label: 'Product Name',
                                    hint: 'Example: Mineral Water 600ml',
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        FormValidators.required(
                                            value, 'Product name')),
                                const SizedBox(height: 10),
                                MalpraxFormField(
                                    key: const ValueKey('product-sku-field'),
                                    controller: sku,
                                    label: 'SKU',
                                    hint: 'Example: WATER600',
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        FormValidators.required(value, 'SKU') ??
                                        (controller.products.any((item) =>
                                                item.id != product?.id &&
                                                item.sku.toLowerCase() ==
                                                    value?.trim().toLowerCase())
                                            ? 'SKU must be unique.'
                                            : null)),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                    initialValue: categoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      hintText: 'Example: Beverages',
                                      helperText:
                                          'Choose where this product appears.',
                                    ),
                                    items: controller.categories
                                        .map((c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Row(children: [
                                              Icon(
                                                  CategoryIconRegistry.iconFor(
                                                      c.iconName),
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(c.name),
                                            ])))
                                        .toList(),
                                    onChanged: (value) =>
                                        setState(() => categoryId = value),
                                    validator: (value) => value == null
                                        ? 'Category is required.'
                                        : null),
                                const SizedBox(height: 10),
                                ProductImageField(
                                  product: MenuItemModel(
                                    id: product?.id ?? 'product-preview',
                                    name: name.text.trim().isEmpty
                                        ? 'Product preview'
                                        : name.text.trim(),
                                    categoryId: categoryId ?? '',
                                    variants: [
                                      MenuVariant(
                                          size: 'Regular',
                                          price:
                                              double.tryParse(price.text) ?? 0)
                                    ],
                                    imageBase64: imageBase64,
                                    imageMimeType: imageMimeType,
                                    imageName: imageName,
                                  ),
                                  category: controller.categories
                                      .where((c) => c.id == categoryId)
                                      .firstOrNull,
                                  processing: processingImage,
                                  errorMessage: imageError,
                                  onChoose: () async {
                                    setState(() {
                                      processingImage = true;
                                      imageError = null;
                                    });
                                    final result =
                                        await imageService.pickFromGallery();
                                    if (!context.mounted) return;
                                    setState(() {
                                      processingImage = false;
                                      if (result.success) {
                                        imageBase64 = result.imageBase64;
                                        imageMimeType = result.mimeType;
                                        imageName = result.fileName;
                                      } else if (!result.cancelled) {
                                        imageError = result.errorMessage;
                                      }
                                    });
                                  },
                                  onRemove: () => setState(() {
                                    imageBase64 = '';
                                    imageMimeType = '';
                                    imageName = '';
                                    imageError = null;
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(
                                      child: MalpraxFormField(
                                          controller: price,
                                          label: 'Price',
                                          hint: 'Example: 7500',
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.next,
                                          validator: (value) =>
                                              FormValidators.positiveNumber(
                                                  value, 'Price'))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: MalpraxFormField(
                                          controller: stock,
                                          label: 'Stock Quantity',
                                          hint: 'Example: 24',
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) =>
                                              FormValidators.nonNegativeNumber(
                                                  value, 'Stock quantity'))),
                                ]),
                                const SizedBox(height: 10),
                                MalpraxFormField(
                                    controller: threshold,
                                    label: 'Low Stock Alert',
                                    hint: 'Example: 5',
                                    helperText:
                                        'An inventory alert appears at or below this quantity.',
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    validator: (value) =>
                                        FormValidators.nonNegativeNumber(
                                            value, 'Low stock alert')),
                              ])),
                        )),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: categoryId == null
                              ? null
                              : () async {
                                  if (!(formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  await controller.saveProduct(
                                      id: product?.id,
                                      name: name.text.trim(),
                                      categoryId: categoryId!,
                                      price: double.tryParse(price.text) ?? 0,
                                      stock: int.tryParse(stock.text) ?? 0,
                                      threshold:
                                          int.tryParse(threshold.text) ?? 5,
                                      sku: sku.text.trim(),
                                      imageBase64: imageBase64,
                                      imageMimeType: imageMimeType,
                                      imageName: imageName);
                                  if (context.mounted) Navigator.pop(context);
                                },
                          child: const Text('Save'))
                    ])));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    sku.dispose();
    price.dispose();
    stock.dispose();
    threshold.dispose();
  }

  Future<void> _stockDialog(BuildContext context, MenuItemModel product) async {
    final value = TextEditingController(text: '${product.stock}');
    final formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text('Adjust ${product.name}'),
                content: Form(
                  key: formKey,
                  child: MalpraxFormField(
                      controller: value,
                      label: 'Stock Quantity',
                      hint: 'Example: 24',
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (input) => FormValidators.nonNegativeNumber(
                          input, 'Stock quantity')),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        await controller.setStock(
                            product, int.tryParse(value.text) ?? product.stock);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Update'))
                ]));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    value.dispose();
  }

  Future<void> _customerDialog(BuildContext context,
      [CustomerModel? customer]) async {
    final name = TextEditingController(text: customer?.name ?? '');
    final email = TextEditingController(text: customer?.email ?? '');
    final formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title:
                    Text(customer == null ? 'Add Customer' : 'Edit Customer'),
                content: SizedBox(
                    width: 420,
                    child: Form(
                        key: formKey,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          MalpraxFormField(
                              key: const ValueKey('customer-name-field'),
                              controller: name,
                              label: 'Customer Name',
                              hint: 'Example: Andi Pratama',
                              textInputAction: TextInputAction.next,
                              validator: (value) => FormValidators.required(
                                  value, 'Customer name')),
                          const SizedBox(height: 10),
                          MalpraxFormField(
                              key: const ValueKey('customer-email-field'),
                              controller: email,
                              label: 'Email',
                              hint: 'Example: andi@example.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: FormValidators.email)
                        ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        await controller.saveCustomer(
                            id: customer?.id,
                            name: name.text.trim(),
                            email: email.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'))
                ]));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    email.dispose();
  }

  Future<void> _expenseDialog(BuildContext context,
      [String? id,
      String titleValue = '',
      double amountValue = 0,
      String categoryValue = 'Operations']) async {
    final title = TextEditingController(text: titleValue);
    final amount =
        TextEditingController(text: amountValue == 0 ? '' : '$amountValue');
    final category = TextEditingController(text: categoryValue);
    final formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text(id == null ? 'Add Expense' : 'Edit Expense'),
                content: SizedBox(
                    width: 420,
                    child: Form(
                        key: formKey,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          MalpraxFormField(
                              key: const ValueKey('expense-description-field'),
                              controller: title,
                              label: 'Description',
                              hint: 'Example: Purchase of packaging materials',
                              textInputAction: TextInputAction.next,
                              validator: (value) => FormValidators.required(
                                  value, 'Description')),
                          const SizedBox(height: 10),
                          MalpraxFormField(
                              controller: category,
                              label: 'Category',
                              hint: 'Example: Operations',
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  FormValidators.required(value, 'Category')),
                          const SizedBox(height: 10),
                          MalpraxFormField(
                              key: const ValueKey('expense-amount-field'),
                              controller: amount,
                              label: 'Amount',
                              hint: 'Example: 150000',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textInputAction: TextInputAction.done,
                              validator: (value) =>
                                  FormValidators.positiveNumber(
                                      value, 'Amount'))
                        ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        await controller.saveExpense(
                            id: id,
                            title: title.text.trim(),
                            amount: double.tryParse(amount.text) ?? 0,
                            category: category.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'))
                ]));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    title.dispose();
    amount.dispose();
    category.dispose();
  }

  Future<void> _categoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manage Categories'),
        content: SizedBox(
          width: 420,
          child: Obx(() => ListView(
                shrinkWrap: true,
                children: controller.categories
                    .map((category) => ListTile(
                          leading: Icon(
                              CategoryIconRegistry.iconFor(category.iconName)),
                          title: Text(category.name),
                          trailing: Wrap(children: [
                            IconButton(
                                onPressed: () =>
                                    _categoryEditor(context, category),
                                icon: const Icon(Icons.edit_outlined)),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await controller.deleteCategory(category.id);
                                } catch (error) {
                                  Get.snackbar('Category cannot be deleted',
                                      error.toString());
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ]),
                        ))
                    .toList(),
              )),
        ),
        actions: [
          TextButton.icon(
              onPressed: () => _categoryEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category')),
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  Future<void> _categoryEditor(BuildContext context,
      [CategoryModel? category]) async {
    final name = TextEditingController(text: category?.name ?? '');
    final formKey = GlobalKey<FormState>();
    var iconName = category?.iconName ?? 'other';
    await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                    title: Text(
                        category == null ? 'Add Category' : 'Edit Category'),
                    content: Form(
                      key: formKey,
                      child: SizedBox(
                        width: 430,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          MalpraxFormField(
                              key: const ValueKey('category-name-field'),
                              controller: name,
                              label: 'Category Name',
                              hint: 'Example: Beverages',
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) => FormValidators.required(
                                  value, 'Category name')),
                          const SizedBox(height: AppSpacing.lg),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Category Icon',
                                style: Theme.of(context).textTheme.labelLarge),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Choose an icon that represents this category',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ListTile(
                            key: const ValueKey('category-icon-preview'),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: CircleAvatar(
                              child:
                                  Icon(CategoryIconRegistry.iconFor(iconName)),
                            ),
                            title:
                                Text(CategoryIconRegistry.labelFor(iconName)),
                            subtitle: Text('Stored as: $iconName'),
                            trailing: const Icon(Icons.grid_view_rounded),
                            onTap: () async {
                              final selected = await showCategoryIconPicker(
                                  context,
                                  selectedName: iconName);
                              if (selected != null && context.mounted) {
                                setState(() => iconName = selected);
                              }
                            },
                          ),
                        ]),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            await controller.saveCategory(
                                id: category?.id,
                                name: name.text.trim(),
                                iconName: iconName);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Save'))
                    ])));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
  }
}
