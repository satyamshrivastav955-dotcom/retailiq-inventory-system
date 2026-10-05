import 'package:flutter_test/flutter_test.dart';
import 'package:k11_project/models/product_model.dart';

void main() {
  test('Hive round-trip preserves fields', () {
    final now = DateTime(2026, 10, 5, 12);
    final product = ProductModel(
      productId: 'p1',
      barcode: '8901234567890',
      name: 'Test Soap',
      category: 'Personal Care',
      costPrice: 20.5,
      sellingPrice: 30.0,
      quantity: 10,
      supplier: 'Acme',
      minimumStockLevel: 5,
      createdAt: now,
      lastSoldAt: now,
      expiryDate: now.add(const Duration(days: 30)),
    );

    final restored = ProductModel.fromHiveMap(product.toHiveMap());

    expect(restored.productId, 'p1');
    expect(restored.barcode, '8901234567890');
    expect(restored.costPrice, 20.5);
    expect(restored.quantity, 10);
    expect(restored.expiryDate?.year, now.add(const Duration(days: 30)).year);
  });

  test('fromHiveMap tolerates string numbers', () {
    final restored = ProductModel.fromHiveMap({
      'product_id': 'p2',
      'barcode': '123',
      'name': 'String numbers',
      'category': 'Other',
      'cost_price': '19.99',
      'selling_price': '29.99',
      'quantity': '7',
      'supplier': '',
      'minimum_stock_level': '5',
      'created_at': DateTime(2026, 1, 1).toIso8601String(),
    });

    expect(restored.costPrice, 19.99);
    expect(restored.quantity, 7);
  });

  test('stock getters behave correctly', () {
    ProductModel base(int qty) => ProductModel(
          productId: 'x',
          barcode: 'b',
          name: 'n',
          category: 'Other',
          costPrice: 1,
          sellingPrice: 2,
          quantity: qty,
          supplier: '',
          minimumStockLevel: 5,
          createdAt: DateTime.now(),
        );

    expect(base(0).isOutOfStock, isTrue);
    expect(base(3).isLowStock, isTrue);
    expect(base(10).isLowStock, isFalse);
  });
}
