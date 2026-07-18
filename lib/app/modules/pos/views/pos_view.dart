import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/routes/app_routes.dart';
import 'package:postgetx/widgets/demo_mode_banner.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  PosView({super.key});
  final PosController controller = Get.find();
  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 1100;
      return Scaffold(
        appBar: AppBar(
          title: const Text('POS / Cashier'),
          actions: [
            IconButton(
                tooltip: 'Transaction history',
                onPressed: () => Get.toNamed(Routes.orderHistory),
                icon: const Icon(Icons.history))
          ],
        ),
        body: Column(
          children: [
            const DemoModeBanner(),
            Expanded(child: compact ? _compact(context) : _wide(context)),
          ],
        ),
        bottomNavigationBar: compact
            ? Obx(() => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FilledButton.icon(
                      onPressed: () => _showCart(context),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                          'Cart (${controller.cartItems.length}) • ${currency.format(controller.totalAfterDiscount.value)}'),
                    ),
                  ),
                ))
            : null,
      );
    });
  }

  Widget _categories({bool horizontal = false}) {
    return Obx(() => SizedBox(
          height: horizontal ? 52 : null,
          child: ListView.separated(
            scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
            padding: const EdgeInsets.all(8),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6, height: 6),
            itemBuilder: (_, index) {
              final category = controller.categories[index];
              return FilterChip(
                label: Text(category.name),
                selected: controller.selectedCategory.value?.id == category.id,
                onSelected: (_) => controller.setCategoryFilter(category),
              );
            },
          ),
        ));
  }

  Widget _catalog(int columns) {
    return Obx(() {
      final menus = controller.filteredMenu;
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: columns == 1 ? 1.8 : 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: menus.length,
        itemBuilder: (_, index) {
          final menu = menus[index];
          final variant = menu.variants.isEmpty
              ? MenuVariant(size: 'Regular', price: 0)
              : menu.variants.first;
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.addItem(menu, variant.size),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(child: Text(menu.name.characters.first)),
                    const SizedBox(height: 10),
                    Text(menu.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(currency.format(variant.price),
                        style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w700)),
                    const Text('Tap to add', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _wide(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 184, child: _categories()),
        Expanded(
            child: LayoutBuilder(
                builder: (_, c) => _catalog(c.maxWidth >= 900
                    ? 4
                    : c.maxWidth >= 620
                        ? 3
                        : 2))),
        SizedBox(width: 390, child: _cart(context)),
      ],
    );
  }

  Widget _compact(BuildContext context) {
    return Column(
      children: [
        _categories(horizontal: true),
        Expanded(
            child: LayoutBuilder(
                builder: (_, c) => _catalog(c.maxWidth >= 600
                    ? 3
                    : c.maxWidth >= 430
                        ? 2
                        : 1))),
      ],
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) =>
            FractionallySizedBox(heightFactor: .88, child: _cart(context)));
  }

  Widget _cart(BuildContext context) {
    return Obx(() => Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Current sale',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                      onPressed: controller.cartItems.isEmpty
                          ? null
                          : controller.resetCart,
                      child: const Text('Clear'))
                ]),
                const Text(
                    'Add items, optionally apply a discount, then enter cash received.'),
                const SizedBox(height: 8),
                Expanded(
                  child: controller.cartItems.isEmpty
                      ? const Center(
                          child: Text(
                              'Your cart is empty. Select a product to begin.'))
                      : ListView.builder(
                          itemCount: controller.cartItems.length,
                          itemBuilder: (_, index) {
                            final item = controller.cartItems[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(item.name),
                              subtitle: Text(
                                  '${currency.format(item.price)} × ${item.quantity}'),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        constraints:
                                            const BoxConstraints.tightFor(
                                                width: 36, height: 36),
                                        padding: EdgeInsets.zero,
                                        onPressed: () =>
                                            controller.decreaseQuantity(item),
                                        icon: const Icon(
                                            Icons.remove_circle_outline)),
                                    Text('${item.quantity}'),
                                    IconButton(
                                        constraints:
                                            const BoxConstraints.tightFor(
                                                width: 36, height: 36),
                                        padding: EdgeInsets.zero,
                                        onPressed: () =>
                                            controller.increaseQuantity(item),
                                        icon: const Icon(
                                            Icons.add_circle_outline))
                                  ]),
                            );
                          },
                        ),
                ),
                const Divider(),
                Row(children: [
                  const Text('Discount'),
                  const Spacer(),
                  DropdownButton<double>(
                    value: controller.discount.value,
                    items: const [0, 5, 10, 15]
                        .map((value) => DropdownMenuItem(
                            value: value.toDouble(), child: Text('$value%')))
                        .toList(),
                    onChanged: (value) => controller.setDiscount(value ?? 0),
                  ),
                ]),
                TextField(
                  controller: controller.payment,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cash received',
                    helperText:
                        'Suggested: ${currency.format(controller.totalAfterDiscount.value)}',
                    suffixIcon: IconButton(
                      tooltip: 'Use exact amount',
                      onPressed: controller.cartItems.isEmpty
                          ? null
                          : () {
                              controller.payment.text = controller
                                  .totalAfterDiscount.value
                                  .toStringAsFixed(0);
                              controller.recalculateTotal();
                            },
                      icon: const Icon(Icons.auto_fix_high),
                    ),
                  ),
                  onChanged: (_) => controller.recalculateTotal(),
                ),
                const SizedBox(height: 12),
                _total('Subtotal', controller.totalAmount.value),
                _total('Total', controller.totalAfterDiscount.value,
                    strong: true),
                if (!controller.isPaymentEmpty.value)
                  _total('Change', controller.totalChange.value),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: controller.cartItems.isNotEmpty &&
                          controller.isPaymentSufficient.value
                      ? controller.checkoutAndPrint
                      : null,
                  icon: const Icon(Icons.receipt_long),
                  label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Complete Sale & Preview Receipt')),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _total(String label, double value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontWeight: strong ? FontWeight.bold : FontWeight.normal)),
        const Spacer(),
        Text(currency.format(value),
            style: TextStyle(
                fontWeight: strong ? FontWeight.bold : FontWeight.normal))
      ]),
    );
  }
}
