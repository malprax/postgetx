import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';
import '../../../shared/forms/form_validators.dart';
import '../../../shared/widgets/malprax_button.dart';
import '../../../shared/widgets/malprax_form_field.dart';
import '../../../shared/widgets/malprax_panel.dart';
import '../../../shared/widgets/product_visual.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/category_icon_registry.dart';
import '../controllers/workspace_controller.dart';

class CategoryBar extends GetView<WorkspaceController> {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) => Obx(
        () => SingleChildScrollView(
          key: const ValueKey('category-bar'),
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('All Categories', '', showCheck: true),
            ...controller.categories.map((category) => _chip(
                  category.name,
                  category.id,
                  showCheck: false,
                  icon: CategoryIconRegistry.iconFor(category.iconName),
                )),
          ]),
        ),
      );

  Widget _chip(String label, String id,
          {required bool showCheck, IconData? icon}) =>
      Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: ChoiceChip(
          key: ValueKey('category-${id.isEmpty ? 'all' : id}'),
          avatar: showCheck && controller.selectedCategory.value == id
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : icon == null
                  ? null
                  : Icon(icon, size: 14),
          label: Text(label),
          selected: controller.selectedCategory.value == id,
          showCheckmark: false,
          onSelected: (_) => controller.selectCategory(id),
        ),
      );
}

class ProductGrid extends GetView<WorkspaceController> {
  const ProductGrid({super.key, this.cardExtent = 176});
  final double cardExtent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Obx(() {
          final width = constraints.maxWidth;
          final columns = width >= 880
              ? 6
              : width >= 520
                  ? 5
                  : width >= 400
                      ? 3
                      : 2;
          final products = controller.visibleProducts;
          if (products.isEmpty) {
            return MalpraxPanel(
              key: const ValueKey('product-grid-empty'),
              child: SizedBox(
                height: 108,
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.search_off_rounded,
                        color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('No matching products'),
                    TextButton(
                      onPressed: () => controller.setSearch(''),
                      child: const Text('Clear search'),
                    ),
                  ]),
                ),
              ),
            );
          }
          return Column(children: [
            GridView.builder(
              key: const ValueKey('product-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: cardExtent,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemBuilder: (_, index) => ProductCard(
                product: products[index],
                category: controller.categories
                    .where((item) => item.id == products[index].categoryId)
                    .firstOrNull,
                onTap: () => controller.addProduct(products[index]),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 31,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _PageButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Previous page',
                  onPressed: controller.page.value > 1
                      ? () => controller.setPage(controller.page.value - 1)
                      : null,
                ),
                ...List.generate(
                  controller.pageCount,
                  (index) => _PageButton(
                    label: '${index + 1}',
                    selected: controller.page.value == index + 1,
                    onPressed: () => controller.setPage(index + 1),
                  ),
                ),
                _PageButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Next page',
                  onPressed: controller.page.value < controller.pageCount
                      ? () => controller.setPage(controller.page.value + 1)
                      : null,
                ),
              ]),
            ),
          ]);
        }),
      );
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    this.label,
    this.icon,
    this.tooltip,
    this.selected = false,
    required this.onPressed,
  });
  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          width: 30,
          height: 29,
          child: IconButton(
            tooltip: tooltip ?? 'Page $label',
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor:
                  selected ? AppColors.primary : Colors.transparent,
              foregroundColor: selected ? Colors.white : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            onPressed: onPressed,
            icon: icon == null
                ? Text(label!, style: const TextStyle(fontSize: 10))
                : Icon(icon, size: 17),
          ),
        ),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard(
      {super.key, required this.product, this.category, required this.onTap});
  final MenuItemModel product;
  final CategoryModel? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final out = product.stock == 0;
    final low = product.stock <= product.lowStockThreshold;
    final stateColor = out
        ? AppColors.danger
        : low
            ? AppColors.warning
            : AppColors.success;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('product-${product.id}'),
        onTap: out ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: MalpraxPanel(
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
          child: Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Center(
                  child: ProductVisual(
                      product: product, category: category, size: 62),
                ),
              ),
              Text(product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 11)),
              const SizedBox(height: 2),
              Text(product.sku,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 9)),
              const SizedBox(height: 4),
              Text(
                product.variants.isEmpty
                    ? '—'
                    : RupiahFormatter.format(product.variants.first.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ]),
            Positioned(
              top: 0,
              right: 0,
              child: StatusBadge(
                out
                    ? 'Out of Stock'
                    : low
                        ? 'Low Stock'
                        : 'In Stock',
                color: stateColor,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class CartPanel extends GetView<WorkspaceController> {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) => Obx(
        () => MalpraxPanel(
          key: const ValueKey('cart-panel'),
          title:
              'Cart (${controller.cart.fold(0, (sum, item) => sum + item.quantity)})',
          trailing: TextButton.icon(
            key: const ValueKey('clear-cart'),
            onPressed:
                controller.cart.isEmpty || controller.processingOrder.value
                    ? null
                    : controller.clearCart,
            icon: const Icon(Icons.delete_outline_rounded, size: 15),
            label: const Text('Clear Cart'),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bounded = constraints.hasBoundedHeight;
              final items = controller.cart.isEmpty
                  ? const _CompactEmptyCart()
                  : bounded
                      ? ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: controller.cart.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) => _CartItemRow(index: index),
                        )
                      : Column(
                          children: List.generate(
                            controller.cart.length,
                            (index) => _CartItemRow(index: index),
                          ),
                        );
              final footer = Obx(() {
                final totals = controller.totals;
                return _CartFooter(
                  controller: controller,
                  totals: totals,
                  discountType: controller.discountType.value,
                  discountValue: controller.discountValue.value,
                  showDiscount: () => _showDiscountDialog(context),
                  showTax: () => _showTaxDialog(context),
                  showCashPayment: () => _showCashPaymentDialog(context),
                  showSaveOrder: () => _showSaveOrderDialog(context),
                  showMorePayments: () => _showMorePayments(context),
                );
              });
              return Column(children: [
                if (bounded) Expanded(child: items) else items,
                footer,
              ]);
            },
          ),
        ),
      );

  Future<void> _showDiscountDialog(BuildContext context) async {
    var type = controller.discountType.value;
    final value = TextEditingController(
        text: controller.discountValue.value.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Order discount'),
          content: SizedBox(
            width: 320,
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SegmentedButton<DiscountType>(
                  segments: const [
                    ButtonSegment(
                      value: DiscountType.percentage,
                      label: Text('Percentage'),
                      icon: Icon(Icons.percent_rounded),
                    ),
                    ButtonSegment(
                      value: DiscountType.fixed,
                      label: Text('Fixed'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (selection) =>
                      setState(() => type = selection.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                MalpraxFormField(
                  key: const ValueKey('discount-input'),
                  controller: value,
                  label: 'Discount',
                  hint: type == DiscountType.percentage
                      ? 'Example: 10'
                      : 'Example: 15000',
                  helperText: type == DiscountType.percentage
                      ? 'Percentage from 0 to 100'
                      : 'Fixed amount in rupiah',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  validator: (input) => FormValidators.discount(
                    input,
                    percentage: type == DiscountType.percentage,
                  ),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              key: const ValueKey('apply-discount'),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                controller.setDiscount(type, double.parse(value.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    value.dispose();
  }

  Future<void> _showCashPaymentDialog(BuildContext context) async {
    final received = TextEditingController();
    var amount = 0.0;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final total = controller.totals.total;
          final availablePoints = controller.availableCheckoutPoints;
          final selectedPoints = controller.loyaltyPointsToRedeem.value;
          final valid = amount.isFinite && amount >= total;
          final change = valid ? amount - total : 0.0;

          final quickAmounts = <double>{
            total,
            (total / 10000).ceil() * 10000,
            (total / 20000).ceil() * 20000,
            (total / 50000).ceil() * 50000,
            (total / 100000).ceil() * 100000,
          }.where((value) => value >= total).toList()
            ..sort();

          return AlertDialog(
            title: const Row(children: [
              Icon(Icons.payments_outlined),
              SizedBox(width: 10),
              Text('Cash Payment'),
            ]),
            content: SizedBox(
              width: 430,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String?>(
                        key: const ValueKey('checkout-customer-selector'),
                        initialValue:
                            controller.selectedCheckoutCustomer.value?.id,
                        decoration: const InputDecoration(
                          labelText: 'Customer (optional)',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Walk-in customer'),
                          ),
                          ...controller.customers.map(
                            (customer) => DropdownMenuItem<String?>(
                              value: customer.id,
                              child: Text(
                                '${customer.name} · '
                                '${controller.loyaltyBalanceFor(customer.id)} pts',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (customerId) {
                          final customer = controller.customers
                              .where((item) => item.id == customerId)
                              .firstOrNull;

                          setState(() {
                            controller.selectCheckoutCustomer(customer);
                          });
                        },
                      ),
                      if (controller.selectedCheckoutCustomer.value !=
                          null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          key: const ValueKey('checkout-loyalty-panel'),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Available loyalty: $availablePoints points',
                                key: const ValueKey(
                                  'checkout-available-points',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Slider(
                                key: const ValueKey(
                                  'checkout-loyalty-slider',
                                ),
                                value: selectedPoints.toDouble().clamp(
                                      0,
                                      availablePoints > 0
                                          ? availablePoints.toDouble()
                                          : 1,
                                    ),
                                min: 0,
                                max: availablePoints > 0
                                    ? availablePoints.toDouble()
                                    : 1,
                                divisions:
                                    availablePoints > 0 ? availablePoints : 1,
                                label: '$selectedPoints points',
                                onChanged: availablePoints <= 0
                                    ? null
                                    : (value) {
                                        setState(() {
                                          controller.setLoyaltyPointsToRedeem(
                                            value.round(),
                                          );
                                        });
                                      },
                              ),
                              Text(
                                '$selectedPoints points = '
                                '${RupiahFormatter.format(
                                  controller.checkoutLoyaltyDiscount,
                                )}',
                                key: const ValueKey(
                                  'checkout-selected-points',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      _PaymentSummaryLine(
                        label: 'Total Due',
                        value: total,
                        emphasized: true,
                      ),
                      if (controller.totals.loyaltyDiscount > 0)
                        _PaymentSummaryLine(
                          label: 'Loyalty Discount',
                          value: -controller.totals.loyaltyDiscount,
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      MalpraxFormField(
                        key: const ValueKey('cash-received-input'),
                        controller: received,
                        label: 'Amount Received',
                        hint: 'Example: 50000',
                        helperText: valid
                            ? 'Sufficient cash received'
                            : 'Amount must be at least the total due',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) => setState(
                            () => amount = double.tryParse(value.trim()) ?? 0),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || !parsed.isFinite) {
                            return 'Enter a valid cash amount.';
                          }
                          if (parsed < total) {
                            return 'Amount received is insufficient.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ActionChip(
                            key: const ValueKey('cash-exact-amount'),
                            label: const Text('Exact Amount'),
                            onPressed: () => setState(() {
                              amount = total;
                              received.text = total.toStringAsFixed(0);
                            }),
                          ),
                          ...quickAmounts
                              .skip(1)
                              .take(4)
                              .map((value) => ActionChip(
                                    key: ValueKey(
                                        'cash-quick-${value.toStringAsFixed(0)}'),
                                    label: Text(RupiahFormatter.format(value)),
                                    onPressed: () => setState(() {
                                      amount = value;
                                      received.text = value.toStringAsFixed(0);
                                    }),
                                  )),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color:
                              (valid ? AppColors.success : AppColors.textMuted)
                                  .withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: _PaymentSummaryLine(
                          label: valid
                              ? 'Change'
                              : 'Change calculated after sufficient cash',
                          value: change,
                          emphasized: valid,
                        ),
                      ),
                    ]),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: controller.processingOrder.value
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton.icon(
                key: const ValueKey('confirm-cash-payment'),
                onPressed: !valid || controller.processingOrder.value
                    ? null
                    : () async {
                        final completed = await controller.saveOrder(
                          print: false,
                          amountReceived: amount,
                          paymentMethod: 'cash',
                        );
                        if (context.mounted && completed != null) {
                          Navigator.pop(context);
                        }
                        if (completed != null) {
                          unawaited(controller.printReceipt(completed));
                        }
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Payment'),
              ),
            ],
          );
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    received.dispose();
  }

  Future<void> _showSaveOrderDialog(BuildContext context) async {
    final notes = TextEditingController();
    String? customerId;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Save as Open Order'),
          content: SizedBox(
            width: 430,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Save as an open order for later processing or payment.'),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String?>(
                initialValue: customerId,
                decoration:
                    const InputDecoration(labelText: 'Customer (optional)'),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('No customer')),
                  ...controller.customers.map((customer) =>
                      DropdownMenuItem<String?>(
                          value: customer.id, child: Text(customer.name))),
                ],
                onChanged: (value) => setState(() => customerId = value),
              ),
              const SizedBox(height: AppSpacing.md),
              MalpraxFormField(
                key: const ValueKey('saved-order-notes'),
                controller: notes,
                label: 'Order Notes',
                hint: 'Example: Customer will collect after 5 PM',
                maxLines: 3,
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back')),
            FilledButton(
              key: const ValueKey('confirm-save-order'),
              onPressed: () async {
                final customer = controller.customers
                    .where((item) => item.id == customerId)
                    .firstOrNull;
                await controller.saveOrder(
                  status: OrderStatus.saved,
                  receiptStatus: ReceiptState.pending,
                  customerId: customer?.id,
                  customerName: customer?.name,
                  notes: notes.text.trim(),
                );
                if (context.mounted && controller.cart.isEmpty) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Order'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    notes.dispose();
  }

  Future<void> _showTaxDialog(BuildContext context) async {
    var type = controller.taxType.value;
    final value = TextEditingController(
        text: controller.taxValue.value.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Order tax'),
          content: SizedBox(
            width: 430,
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SegmentedButton<TaxType>(
                  segments: const [
                    ButtonSegment(value: TaxType.none, label: Text('None')),
                    ButtonSegment(
                        value: TaxType.percentage,
                        label: Text('Percentage'),
                        icon: Icon(Icons.percent_rounded)),
                    ButtonSegment(
                        value: TaxType.fixedAmount,
                        label: Text('Fixed Amount'),
                        icon: Icon(Icons.payments_outlined)),
                  ],
                  selected: {type},
                  onSelectionChanged: (selection) => setState(() {
                    type = selection.first;
                    if (type == TaxType.none) value.text = '0';
                  }),
                ),
                if (type != TaxType.none) ...[
                  const SizedBox(height: AppSpacing.lg),
                  MalpraxFormField(
                    key: const ValueKey('tax-input'),
                    controller: value,
                    label: type == TaxType.percentage
                        ? 'Tax Percentage'
                        : 'Tax Amount',
                    hint: type == TaxType.percentage
                        ? 'Example: 10'
                        : 'Example: 5000',
                    helperText: type == TaxType.percentage
                        ? 'Percentage from 0 to 100'
                        : 'Fixed amount in rupiah',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (input) => FormValidators.discount(input,
                        percentage: type == TaxType.percentage),
                  ),
                ],
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              key: const ValueKey('apply-tax'),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final parsed = type == TaxType.none
                    ? 0.0
                    : double.parse(value.text.trim());
                controller.setTax(type, parsed);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    value.dispose();
  }

  Future<void> _showMorePayments(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select payment method'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _PaymentOption(
                icon: Icons.payments_outlined,
                label: 'Cash',
                onTap: () {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final appContext = Get.context;
                    if (appContext != null) {
                      _showCashPaymentDialog(appContext);
                    }
                  });
                },
              ),
              const _PaymentOption(
                icon: Icons.credit_card_rounded,
                label: 'Card — unavailable offline',
                onTap: null,
              ),
              const _PaymentOption(
                icon: Icons.qr_code_2_rounded,
                label: 'Digital payment — unavailable offline',
                onTap: null,
              ),
            ]),
          ),
        ),
      );
}

class _CompactEmptyCart extends StatelessWidget {
  const _CompactEmptyCart();

  @override
  Widget build(BuildContext context) => SizedBox(
        key: const ValueKey('empty-cart-state'),
        height: 105,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 28, color: AppColors.textMuted),
            const SizedBox(height: 6),
            const Text('Select a product to begin',
                style: TextStyle(fontSize: 11)),
            const SizedBox(height: 2),
            Text('Products are added instantly',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

class _CartItemRow extends GetView<WorkspaceController> {
  const _CartItemRow({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final item = controller.cart[index];
    final product = controller.products.firstWhere((p) => p.id == item.id);
    return SizedBox(
      height: 73,
      child: Row(children: [
        ProductVisual(
          product: product,
          category: controller.categories
              .where((item) => item.id == product.categoryId)
              .firstOrNull,
          size: 38,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(RupiahFormatter.format(item.price),
                  style:
                      const TextStyle(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ),
        _QuantityButton(
          key: ValueKey('decrease-${item.id}'),
          icon: Icons.remove_rounded,
          onPressed: () => controller.changeQuantity(item.id, -1),
        ),
        Container(
          width: 25,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Text('${item.quantity}',
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        _QuantityButton(
          key: ValueKey('increase-${item.id}'),
          icon: Icons.add_rounded,
          onPressed: () => controller.changeQuantity(item.id, 1),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 55,
          child: Text(RupiahFormatter.format(item.price * item.quantity),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          width: 28,
          child: IconButton(
            key: ValueKey('remove-${item.id}'),
            tooltip: 'Remove ${item.name}',
            padding: EdgeInsets.zero,
            onPressed: () => controller.removeCartItem(item.id),
            icon: const Icon(Icons.close_rounded,
                size: 15, color: AppColors.textMuted),
          ),
        ),
      ]),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton(
      {super.key, required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 27,
        height: 27,
        child: IconButton.outlined(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 13),
        ),
      );
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.controller,
    required this.totals,
    required this.discountType,
    required this.discountValue,
    required this.showDiscount,
    required this.showTax,
    required this.showCashPayment,
    required this.showSaveOrder,
    required this.showMorePayments,
  });
  final WorkspaceController controller;
  final PosTotals totals;
  final DiscountType discountType;
  final double discountValue;
  final VoidCallback showDiscount;
  final VoidCallback showTax;
  final VoidCallback showCashPayment;
  final VoidCallback showSaveOrder;
  final VoidCallback showMorePayments;

  @override
  Widget build(BuildContext context) => Column(children: [
        const Divider(height: 1),
        const SizedBox(height: 6),
        _line('Subtotal', totals.subtotal),
        InkWell(
          key: const ValueKey('edit-discount'),
          onTap: controller.cart.isEmpty ? null : showDiscount,
          child: _line(
            discountType == DiscountType.percentage
                ? 'Discount (${discountValue.toStringAsFixed(0)}%)'
                : 'Discount (Fixed)',
            -totals.discountAmount,
            danger: true,
            trailingIcon: Icons.edit_outlined,
          ),
        ),
        if (totals.loyaltyDiscount > 0)
          _line(
            'Loyalty (${controller.loyaltyPointsToRedeem.value} pts)',
            -totals.loyaltyDiscount,
            danger: true,
          ),
        InkWell(
          key: const ValueKey('edit-tax'),
          onTap: controller.cart.isEmpty ? null : showTax,
          child: _line(
            switch (totals.taxType) {
              TaxType.none => 'Tax (None)',
              TaxType.percentage =>
                'Tax (${totals.taxValue.toStringAsFixed(0)}%)',
              TaxType.fixedAmount => 'Tax (Fixed)',
            },
            totals.taxAmount,
            trailingIcon: Icons.edit_outlined,
          ),
        ),
        const Divider(height: 10),
        _line('Total', totals.total, total: true),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 47,
          child: MalpraxButton(
            key: const ValueKey('pay-order'),
            label: 'Pay ${RupiahFormatter.format(totals.total)}',
            onPressed:
                controller.cart.isEmpty || controller.processingOrder.value
                    ? null
                    : showCashPayment,
            filled: true,
            accent: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(
            child: Tooltip(
              message: 'Pause this cart temporarily and continue it later.',
              child: MalpraxButton(
                key: const ValueKey('hold-order'),
                label: 'Hold',
                icon: Icons.pause_circle_outline_rounded,
                onPressed:
                    controller.cart.isEmpty || controller.processingOrder.value
                        ? null
                        : () => controller.saveOrder(
                              status: OrderStatus.held,
                              receiptStatus: ReceiptState.pending,
                            ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: MalpraxButton(
              key: const ValueKey('cancel-order'),
              label: 'Cancel',
              icon: Icons.delete_outline_rounded,
              destructive: true,
              onPressed:
                  controller.cart.isEmpty || controller.processingOrder.value
                      ? null
                      : controller.cancelCart,
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(
            child: Tooltip(
              message: 'Save as an open order for later processing or payment.',
              child: MalpraxButton(
                key: const ValueKey('save-order'),
                label: 'Save as Order',
                icon: Icons.save_outlined,
                onPressed:
                    controller.cart.isEmpty || controller.processingOrder.value
                        ? null
                        : showSaveOrder,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: MalpraxButton(
              key: const ValueKey('more-payments'),
              label: 'More Payments',
              icon: Icons.add_circle_outline_rounded,
              onPressed:
                  controller.cart.isEmpty || controller.processingOrder.value
                      ? null
                      : showMorePayments,
            ),
          ),
        ]),
      ]);

  Widget _line(
    String label,
    double value, {
    bool danger = false,
    bool total = false,
    IconData? trailingIcon,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
            child: Row(children: [
              Text(label,
                  style: TextStyle(
                      fontSize: total ? 15 : 11,
                      fontWeight: total ? FontWeight.w800 : null)),
              if (trailingIcon != null) ...[
                const SizedBox(width: 4),
                Icon(trailingIcon, size: 11, color: AppColors.textMuted),
              ],
            ]),
          ),
          Text(RupiahFormatter.format(value),
              style: TextStyle(
                  fontSize: total ? 19 : 11,
                  color: danger
                      ? AppColors.danger
                      : total
                          ? AppColors.primary
                          : null,
                  fontWeight: total ? FontWeight.w800 : null)),
        ]),
      );
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: Theme.of(context).dividerColor)),
          leading: Icon(icon, color: AppColors.primary),
          title: Text(label),
          trailing: const Icon(Icons.arrow_forward_rounded, size: 17),
          onTap: onTap,
        ),
      );
}

class _PaymentSummaryLine extends StatelessWidget {
  const _PaymentSummaryLine(
      {required this.label, required this.value, this.emphasized = false});
  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight:
                        emphasized ? FontWeight.w800 : FontWeight.w500))),
        Text(RupiahFormatter.format(value),
            style: TextStyle(
                color: emphasized ? AppColors.primary : null,
                fontSize: emphasized ? 20 : 14,
                fontWeight: FontWeight.w800)),
      ]);
}

class InventoryAlerts extends GetView<WorkspaceController> {
  const InventoryAlerts({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final alerts = controller.inventoryAlerts.take(3).toList();
        return MalpraxPanel(
          key: const ValueKey('inventory-alerts'),
          title: 'Inventory Alerts',
          headerColor: AppColors.inventoryHeader,
          headerForegroundColor: Colors.white,
          trailing: const Icon(Icons.warning_amber_rounded,
              size: 17, color: Color(0xFFFFD66B)),
          child: LayoutBuilder(builder: (context, constraints) {
            final rows = alerts
                .map((product) => _InventoryAlertRow(product: product))
                .toList();
            return Column(children: [
              if (constraints.hasBoundedHeight)
                ...rows.map((row) => Expanded(child: row))
              else
                ...rows.map((row) => SizedBox(height: 52, child: row)),
              if (alerts.isEmpty)
                constraints.hasBoundedHeight
                    ? const Expanded(
                        child:
                            Center(child: Text('Inventory levels are healthy')),
                      )
                    : const SizedBox(
                        height: 72,
                        child:
                            Center(child: Text('Inventory levels are healthy')),
                      ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('view-inventory-alerts'),
                  onPressed: () => controller.selectSection('Inventory'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                  label: const Text('View all alerts'),
                ),
              ),
            ]);
          }),
        );
      });
}

class _InventoryAlertRow extends StatelessWidget {
  const _InventoryAlertRow({required this.product});
  final MenuItemModel product;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Row(children: [
          ProductVisual(
            product: product,
            category: Get.find<WorkspaceController>()
                .categories
                .where((item) => item.id == product.categoryId)
                .firstOrNull,
            size: 34,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  product.stock == 0
                      ? 'Out of Stock'
                      : 'Low Stock (${product.stock} left)',
                  style: TextStyle(
                    fontSize: 9,
                    color: product.stock == 0
                        ? AppColors.danger
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
}

class SalesStats extends GetView<WorkspaceController> {
  const SalesStats({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final range = controller.salesRange.value;
        final orders = controller.ordersForRange(range);
        final total = controller.salesTotalForRange(range);
        final items = controller.itemsSoldForRange(range);
        final average = orders.isEmpty ? 0.0 : total / orders.length;
        return MalpraxPanel(
          key: const ValueKey('today-sales'),
          title: "Today's Sales",
          headerColor: AppColors.salesHeader,
          headerForegroundColor: AppColors.primary,
          trailing: _RangeMenu(
            value: range,
            onSelected: controller.setSalesRange,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final chart = _SalesChart(
                values: orders.map((order) => order.totalAmount).toList());
            final comparison = controller.salesChangePercent;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                      child: Text(RupiahFormatter.format(total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    if (range == 'Today')
                      Text(
                        '${comparison >= 0 ? '+' : ''}${comparison.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: comparison >= 0
                                ? AppColors.success
                                : AppColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                  ]),
                  Text(
                    range == 'Today'
                        ? 'vs Yesterday ${RupiahFormatter.format(controller.yesterdaySales)}'
                        : '${orders.length} completed transactions',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 9),
                  ),
                  const SizedBox(height: 6),
                  if (constraints.hasBoundedHeight)
                    Expanded(child: chart)
                  else
                    SizedBox(height: 72, child: chart),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('12 AM',
                            style: TextStyle(
                                fontSize: 7, color: AppColors.textMuted)),
                        Text('6 AM',
                            style: TextStyle(
                                fontSize: 7, color: AppColors.textMuted)),
                        Text('12 PM',
                            style: TextStyle(
                                fontSize: 7, color: AppColors.textMuted)),
                        Text('6 PM',
                            style: TextStyle(
                                fontSize: 7, color: AppColors.textMuted)),
                        Text('11 PM',
                            style: TextStyle(
                                fontSize: 7, color: AppColors.textMuted)),
                      ]),
                  const Divider(height: 12),
                  Row(children: [
                    Expanded(
                        child: _metric('Transactions', '${orders.length}')),
                    _metricDivider(),
                    Expanded(child: _metric('Items Sold', '$items')),
                    _metricDivider(),
                    Expanded(
                        child: _metric(
                            'Avg. Sale', RupiahFormatter.format(average))),
                  ]),
                ]);
          }),
        );
      });

  Widget _metric(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
        ],
      );

  Widget _metricDivider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: AppColors.border,
      );
}

class _RangeMenu extends StatelessWidget {
  const _RangeMenu({required this.value, required this.onSelected});
  final String value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Select time range',
        onSelected: onSelected,
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'Today', child: Text('Today')),
          PopupMenuItem(value: '7 days', child: Text('Last 7 days')),
          PopupMenuItem(value: 'All time', child: Text('All time')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 8)),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 13),
          ]),
        ),
      );
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SalesPainter(values, Theme.of(context).dividerColor),
        size: Size.infinite,
      );
}

class ReceiptStatus extends GetView<WorkspaceController> {
  const ReceiptStatus({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final range = controller.receiptRange.value;
        final orders = controller.receiptOrdersForRange(range);
        final total = orders.length;
        return MalpraxPanel(
          key: const ValueKey('receipt-status'),
          title: 'Receipt Status',
          headerColor: AppColors.receiptHeader,
          headerForegroundColor: AppColors.success,
          trailing:
              _RangeMenu(value: range, onSelected: controller.setReceiptRange),
          child: LayoutBuilder(builder: (context, constraints) {
            final rows = [
              _row('Total Receipts', total, total, AppColors.success),
              _row(
                  'Printed',
                  controller.receiptCountForRange(ReceiptState.printed, range),
                  total,
                  AppColors.primary),
              _row(
                  'Emailed',
                  controller.receiptCountForRange(ReceiptState.emailed, range),
                  total,
                  Colors.indigoAccent),
              _row(
                  'Failed',
                  controller.receiptCountForRange(ReceiptState.failed, range),
                  total,
                  AppColors.danger),
            ];
            return Column(
              children: constraints.hasBoundedHeight
                  ? rows.map((row) => Expanded(child: row)).toList()
                  : rows
                      .map((row) => SizedBox(height: 34, child: row))
                      .toList(),
            );
          }),
        );
      });

  Widget _row(String label, int value, int total, Color color) =>
      Row(children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 7),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 10))),
        Text(
          label == 'Total Receipts'
              ? '$value'
              : '$value (${total == 0 ? 0 : (value / total * 100).round()}%)',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
        ),
      ]);
}

class RecentOrders extends GetView<WorkspaceController> {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final orders = controller.orders.take(5).toList();
        return MalpraxPanel(
          key: const ValueKey('recent-orders'),
          title: 'Recent Orders',
          trailing: TextButton(
            key: const ValueKey('view-all-orders'),
            onPressed: () => controller.selectSection('Orders'),
            child: const Text('View All'),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 330;
            final rows = orders
                .map((order) => _RecentOrderRow(order: order, compact: compact))
                .toList();
            if (constraints.hasBoundedHeight) {
              return Column(
                  children: rows.map((row) => Expanded(child: row)).toList());
            }
            return Column(
                children: rows
                    .map((row) =>
                        SizedBox(height: compact ? 42 : 34, child: row))
                    .toList());
          }),
        );
      });
}

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({required this.order, required this.compact});
  final OrderModel order;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final danger = order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded;
    final badge = StatusBadge(order.status,
        color: danger
            ? AppColors.danger
            : order.status == OrderStatus.completed
                ? AppColors.success
                : AppColors.warning);
    final date = Text(DateFormat('MMM d, h:mm a').format(order.createdAt),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted));
    final amount = Text(RupiahFormatter.format(order.totalAmount),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600));
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: compact
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                Expanded(
                  child: Text('#${order.orderId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                badge,
              ]),
              const SizedBox(height: 1),
              Row(children: [Expanded(child: date), amount]),
            ])
          : Row(children: [
              Expanded(
                flex: 5,
                child: Text('#${order.orderId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 10)),
              ),
              Expanded(flex: 6, child: date),
              Expanded(flex: 4, child: amount),
              badge,
            ]),
    );
  }
}

class TopSelling extends GetView<WorkspaceController> {
  const TopSelling({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final top = controller.topProducts;
        final maxValue = top.isEmpty ? 1 : top.first.quantity;
        return MalpraxPanel(
          key: const ValueKey('top-selling'),
          title: 'Top Selling Products',
          trailing: TextButton(
            key: const ValueKey('view-sales-report'),
            onPressed: () => controller.selectSection('Reports'),
            child: const Text('View Report'),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final rows = top.asMap().entries.map((entry) {
              return _TopProductRow(
                rank: entry.key + 1,
                product: entry.value,
                maxValue: maxValue,
              );
            }).toList();
            if (constraints.hasBoundedHeight) {
              return Column(
                  children: rows.map((row) => Expanded(child: row)).toList());
            }
            return Column(
                children: rows
                    .map((row) => SizedBox(height: 34, child: row))
                    .toList());
          }),
        );
      });
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow(
      {required this.rank, required this.product, required this.maxValue});
  final int rank;
  final ProductSale product;
  final int maxValue;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text('$rank', style: const TextStyle(fontSize: 9)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Expanded(
                child: Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10)),
              ),
              const SizedBox(width: 5),
              Text('${product.quantity}',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: product.quantity / maxValue,
                backgroundColor: AppColors.primary.withValues(alpha: .14),
              ),
            ),
          ]),
        ),
      ]);
}

class _SalesPainter extends CustomPainter {
  _SalesPainter(this.values, this.gridColor);
  final List<double> values;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final source = values.isEmpty
        ? <double>[.18, .36, .25, .52, .42, .68, .49, .77, .63, .9]
        : values.length == 1
            ? <double>[0, values.first]
            : values;
    final maxValue =
        source.fold<double>(1, (max, value) => value > max ? value : max);
    final path = Path();
    for (var index = 0; index < source.length; index++) {
      final x =
          source.length == 1 ? 0.0 : size.width * index / (source.length - 1);
      final y = size.height - (source[index] / maxValue * (size.height - 5));
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x552788FF), Color(0x002788FF)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.gridColor != gridColor;
}
