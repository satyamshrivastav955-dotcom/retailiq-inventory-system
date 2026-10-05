import 'package:flutter_test/flutter_test.dart';
import 'package:k11_project/models/sale_model.dart';

void main() {
  test('Hive round-trip preserves sale', () {
    final now = DateTime(2026, 10, 5, 12);
    final sale = SaleModel(
      saleId: 's1',
      staffId: 'staff-1',
      staffName: 'Asha',
      items: [
        SaleItem(
          productId: 'p1',
          productName: 'Soap',
          quantity: 2,
          price: 30.0,
        ),
      ],
      totalAmount: 60.0,
      paymentMethod: 'Cash',
      timestamp: now,
    );

    final restored = SaleModel.fromHiveMap(sale.toHiveMap());

    expect(restored.saleId, 's1');
    expect(restored.totalItems, 2);
    expect(restored.totalAmount, 60.0);
    expect(restored.items.first.total, 60.0);
  });

  test('SaleItem tolerates string numbers', () {
    final item = SaleItem.fromMap({
      'product_id': 'p1',
      'product_name': 'Soap',
      'quantity': '3',
      'price': '10.5',
    });

    expect(item.quantity, 3);
    expect(item.price, 10.5);
    expect(item.total, 31.5);
  });
}
