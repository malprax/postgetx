// lib/modules/pos/widgets/menu_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postgetx/models/menu_item_model.dart';
import '../controllers/pos_controller.dart';

class MenuDetailBottomSheet extends StatelessWidget {
  final MenuItemModel item;
  final PosController controller;

  const MenuDetailBottomSheet({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Cek apakah description tidak null dan tidak kosong
          if ((item.description ?? '').isNotEmpty)
            Text(
              item.description!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

          const SizedBox(height: 12),
          const Text(
            'Pilih Varian:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...item.variants.map(
            (variant) => ListTile(
              title: Text(variant.size ?? '-'),
              trailing: Text(currencyFormat.format(variant.price ?? 0)),
              onTap: () {
                controller.addItem(item, variant.size ?? '-');
                Navigator.pop(context);
              },
            ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text("Tutup"),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
