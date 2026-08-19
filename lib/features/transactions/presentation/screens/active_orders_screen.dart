import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../presentation/providers/transaction_provider.dart';
import '../../../inventory/presentation/providers/product_provider.dart';

class ActiveOrdersScreen extends ConsumerStatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  ConsumerState<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends ConsumerState<ActiveOrdersScreen> {
  final Set<String> _processingIds = {};

  /// Ambil URL gambar produk: pakai `productImageUrl` kalau ada,
  /// fallback ke lookup dari koleksi produk (untuk transaksi lama).
  String? _getProductImageUrl(TransactionModel tx) {
    if (tx.productImageUrl != null && tx.productImageUrl!.isNotEmpty) {
      return tx.productImageUrl;
    }
    try {
      final product = ref.read(productProvider.notifier).productById(tx.productId);
      return product.imageUrl;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider).inProgressTransactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Dalam Proses')),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: FlokowerTheme.accentGreenLight, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.check_circle_rounded, size: 36, color: FlokowerTheme.accentGreen),
                  ),
                  const SizedBox(height: 20),
                  const Text('Semua Beres!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                  const SizedBox(height: 6),
                  Text('Tidak ada order yang sedang diproses', style: TextStyle(fontSize: 14, color: FlokowerTheme.mediumGray)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final duration = DateTime.now().difference(tx.orderDate);
                final hours = duration.inHours;
                final minutes = duration.inMinutes % 60;
                final isLong = hours >= 2;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: FlokowerTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isLong ? FlokowerTheme.accentOrange.withOpacity(0.4) : const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: isLong ? FlokowerTheme.accentOrangeLight : FlokowerTheme.accentBlueLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Builder(builder: (_) {
                                    final imgUrl = _getProductImageUrl(tx);
                                    return imgUrl != null && imgUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _FallbackIcon(isLong: isLong)),
                                          )
                                        : _FallbackIcon(isLong: isLong);
                                  }),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.productName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                                      Text('${hours}j ${minutes}m lalu • Qty: ${tx.quantity}', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLong ? FlokowerTheme.accentOrangeLight : FlokowerTheme.accentOrangeLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(isLong ? 'Lama!' : 'Proses', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isLong ? FlokowerTheme.accentOrange : FlokowerTheme.accentOrange)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Price
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: FlokowerTheme.offWhite, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total', style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
                                  Text('Rp ${_fmt(tx.totalAmount)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                                ],
                              ),
                            ),
                            if (tx.customerName != null) ...[
                              const SizedBox(height: 8),
                              Row(children: [
                                Icon(Icons.person_outline_rounded, size: 14, color: FlokowerTheme.mediumGray),
                                const SizedBox(width: 4),
                                Text(tx.customerName!, style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                              ]),
                            ],

                            // Materials
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6, runSpacing: 6,
                              children: tx.materialsUsed.map((m) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: FlokowerTheme.offWhite, borderRadius: BorderRadius.circular(6)),
                                child: Text('${m.materialName}: ${m.quantityNeeded}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: FlokowerTheme.darkGray)),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _processingIds.contains(tx.id) ? null : () => _cancelOrder(context, ref, tx),
                                icon: _processingIds.contains(tx.id)
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.close_rounded, size: 18),
                                label: const Text('Batalkan'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: FlokowerTheme.accentRed,
                                  side: const BorderSide(color: FlokowerTheme.accentRed),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _processingIds.contains(tx.id) ? null : () => _completeOrder(context, ref, tx),
                                icon: _processingIds.contains(tx.id)
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.check_rounded, size: 18),
                                label: const Text('Selesai'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FlokowerTheme.accentGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _completeOrder(BuildContext context, WidgetRef ref, TransactionModel tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Order?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Stok bahan akan dikurangi permanen untuk ${tx.productName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: FlokowerTheme.accentGreen),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _processingIds.add(tx.id));
      try {
        await ref.read(transactionProvider.notifier).completeTransaction(tx.id);
        if (context.mounted) showToast(context, message: 'Order selesai! Stok telah diperbarui.', type: ToastType.success);
      } catch (e) {
        if (context.mounted) showToast(context, message: 'Error: $e', type: ToastType.error);
      } finally {
        if (mounted) setState(() => _processingIds.remove(tx.id));
      }
    }
  }

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref, TransactionModel tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Order?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Stok bahan akan dikembalikan. Tidak ada pengurangan stok.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: FlokowerTheme.accentRed),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _processingIds.add(tx.id));
      try {
        await ref.read(transactionProvider.notifier).cancelTransaction(tx.id);
        if (context.mounted) showToast(context, message: 'Order dibatalkan. Stok dikembalikan.', type: ToastType.warning);
      } catch (e) {
        if (context.mounted) showToast(context, message: 'Error: $e', type: ToastType.error);
      } finally {
        if (mounted) setState(() => _processingIds.remove(tx.id));
      }
    }
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _FallbackIcon extends StatelessWidget {
  final bool isLong;
  const _FallbackIcon({required this.isLong});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.hourglass_empty_rounded,
      color: isLong ? FlokowerTheme.accentOrange : FlokowerTheme.accentBlue,
      size: 22,
    );
  }
}
