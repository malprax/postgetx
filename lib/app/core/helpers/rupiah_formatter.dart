import 'package:intl/intl.dart';

abstract final class RupiahFormatter {
  static final NumberFormat _format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(num value) => _format.format(value.round());
}
