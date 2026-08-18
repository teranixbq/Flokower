import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final List<ProductIngredient> ingredients;
  final List<PriceHistoryEntry> priceHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.ingredients,
    this.priceHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool hasSufficientStock(Map<String, int> availableStocks) {
    return ingredients.every((ingredient) {
      final materialId = ingredient.materialId;
      final neededQty = ingredient.quantityNeeded;
      final available = availableStocks[materialId] ?? 0;
      return available >= neededQty;
    });
  }

  Map<String, int> getRequiredMaterials() {
    final Map<String, int> result = {};
    for (var ingredient in ingredients) {
      result[ingredient.materialId] = 
          (result[ingredient.materialId] ?? 0) + ingredient.quantityNeeded;
    }
    return result;
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse ingredients
    final ingredientsList = 
        (data['ingredients'] as List?)?.map((i) {
      return ProductIngredient(
        materialId: i['materialId'] ?? '',
        quantityNeeded: i['quantityNeeded'] as int? ?? 0,
      );
    }).toList() ?? [];

    // Parse price history
    final priceHistoryList = 
        (data['priceHistory'] as List?)?.map((p) {
      return PriceHistoryEntry(
        amount: p['amount'] as double? ?? 0.0,
        effectiveDate: (p['effectiveDate'] as Timestamp).toDate(),
        previousAmount: p['previousAmount'] as double? ?? 0.0,
        changedBy: p['changedBy'] ?? '',
        reason: p['reason'],
      );
    }).toList() ?? [];

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      ingredients: ingredientsList,
      priceHistory: priceHistoryList,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'ingredients': ingredients.map((i) => {
        'materialId': i.materialId,
        'quantityNeeded': i.quantityNeeded,
      }).toList(),
      'priceHistory': priceHistory.map((p) => {
        'amount': p.amount,
        'effectiveDate': FieldValue.serverTimestamp(),
        'previousAmount': p.previousAmount,
        'changedBy': p.changedBy,
        'reason': p.reason,
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    bool? isActive,
    List<ProductIngredient>? ingredients,
    List<PriceHistoryEntry>? priceHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      ingredients: ingredients ?? this.ingredients,
      priceHistory: priceHistory ?? this.priceHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: Rp${price.toStringAsFixed(0)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;
}

class ProductIngredient {
  final String materialId;
  final int quantityNeeded;

  ProductIngredient({
    required this.materialId,
    required this.quantityNeeded,
  });

  Map<String, dynamic> toMap() => {
    'materialId': materialId,
    'quantityNeeded': quantityNeeded,
  };

  factory ProductIngredient.fromMap(Map<String, dynamic> map) {
    return ProductIngredient(
      materialId: map['materialId'] ?? '',
      quantityNeeded: map['quantityNeeded'] ?? 0,
    );
  }
}

class PriceHistoryEntry {
  final double amount;
  final DateTime effectiveDate;
  final double previousAmount;
  final String changedBy;
  final String? reason;

  PriceHistoryEntry({
    required this.amount,
    required this.effectiveDate,
    required this.previousAmount,
    required this.changedBy,
    this.reason,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'effectiveDate': effectiveDate,
    'previousAmount': previousAmount,
    'changedBy': changedBy,
    'reason': reason,
  };
}
