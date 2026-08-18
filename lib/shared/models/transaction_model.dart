import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String productId;
  final String productName;
  final double productPriceAtSale;
  final int quantity;
  final double totalAmount;
  final String status; // in_progress, completed, cancelled
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final bool useCustomMapping;
  final List<TransactionIngredient> materialsUsed;
  final DateTime orderDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final String createdBy;

  TransactionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPriceAtSale,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.useCustomMapping = false,
    required this.materialsUsed,
    required this.orderDate,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledReason,
    required this.createdBy,
  });

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    final materialsList = (data['materialsUsed'] as List?)?.map((m) {
      return TransactionIngredient(
        materialId: m['materialId'] ?? '',
        materialName: m['materialName'] ?? '',
        quantityNeeded: m['quantityNeeded'] ?? 0,
      );
    }).toList() ?? [];

    return TransactionModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productPriceAtSale: (data['productPriceAtSale'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'in_progress',
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
      notes: data['notes'],
      useCustomMapping: data['useCustomMapping'] ?? false,
      materialsUsed: materialsList,
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancelledReason: data['cancelledReason'],
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPriceAtSale': productPriceAtSale,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
      'useCustomMapping': useCustomMapping,
      'materialsUsed': materialsUsed.map((m) => m.toMap()).toList(),
      'orderDate': Timestamp.fromDate(orderDate),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancelledReason': cancelledReason,
      'createdBy': createdBy,
    };
  }

  TransactionModel copyWith({
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelledReason,
  }) {
    return TransactionModel(
      id: id,
      productId: productId,
      productName: productName,
      productPriceAtSale: productPriceAtSale,
      quantity: quantity,
      totalAmount: totalAmount,
      status: status ?? this.status,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes,
      useCustomMapping: useCustomMapping,
      materialsUsed: materialsUsed,
      orderDate: orderDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      createdBy: createdBy,
    );
  }
}

class TransactionIngredient {
  final String materialId;
  final String materialName;
  final int quantityNeeded;

  TransactionIngredient({
    required this.materialId,
    required this.materialName,
    required this.quantityNeeded,
  });

  Map<String, dynamic> toMap() => {
    'materialId': materialId,
    'materialName': materialName,
    'quantityNeeded': quantityNeeded,
  };
}
