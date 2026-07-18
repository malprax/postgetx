import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';

class OrderModel {
  final String id;
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final double subtotal;
  final double discount;
  final DiscountType discountType;
  final double discountValue;
  final int loyaltyPointsRedeemed;
  final double loyaltyDiscount;
  final int loyaltyPointsEarned;
  final int loyaltyBalanceAfter;
  final double taxableAmount;
  final double paid;
  final double change;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;
  final String updatedBy;
  final String status;
  final String receiptStatus;
  final TaxType taxType;
  final double taxValue;
  final double taxAmount;
  double get tax => taxAmount;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;
  final String? refundReason;
  final String? cancelledBy;
  final String? cancellationReason;
  final String? refundedBy;
  final String paymentMethod;
  final double amountReceived;
  final double amountApplied;
  final DateTime? paidAt;
  final String? customerId;
  final String? customerName;
  final String notes;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? deleteReason;
  final DateTime? restoredAt;
  final String? restoredBy;
  final bool stockApplied;
  final bool stockRestored;
  final String? sourceOrderId;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.items,
    required this.totalAmount,
    double? subtotal,
    required this.discount,
    this.discountType = DiscountType.fixed,
    double? discountValue,
    this.loyaltyPointsRedeemed = 0,
    this.loyaltyDiscount = 0,
    this.loyaltyPointsEarned = 0,
    this.loyaltyBalanceAfter = 0,
    double? taxableAmount,
    required this.paid,
    required this.change,
    required this.createdAt,
    required this.createdBy,
    this.createdByName = '',
    this.updatedBy = '',
    this.status = OrderStatus.completed,
    this.receiptStatus = ReceiptState.printed,
    TaxType? taxType,
    double? taxValue,
    double? taxAmount,
    double? tax,
    this.completedAt,
    this.cancelledAt,
    this.refundedAt,
    this.refundReason,
    this.cancelledBy,
    this.cancellationReason,
    this.refundedBy,
    this.paymentMethod = 'cash',
    double? amountReceived,
    double? amountApplied,
    this.paidAt,
    this.customerId,
    this.customerName,
    this.notes = '',
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.deleteReason,
    this.restoredAt,
    this.restoredBy,
    bool? stockApplied,
    bool? stockRestored,
    this.sourceOrderId,
    DateTime? updatedAt,
  })  : amountReceived = amountReceived ?? paid,
        amountApplied = amountApplied ?? totalAmount,
        taxType = taxType ??
            ((taxAmount ?? tax ?? 0) > 0 ? TaxType.fixedAmount : TaxType.none),
        taxAmount = taxAmount ?? tax ?? 0,
        taxValue = taxValue ?? taxAmount ?? tax ?? 0,
        subtotal = subtotal ?? _itemsSubtotal(items),
        discountValue = discountValue ?? discount,
        taxableAmount = taxableAmount ??
            (subtotal ?? _itemsSubtotal(items)) - discount - loyaltyDiscount,
        stockApplied = stockApplied ??
            status == OrderStatus.completed || status == OrderStatus.refunded,
        stockRestored = stockRestored ?? status == OrderStatus.refunded,
        updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'discount': discount,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
      'loyaltyDiscount': loyaltyDiscount,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyBalanceAfter': loyaltyBalanceAfter,
      'taxableAmount': taxableAmount,
      'paid': paid,
      'change': change,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'status': status,
      'receiptStatus': receiptStatus,
      'taxType': taxType.name,
      'taxValue': taxValue,
      'taxAmount': taxAmount,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'refundReason': refundReason,
      'cancelledBy': cancelledBy,
      'cancellationReason': cancellationReason,
      'refundedBy': refundedBy,
      'paymentMethod': paymentMethod,
      'amountReceived': amountReceived,
      'amountApplied': amountApplied,
      'paidAt': paidAt?.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'notes': notes,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'deleteReason': deleteReason,
      'restoredAt': restoredAt?.toIso8601String(),
      'restoredBy': restoredBy,
      'stockApplied': stockApplied,
      'stockRestored': stockRestored,
      'sourceOrderId': sourceOrderId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final status = map['status']?.toString() ?? OrderStatus.completed;
    final createdAt = _date(map['createdAt']) ?? DateTime.now();
    final items = (map['items'] as List? ?? const [])
        .map((e) => CartItemModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final subtotal =
        (map['subtotal'] as num?)?.toDouble() ?? _itemsSubtotal(items);
    final discount = (map['discount'] ?? 0).toDouble();
    final legacyTax = (map['tax'] as num?)?.toDouble() ?? 0;
    final persistedTax = (map['taxAmount'] as num?)?.toDouble() ?? legacyTax;
    final hasTaxType = map.containsKey('taxType');
    return OrderModel(
      id: id,
      orderId: map['orderId'] ?? '',
      items: items,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      subtotal: subtotal,
      discount: discount,
      discountType: DiscountType.fromStorage(map['discountType']),
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? discount,
      loyaltyPointsRedeemed:
          (map['loyaltyPointsRedeemed'] as num?)?.toInt() ?? 0,
      loyaltyDiscount: (map['loyaltyDiscount'] as num?)?.toDouble() ?? 0,
      loyaltyPointsEarned: (map['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
      loyaltyBalanceAfter: (map['loyaltyBalanceAfter'] as num?)?.toInt() ?? 0,
      taxableAmount: (map['taxableAmount'] as num?)?.toDouble() ??
          subtotal -
              discount -
              ((map['loyaltyDiscount'] as num?)?.toDouble() ?? 0),
      paid: (map['paid'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      createdAt: createdAt,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName']?.toString() ?? '',
      updatedBy: map['updatedBy']?.toString() ?? '',
      status: status,
      receiptStatus: map['receiptStatus']?.toString() ?? ReceiptState.printed,
      taxType: hasTaxType
          ? TaxType.fromStorage(map['taxType'])
          : persistedTax > 0
              ? TaxType.fixedAmount
              : TaxType.none,
      taxValue: (map['taxValue'] as num?)?.toDouble() ?? persistedTax,
      taxAmount: persistedTax,
      completedAt: _date(map['completedAt']) ??
          (status == OrderStatus.completed ? createdAt : null),
      cancelledAt: _date(map['cancelledAt']),
      refundedAt: _date(map['refundedAt']),
      refundReason: map['refundReason']?.toString(),
      cancelledBy: map['cancelledBy']?.toString(),
      cancellationReason: map['cancellationReason']?.toString(),
      refundedBy: map['refundedBy']?.toString(),
      paymentMethod: map['paymentMethod']?.toString() ?? 'cash',
      amountReceived: (map['amountReceived'] as num?)?.toDouble() ??
          (map['paid'] as num?)?.toDouble() ??
          0,
      amountApplied: (map['amountApplied'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0,
      paidAt: _date(map['paidAt']),
      customerId: map['customerId']?.toString(),
      customerName: map['customerName']?.toString(),
      notes: map['notes']?.toString() ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
      deletedAt: _date(map['deletedAt']),
      deletedBy: map['deletedBy']?.toString(),
      deleteReason: map['deleteReason']?.toString(),
      restoredAt: _date(map['restoredAt']),
      restoredBy: map['restoredBy']?.toString(),
      stockApplied: map['stockApplied'] as bool? ??
          (status == OrderStatus.completed || status == OrderStatus.refunded),
      stockRestored:
          map['stockRestored'] as bool? ?? status == OrderStatus.refunded,
      sourceOrderId: map['sourceOrderId']?.toString(),
      updatedAt: _date(map['updatedAt']) ?? createdAt,
    );
  }

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');

  OrderModel copyWith({
    String? id,
    String? orderId,
    List<CartItemModel>? items,
    double? totalAmount,
    double? subtotal,
    double? discount,
    DiscountType? discountType,
    double? discountValue,
    int? loyaltyPointsRedeemed,
    double? loyaltyDiscount,
    int? loyaltyPointsEarned,
    int? loyaltyBalanceAfter,
    double? taxableAmount,
    double? paid,
    double? change,
    TaxType? taxType,
    double? taxValue,
    double? taxAmount,
    DateTime? createdAt,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? status,
    String? receiptStatus,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? refundedAt,
    String? refundReason,
    String? cancelledBy,
    String? cancellationReason,
    String? refundedBy,
    String? paymentMethod,
    double? amountReceived,
    double? amountApplied,
    DateTime? paidAt,
    String? customerId,
    String? customerName,
    String? notes,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    String? deleteReason,
    DateTime? restoredAt,
    String? restoredBy,
    bool clearDeletion = false,
    bool? stockApplied,
    bool? stockRestored,
    String? sourceOrderId,
    DateTime? updatedAt,
  }) =>
      OrderModel(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        items: items ?? this.items,
        totalAmount: totalAmount ?? this.totalAmount,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        loyaltyPointsRedeemed:
            loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
        loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
        loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
        loyaltyBalanceAfter: loyaltyBalanceAfter ?? this.loyaltyBalanceAfter,
        taxableAmount: taxableAmount ?? this.taxableAmount,
        paid: paid ?? this.paid,
        change: change ?? this.change,
        taxType: taxType ?? this.taxType,
        taxValue: taxValue ?? this.taxValue,
        taxAmount: taxAmount ?? this.taxAmount,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        createdByName: createdByName ?? this.createdByName,
        updatedBy: updatedBy ?? this.updatedBy,
        status: status ?? this.status,
        receiptStatus: receiptStatus ?? this.receiptStatus,
        completedAt: completedAt ?? this.completedAt,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        refundedAt: refundedAt ?? this.refundedAt,
        refundReason: refundReason ?? this.refundReason,
        cancelledBy: cancelledBy ?? this.cancelledBy,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        refundedBy: refundedBy ?? this.refundedBy,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        amountReceived: amountReceived ?? this.amountReceived,
        amountApplied: amountApplied ?? this.amountApplied,
        paidAt: paidAt ?? this.paidAt,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        notes: notes ?? this.notes,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: clearDeletion ? null : deletedAt ?? this.deletedAt,
        deletedBy: clearDeletion ? null : deletedBy ?? this.deletedBy,
        deleteReason: clearDeletion ? null : deleteReason ?? this.deleteReason,
        restoredAt: restoredAt ?? this.restoredAt,
        restoredBy: restoredBy ?? this.restoredBy,
        stockApplied: stockApplied ?? this.stockApplied,
        stockRestored: stockRestored ?? this.stockRestored,
        sourceOrderId: sourceOrderId ?? this.sourceOrderId,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static double _itemsSubtotal(Iterable<CartItemModel> items) =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
