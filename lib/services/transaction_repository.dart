import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/material_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _collection = FirebaseFirestore.instance.collection('transactions');
  CollectionReference _materials = FirebaseFirestore.instance.collection('materials');

  Stream<List<TransactionModel>> getTransactions() {
    return _collection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TransactionModel>> getTransactionsByStatus(String status) {
    return _collection
        .where('status', isEqualTo: status)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TransactionModel>> getRecentTransactions(int limit) {
    return _collection
        .orderBy('orderDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      return await _firestore.runTransaction((txn) async {
        // Reserve stock for each ingredient
        for (var ingredient in transaction.materialsUsed) {
          final materialRef = _materials.doc(ingredient.materialId);
          final materialDoc = await txn.get(materialRef);

          if (!materialDoc.exists) {
            throw Exception('Material not found: ${ingredient.materialName}');
          }

          var data = materialDoc.data() as Map<String, dynamic>;
          int currentQty = data['currentQuantity'] ?? 0;
          int reservedQty = data['reservedQuantity'] ?? 0;
          int available = currentQty - reservedQty;

          if (available < ingredient.quantityNeeded) {
            throw Exception(
              'Stok ${ingredient.materialName} tidak cukup! '
              'Tersedia: $available, Dibutuhkan: ${ingredient.quantityNeeded}'
            );
          }

          // Reserve stock (soft deduction)
          txn.update(materialRef, {
            'reservedQuantity': FieldValue.increment(ingredient.quantityNeeded),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Create the transaction
        final docRef = _collection.doc();
        txn.set(docRef, transaction.toMap());
        return docRef.id;
      });
    } catch (e) {
      throw Exception('Gagal membuat transaksi: $e');
    }
  }

  Future<void> completeTransaction(String transactionId) async {
    try {
      await _firestore.runTransaction((txn) async {
        final txDoc = await txn.get(_collection.doc(transactionId));
        
        if (!txDoc.exists) throw Exception('Transaksi tidak ditemukan');
        
        final data = txDoc.data() as Map<String, dynamic>;
        if (data['status'] != 'in_progress') {
          throw Exception('Transaksi tidak dalam status in_progress');
        }

        // Deduct stock permanently
        final materialsUsed = (data['materialsUsed'] as List?) ?? [];
        for (var ingredient in materialsUsed) {
          final materialRef = _materials.doc(ingredient['materialId']);
          final materialDoc = await txn.get(materialRef);
          
          if (!materialDoc.exists) continue;
          
          var matData = materialDoc.data() as Map<String, dynamic>;
          int currentQty = matData['currentQuantity'] ?? 0;
          int reservedQty = matData['reservedQuantity'] ?? 0;
          int qtyNeeded = ingredient['quantityNeeded'] ?? 0;

          // Verify stock is still sufficient
          int available = currentQty - reservedQty + qtyNeeded;
          if (currentQty < qtyNeeded) {
            throw Exception(
              'Stok ${ingredient['materialName']} tidak cukup saat penyelesaian!'
            );
          }

          // Final deduction
          txn.update(materialRef, {
            'currentQuantity': FieldValue.increment(-qtyNeeded),
            'reservedQuantity': FieldValue.increment(-qtyNeeded),
            'totalDeductions': FieldValue.increment(qtyNeeded),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Update transaction status
        txn.update(_collection.doc(transactionId), {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Gagal menyelesaikan transaksi: $e');
    }
  }

  Future<void> cancelTransaction(String transactionId, {String? reason}) async {
    try {
      await _firestore.runTransaction((txn) async {
        final txDoc = await txn.get(_collection.doc(transactionId));
        
        if (!txDoc.exists) throw Exception('Transaksi tidak ditemukan');
        
        final data = txDoc.data() as Map<String, dynamic>;
        if (data['status'] != 'in_progress') {
          throw Exception('Transaksi tidak dalam status in_progress');
        }

        // Release reserved stock (NO deduction)
        final materialsUsed = (data['materialsUsed'] as List?) ?? [];
        for (var ingredient in materialsUsed) {
          final materialRef = _materials.doc(ingredient['materialId']);
          int qtyNeeded = ingredient['quantityNeeded'] ?? 0;

          txn.update(materialRef, {
            'reservedQuantity': FieldValue.increment(-qtyNeeded),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Update transaction status
        txn.update(_collection.doc(transactionId), {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancelledReason': reason ?? 'Dibatalkan oleh pengguna',
        });
      });
    } catch (e) {
      throw Exception('Gagal membatalkan transaksi: $e');
    }
  }

  Future<double> getTodayRevenue() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final snapshot = await _collection
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += ((doc.data() as Map<String, dynamic>)['totalAmount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<int> getInProgressCount() async {
    final snapshot = await _collection
        .where('status', isEqualTo: 'in_progress')
        .get();
    return snapshot.size;
  }
}
