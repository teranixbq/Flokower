import 'package:cloud_firestore/cloud_firestore.dart';

class Material {
  final String id;
  final String name;
  final String unit; // "lembar" or "tangkai"
  final int currentQuantity;
  final int reservedQuantity;
  final int initialQuantity;
  final int totalAdditions;
  final int totalDeductions;
  final int threshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  Material({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    this.reservedQuantity = 0,
    this.initialQuantity = 0,
    this.totalAdditions = 0,
    this.totalDeductions = 0,
    this.threshold = 10,
    required this.createdAt,
    required this.updatedAt,
  });

  int get availableQuantity => currentQuantity - reservedQuantity;

  bool get isLowStock => currentQuantity <= threshold;

  factory Material.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Material(
      id: doc.id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? 'lembar',
      currentQuantity: data['currentQuantity'] ?? 0,
      reservedQuantity: data['reservedQuantity'] ?? 0,
      initialQuantity: data['initialQuantity'] ?? 0,
      totalAdditions: data['totalAdditions'] ?? 0,
      totalDeductions: data['totalDeductions'] ?? 0,
      threshold: data['threshold'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'currentQuantity': currentQuantity,
      'reservedQuantity': reservedQuantity,
      'initialQuantity': initialQuantity,
      'totalAdditions': totalAdditions,
      'totalDeductions': totalDeductions,
      'threshold': threshold,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Material copyWith({
    String? id,
    String? name,
    String? unit,
    int? currentQuantity,
    int? reservedQuantity,
    int? initialQuantity,
    int? totalAdditions,
    int? totalDeductions,
    int? threshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      totalAdditions: totalAdditions ?? this.totalAdditions,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      threshold: threshold ?? this.threshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Material(id: $id, name: $name, unit: $unit, quantity: $currentQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Material &&
        other.id == id &&
        other.name == name &&
        other.unit == unit;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ unit.hashCode;
}
