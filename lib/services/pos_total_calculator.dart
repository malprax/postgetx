import '../models/cart_item_model.dart';

enum DiscountType {
  fixed,
  percentage;

  static DiscountType fromStorage(Object? value) => switch (value?.toString()) {
        'percentage' => DiscountType.percentage,
        _ => DiscountType.fixed,
      };
}

enum TaxType {
  none,
  percentage,
  fixedAmount;

  static TaxType fromStorage(Object? value) => switch (value?.toString()) {
        'percentage' => TaxType.percentage,
        'fixedAmount' => TaxType.fixedAmount,
        _ => TaxType.none,
      };
}

class PosTotals {
  const PosTotals({
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
    required this.change,
  });

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
  final double change;
}

/// Authoritative integer-rupiah checkout calculation.
///
/// Every monetary component is rounded once to a whole rupiah. Checkout UI,
/// repository validation, persisted orders, and receipts all share this path.
class PosTotalCalculator {
  const PosTotalCalculator();

  PosTotals calculate({
    required Iterable<CartItemModel> items,
    required DiscountType discountType,
    required double discountValue,
    TaxType taxType = TaxType.percentage,
    double taxValue = 10,
    double? amountPaid,
  }) {
    final subtotal = _rupiah(items.fold<double>(
        0, (sum, item) => sum + (item.price * item.quantity)));
    final safeValue = discountValue.isFinite ? discountValue : 0;
    final requestedDiscount = switch (discountType) {
      DiscountType.fixed => safeValue,
      DiscountType.percentage => subtotal * safeValue.clamp(0, 100) / 100,
    };
    final discountAmount =
        _rupiah(requestedDiscount.clamp(0, subtotal).toDouble());
    final taxableAmount = _rupiah(subtotal - discountAmount);
    final safeTaxValue = taxValue.isFinite ? taxValue : 0;
    final normalizedTaxValue = switch (taxType) {
      TaxType.none => 0.0,
      TaxType.percentage => safeTaxValue.clamp(0, 100).toDouble(),
      TaxType.fixedAmount => _rupiah(safeTaxValue.clamp(0, double.infinity)),
    };
    final taxAmount = _rupiah(switch (taxType) {
      TaxType.none => 0,
      TaxType.percentage => taxableAmount * normalizedTaxValue / 100,
      TaxType.fixedAmount => normalizedTaxValue,
    });
    final total =
        _rupiah(taxableAmount + taxAmount).clamp(0, double.infinity).toDouble();
    final paid = _rupiah(amountPaid ?? total);
    final change = _rupiah((paid - total).clamp(0, double.infinity));
    return PosTotals(
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountType == DiscountType.percentage
          ? safeValue.clamp(0, 100).toDouble()
          : _rupiah(safeValue.clamp(0, double.infinity)),
      discountAmount: discountAmount,
      taxableAmount: taxableAmount,
      taxType: taxType,
      taxValue: normalizedTaxValue,
      taxAmount: taxAmount,
      total: total,
      amountPaid: paid,
      change: change,
    );
  }

  static bool sameMoney(num left, num right) =>
      (left.toDouble() - right.toDouble()).abs() < .01;

  static double _rupiah(num value) => value.toDouble().roundToDouble();
}
