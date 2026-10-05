import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  static double _parseDouble(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int _parseInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      quantity: _parseInt(map['quantity']),
      price: _parseDouble(map['price']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class SaleModel {
  final String saleId;
  final String staffId;
  final String staffName;
  final List<SaleItem> items;
  final double totalAmount;
  final String paymentMethod;
  final DateTime timestamp;

  SaleModel({
    required this.saleId,
    required this.staffId,
    this.staffName = '',
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
  });

  int get totalItems => items.fold(0, (s, item) => s + item.quantity);

  // ─── Firestore Serialization ───────────────────────────
  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      saleId: map['sale_id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: SaleItem._parseDouble(map['total_amount']),
      paymentMethod: map['payment_method'] ?? 'Cash',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sale_id': saleId,
      'staff_id': staffId,
      'staff_name': staffName,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // ─── Hive Serialization (no Firestore Timestamps) ──────
  factory SaleModel.fromHiveMap(Map<dynamic, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
            ?.map((item) =>
                SaleItem.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList() ??
        [];

    return SaleModel(
      saleId: map['sale_id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      items: itemsList,
      totalAmount: SaleItem._parseDouble(map['total_amount']),
      paymentMethod: map['payment_method'] ?? 'Cash',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'sale_id': saleId,
      'staff_id': staffId,
      'staff_name': staffName,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
