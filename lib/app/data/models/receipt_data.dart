import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/models/order_model.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';

/// Receipt-facing snapshot copied only from a persisted [OrderModel].
class ReceiptData {
  const ReceiptData({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.taxableAmount,
    required this.taxType,
    required this.taxValue,
    required this.taxAmount,
    required this.total,
    required this.amountPaid,
    required this.paymentMethod,
    required this.amountApplied,
    required this.paidAt,
    required this.change,
  });

  factory ReceiptData.fromOrder(OrderModel order) => ReceiptData(
        orderId: order.orderId,
        items: order.items,
        subtotal: order.subtotal,
        discountType: order.discountType,
        discountValue: order.discountValue,
        discountAmount: order.discount,
        taxableAmount: order.taxableAmount,
        taxType: order.taxType,
        taxValue: order.taxValue,
        taxAmount: order.taxAmount,
        total: order.totalAmount,
        amountPaid: order.amountReceived,
        paymentMethod: order.paymentMethod,
        amountApplied: order.amountApplied,
        paidAt: order.paidAt,
        change: order.change,
      );

  final String orderId;
  final List<CartItemModel> items;
  final double subtotal;
  final DiscountType discountType;
  final double discountValue;
  final double discountAmount;
  final double taxableAmount;
  final TaxType taxType;
  final double taxValue;
  final double taxAmount;
  double get tax => taxAmount;
  final double total;
  final double amountPaid;
  final String paymentMethod;
  final double amountApplied;
  final DateTime? paidAt;
  final double change;
}
