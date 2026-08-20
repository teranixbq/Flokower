// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

/// Backfill script: populate `productImageUrl` for existing transactions
/// 
/// Run this once to fix old transactions that don't have image URLs:
/// ```bash
/// dart run scripts/backfill_transaction_images.dart
/// ```
Future<void> main() async {
  final firestore = FirebaseFirestore.instance;
  
  print('Starting backfill of transaction image URLs...');
  
  // Get all transactions
  final transactionsSnapshot = await firestore.collection('transactions').get();
  final transactions = transactionsSnapshot.docs;
  
  print('Found ${transactions.length} transactions');
  
  // Get all products
  final productsSnapshot = await firestore.collection('products').get();
  final productsMap = <String, String?>{};
  for (var doc in productsSnapshot.docs) {
    final data = doc.data();
    productsMap[doc.id] = data['imageUrl'] as String?;
  }
  
  print('Found ${productsMap.length} products');
  
  int updated = 0;
  int skipped = 0;
  
  for (var txDoc in transactions) {
    final txData = txDoc.data();
    final productId = txData['productId'] as String?;
    final existingImageUrl = txData['productImageUrl'] as String?;
    
    // Skip if already has image URL
    if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      skipped++;
      continue;
    }
    
    // Skip if no product ID
    if (productId == null) {
      print('  Transaction ${txDoc.id} has no productId, skipping');
      skipped++;
      continue;
    }
    
    // Look up product image
    final productImageUrl = productsMap[productId];
    if (productImageUrl == null) {
      print('  Product $productId not found or has no image, skipping transaction ${txDoc.id}');
      skipped++;
      continue;
    }
    
    // Update transaction
    await txDoc.reference.update({'productImageUrl': productImageUrl});
    updated++;
    print('  Updated transaction ${txDoc.id} with image from product $productId');
  }
  
  print('');
  print('Backfill complete!');
  print('  Updated: $updated transactions');
  print('  Skipped: $skipped transactions');
}
