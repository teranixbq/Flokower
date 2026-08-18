import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/material_model.dart';

class MaterialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _collection = FirebaseFirestore.instance.collection('materials');

  // Get all materials
  Stream<List<Material>> getMaterials() {
    return _collection
        .orderBy('name', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Material.fromFirestore(doc)).toList());
  }

  // Filter by unit type
  Stream<List<Material>> getMaterialsByUnit(String unit) {
    return _collection
        .where('unit', isEqualTo: unit)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Material.fromFirestore(doc)).toList());
  }

  // Search materials
  Stream<List<Material>> searchMaterials(String query) {
    return _collection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + '\uf8ff')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Material.fromFirestore(doc)).toList());
  }

  // Get single material
  Future<Material?> getMaterial(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();
      if (doc.exists) {
        return Material.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get material: $e');
    }
  }

  // Create new material
  Future<String> createMaterial(Material material) async {
    try {
      DocumentReference docRef = await _collection.add(material.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create material: $e');
    }
  }

  // Update material
  Future<void> updateMaterial(Material material) async {
    try {
      await _collection.doc(material.id).update({
        'name': material.name,
        'unit': material.unit,
        'currentQuantity': material.currentQuantity,
        'reservedQuantity': material.reservedQuantity,
        'threshold': material.threshold,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  // Delete material
  Future<void> deleteMaterial(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }

  // Reserve stock for in-progress order
  Future<void> reserveStock(List<Map<String, dynamic>> ingredients) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var ingredient in ingredients) {
        String materialId = ingredient['materialId'];
        int quantityNeeded = ingredient['quantity'];
        
        DocumentReference ref = _collection.doc(materialId);
        batch.update(ref, {
          'reservedQuantity': FieldValue.increment(quantityNeeded),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reserve stock: $e');
    }
  }

  // Release reserved stock when cancelled
  Future<void> releaseStock(List<Map<String, dynamic>> ingredients) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var ingredient in ingredients) {
        String materialId = ingredient['materialId'];
        int quantityReserve = ingredient['quantityReserve'];
        
        DocumentReference ref = _collection.doc(materialId);
        batch.update(ref, {
          'reservedQuantity': FieldValue.increment(-quantityReserve),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to release stock: $e');
    }
  }

  // Deduct stock on completion
  Future<void> deductStock(List<Map<String, dynamic>> ingredients) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var ingredient in ingredients) {
        String materialId = ingredient['materialId'];
        int quantityDeduct = ingredient['quantity'];
        bool isCustomMapping = ingredient['isCustomMapping'] ?? false;
        
        DocumentReference ref = _collection.doc(materialId);
        Map<String, dynamic> updates = {};
        
        if (isCustomMapping) {
          updates['totalDeductions'] = FieldValue.increment(quantityDeduct);
        } else {
          // For standard mapping, only decrement current
          updates['currentQuantity'] = FieldValue.increment(-quantityDeduct);
          updates['reservedQuantity'] = FieldValue.increment(-quantityDeduct);
        }
        
        batch.update(ref, updates);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to deduct stock: $e');
    }
  }

  // Check if sufficient stock available
  Future<bool> hasSufficientStock(List<Map<String, dynamic>> ingredients) async {
    try {
      for (var ingredient in ingredients) {
        String materialId = ingredient['materialId'];
        int quantityNeeded = ingredient['quantityNeeded'];
        
        DocumentSnapshot doc = await _collection.doc(materialId).get();
        if (!doc.exists) {
          return false;
        }
        
        var data = doc.data() as Map<String, dynamic>;
        int currentQty = data['currentQuantity'] ?? 0;
        int reservedQty = data['reservedQuantity'] ?? 0;
        int available = currentQty - reservedQty;
        
        if (available < quantityNeeded) {
          return false;
        }
      }
      return true;
    } catch (e) {
      throw Exception('Failed to check stock: $e');
    }
  }
}
