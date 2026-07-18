import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/models/cart_item_model.dart';
import 'package:postgetx/services/pos_total_calculator.dart';

void main() {
  const calculator = PosTotalCalculator();
  final items = [
    CartItemModel(
      id: 'water',
      name: 'Water',
      size: 'Regular',
      price: 7500,
      quantity: 2,
    ),
  ];

  test('no discount applies tax to the full subtotal', () {
    final totals = calculator.calculate(
      items: items,
      discountType: DiscountType.fixed,
      discountValue: 0,
    );
    expect(totals.subtotal, 15000);
    expect(totals.discountAmount, 0);
    expect(totals.taxableAmount, 15000);
    expect(totals.tax, 1500);
    expect(totals.total, 16500);
  });

  test('fixed discount updates taxable amount tax total paid and change', () {
    final totals = calculator.calculate(
      items: items,
      discountType: DiscountType.fixed,
      discountValue: 2000,
      amountPaid: 15000,
    );
    expect(totals.discountAmount, 2000);
    expect(totals.taxableAmount, 13000);
    expect(totals.tax, 1300);
    expect(totals.total, 14300);
    expect(totals.amountPaid, 15000);
    expect(totals.change, 700);
  });

  test('percentage discount is applied before tax', () {
    final totals = calculator.calculate(
      items: items,
      discountType: DiscountType.percentage,
      discountValue: 10,
    );
    expect(totals.discountValue, 10);
    expect(totals.discountAmount, 1500);
    expect(totals.taxableAmount, 13500);
    expect(totals.tax, 1350);
    expect(totals.total, 14850);
  });

  test('fractional values use deterministic integer-rupiah rounding', () {
    final totals = calculator.calculate(
      items: items,
      discountType: DiscountType.percentage,
      discountValue: 7.5,
    );
    expect(totals.discountValue, 7.5);
    expect(totals.discountAmount, 1125);
    expect(totals.taxableAmount, 13875);
    expect(totals.tax, 1388);
    expect(totals.total, 15263);
  });
}
