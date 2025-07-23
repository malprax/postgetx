import 'package:intl/intl.dart';

class DateHelper {
  /// Format tanggal lengkap: 21 Juli 2025
  static String formatFullDate(DateTime date) {
    return DateFormat("d MMMM y", "id_ID").format(date);
  }

  /// Format tanggal pendek: 2025-07-21
  static String formatShortDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  /// Format waktu jam:menit:detik → 14:35:00
  static String formatTime(DateTime date) {
    return DateFormat("HH:mm:ss").format(date);
  }

  /// Format gabungan tanggal dan waktu: 2025-07-21 14:35
  static String formatDateTime(DateTime date) {
    return DateFormat("yyyy-MM-dd HH:mm").format(date);
  }

  /// Dapatkan tanggal hari ini dalam string (misalnya untuk ID dokumen Firestore)
  static String todayAsString() {
    return formatShortDate(DateTime.now());
  }

  /// Dapatkan timestamp sekarang dengan ISO format
  static String nowIsoString() {
    return DateTime.now().toIso8601String();
  }
}
