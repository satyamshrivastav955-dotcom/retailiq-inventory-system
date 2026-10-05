import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ProductModel {
  final String productId;
  final String barcode;
  final String name;
  final String brand;
  final String description;
  final String? imageUrl;
  final String category;
  final double costPrice;
  final double sellingPrice;
  int quantity;
  final DateTime? expiryDate;
  final String supplier;
  final int minimumStockLevel;
  final DateTime createdAt;
  final DateTime? lastSoldAt;

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

  ProductModel({
    required this.productId,
    required this.barcode,
    required this.name,
    this.brand = '',
    this.description = '',
    this.imageUrl,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    this.expiryDate,
    required this.supplier,
    required this.minimumStockLevel,
    required this.createdAt,
    this.lastSoldAt,
  });

  // ─── Computed Properties ───────────────────────────────
  bool get isLowStock => quantity <= minimumStockLevel && quantity > 0;

  bool get isOutOfStock => quantity <= 0;

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= kExpiryAlertDays;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isDeadStock {
    if (lastSoldAt == null) {
      return DateTime.now().difference(createdAt).inDays >= kDeadStockDays;
    }
    return DateTime.now().difference(lastSoldAt!).inDays >= kDeadStockDays;
  }

  double get profit => sellingPrice - costPrice;
  double get profitMargin => costPrice > 0 ? (profit / costPrice) * 100 : 0;

  // ─── Firestore Serialization ───────────────────────────
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'] ?? '',
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      category: map['category'] ?? 'Other',
      costPrice: _parseDouble(map['cost_price']),
      sellingPrice: _parseDouble(map['selling_price']),
      quantity: _parseInt(map['quantity']),
      expiryDate: (map['expiry_date'] as Timestamp?)?.toDate(),
      supplier: map['supplier'] ?? '',
      minimumStockLevel: _parseInt(map['minimum_stock_level'], 5),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSoldAt: (map['last_sold_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'supplier': supplier,
      'minimum_stock_level': minimumStockLevel,
      'created_at': Timestamp.fromDate(createdAt),
      'last_sold_at': lastSoldAt != null ? Timestamp.fromDate(lastSoldAt!) : null,
    };
  }

  // ─── Hive Serialization (no Firestore Timestamps) ──────
  factory ProductModel.fromHiveMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      productId: map['product_id'] ?? '',
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      category: map['category'] ?? 'Other',
      costPrice: _parseDouble(map['cost_price']),
      sellingPrice: _parseDouble(map['selling_price']),
      quantity: _parseInt(map['quantity']),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'])
          : null,
      supplier: map['supplier'] ?? '',
      minimumStockLevel: _parseInt(map['minimum_stock_level'], 5),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      lastSoldAt: map['last_sold_at'] != null
          ? DateTime.parse(map['last_sold_at'])
          : null,
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'product_id': productId,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'supplier': supplier,
      'minimum_stock_level': minimumStockLevel,
      'created_at': createdAt.toIso8601String(),
      'last_sold_at': lastSoldAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? productId,
    String? barcode,
    String? name,
    String? brand,
    String? description,
    String? imageUrl,
    String? category,
    double? costPrice,
    double? sellingPrice,
    int? quantity,
    DateTime? expiryDate,
    String? supplier,
    int? minimumStockLevel,
    DateTime? createdAt,
    DateTime? lastSoldAt,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      minimumStockLevel: minimumStockLevel ?? this.minimumStockLevel,
      createdAt: createdAt ?? this.createdAt,
      lastSoldAt: lastSoldAt ?? this.lastSoldAt,
    );
  }
}
