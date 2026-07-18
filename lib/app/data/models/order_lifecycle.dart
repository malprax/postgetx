abstract final class OrderStatus {
  static const draft = 'draft';
  static const held = 'held';
  static const saved = 'saved';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const refunded = 'refunded';

  static const open = {held, saved};
  static const persisted = {held, saved, completed, cancelled, refunded};
}

abstract final class ReceiptState {
  static const pending = 'pending';
  static const printed = 'printed';
  static const emailed = 'emailed';
  static const failed = 'failed';
}
