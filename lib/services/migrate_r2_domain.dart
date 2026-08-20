// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

/// Migration script: ganti semua image URL lama (r2.dev) ke custom domain baru.
///
/// OLD: https://pub-aa559cc93afa46d2a5e22181c59852f2.r2.dev
/// NEW: https://fkw.apicode.my.id
///
/// Cara pakai (jalankan dari dalam app, misal di-trigger via settings):
/// ```dart
/// import 'scripts/migrate_r2_domain.dart';
/// await migrateR2Domain();
/// ```
///
/// Atau panggil sekali dari main() sebelum runApp():
/// ```dart
/// await Firebase.initializeApp(...);
/// await migrateR2Domain();
/// runApp(...);
/// ```

const String _oldDomain = 'https://pub-aa559cc93afa46d2a5e22181c59852f2.r2.dev';
const String _newDomain = 'https://fkw.apicode.my.id';

Future<void> migrateR2Domain() async {
  final firestore = FirebaseFirestore.instance;

  print('Starting R2 domain migration...');
  print('  OLD: $_oldDomain');
  print('  NEW: $_newDomain');
  print('');

  int productsUpdated = 0;
  int transactionsUpdated = 0;
  int skipped = 0;

  // ─── 1. Migrate products.imageUrl ───
  print('--- Migrating products ---');
  final productsSnapshot = await firestore.collection('products').get();
  for (var doc in productsSnapshot.docs) {
    final data = doc.data();
    final imageUrl = data['imageUrl'] as String?;

    if (imageUrl == null || imageUrl.isEmpty) {
      skipped++;
      continue;
    }

    if (imageUrl.startsWith(_oldDomain)) {
      final newUrl = imageUrl.replaceFirst(_oldDomain, _newDomain);
      await doc.reference.update({'imageUrl': newUrl});
      productsUpdated++;
      print('  Product ${doc.id}: $imageUrl → $newUrl');
    } else {
      skipped++;
    }
  }

  // ─── 2. Migrate transactions.productImageUrl ───
  print('');
  print('--- Migrating transactions ---');
  final transactionsSnapshot = await firestore.collection('transactions').get();
  for (var doc in transactionsSnapshot.docs) {
    final data = doc.data();
    final productImageUrl = data['productImageUrl'] as String?;

    if (productImageUrl == null || productImageUrl.isEmpty) {
      skipped++;
      continue;
    }

    if (productImageUrl.startsWith(_oldDomain)) {
      final newUrl = productImageUrl.replaceFirst(_oldDomain, _newDomain);
      await doc.reference.update({'productImageUrl': newUrl});
      transactionsUpdated++;
      print('  Transaction ${doc.id}: $productImageUrl → $newUrl');
    } else {
      skipped++;
    }
  }

  print('');
  print('Migration complete!');
  print('  Products updated: $productsUpdated');
  print('  Transactions updated: $transactionsUpdated');
  print('  Skipped: $skipped');
}
