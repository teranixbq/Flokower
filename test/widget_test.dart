import 'package:flutter_test/flutter_test.dart';
import 'package:flokower/shared/models/material_model.dart';
import 'package:flokower/shared/models/product_model.dart';

void main() {
  test('Material availableQuantity calculates correctly', () {
    final material = Material(
      id: 'test1',
      name: 'Test Material',
      unit: 'lembar',
      currentQuantity: 100,
      reservedQuantity: 20,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(material.availableQuantity, 80);
    expect(material.isLowStock, false);
  });

  test('Material isLowStock returns true when below threshold', () {
    final material = Material(
      id: 'test2',
      name: 'Low Stock Material',
      unit: 'tangkai',
      currentQuantity: 5,
      threshold: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(material.isLowStock, true);
  });

  test('Product hasSufficientStock returns true when all materials available', () {
    final product = Product(
      id: 'p1',
      name: 'Test Product',
      price: 150000,
      ingredients: [
        ProductIngredient(materialId: 'm1', quantityNeeded: 5),
        ProductIngredient(materialId: 'm2', quantityNeeded: 3),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final stockMap = {'m1': 10, 'm2': 5};
    expect(product.hasSufficientStock(stockMap), true);
  });

  test('Product hasSufficientStock returns false when material insufficient', () {
    final product = Product(
      id: 'p1',
      name: 'Test Product',
      price: 150000,
      ingredients: [
        ProductIngredient(materialId: 'm1', quantityNeeded: 10),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final stockMap = {'m1': 5};
    expect(product.hasSufficientStock(stockMap), false);
  });
}
