import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/product_model.dart';
import '../shared/models/material_model.dart';
import 'material_repository.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MaterialRepository _materialRepo = MaterialRepository();
  
  final CollectionReference _collection = FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> getActiveProducts() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getAllProducts() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product?> getProduct(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Future<bool> checkStockAvailability(Product product) async {
    try {
      final materialsStream = _materialRepo.getMaterials();
      final materials = await materialsStream.first;
      
      final Map<String, int> availableStocks = {};
      for (var material in materials) {
        availableStocks[material.id] = material.availableQuantity;
      }
      
      return product.hasSufficientStock(availableStocks);
    } catch (e) {
      throw Exception('Failed to check stock: $e');
    }
  }

  Future<String> createProduct(Product product) async {
    try {
      final docRef = await _collection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _collection.doc(product.id).update({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'isActive': product.isActive,
        'ingredients': product.ingredients.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await _collection.doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle active: $e');
    }
  }

  Future<void> changePrice(String productId, double newPrice, String changedBy, {String? reason}) async {
    try {
      final productDoc = await _collection.doc(productId).get();
      
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }
      
      var data = productDoc.data() as Map<String, dynamic>;
      final oldPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
      
      final priceHistoryEntry = PriceHistoryEntry(
        amount: newPrice,
        effectiveDate: DateTime.now(),
        previousAmount: oldPrice,
        changedBy: changedBy,
        reason: reason,
      ).toMap();
      
      await _collection.doc(productId).update({
        'price': newPrice,
        'priceHistory': FieldValue.arrayUnion([priceHistoryEntry]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to change price: $e');
    }
  }

  Stream<List<Product>> searchProducts(String query) {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  Future<List<Product>> getLowStockProducts(List<Material> materials) async {
    try {
      final allProductsStream = getAllProducts();
      final allProducts = await allProductsStream.first;
      
      final stockMap = <String, int>{};
      for (var material in materials) {
        stockMap[material.id] = material.availableQuantity;
      }
      
      return allProducts.where((product) {
        return !product.hasSufficientStock(stockMap);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get low stock products: $e');
    }
  }
}
