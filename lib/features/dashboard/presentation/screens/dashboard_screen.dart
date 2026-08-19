import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/settings_button.dart';
import '../../../inventory/presentation/providers/material_provider.dart';
import '../../../inventory/presentation/providers/product_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(materialProvider);
    final products = ref.watch(productProvider);
    final transactions = ref.watch(transactionProvider);

    /// Ambil URL gambar produk: pakai `productImageUrl` kalau ada,
    /// fallback ke lookup dari koleksi produk (untuk transaksi lama).
    String? getProductImageUrl(String? txImageUrl, String productId) {
      if (txImageUrl != null && txImageUrl.isNotEmpty) return txImageUrl;
      try {
        return products.products.firstWhere((p) => p.id == productId).imageUrl;
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/flokower-logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Flokower'),
          ],
        ),
        actions: const [SettingsButton()],
      ),
      body: RefreshIndicator(
        color: FlokowerTheme.black,
        onRefresh: () async {
          ref.read(materialProvider.notifier).loadMaterials();
          ref.read(productProvider.notifier).loadProducts();
          ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Bento Grid Row 1: Revenue (60%) + 2 Stacked Cards (40%) ───
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _RevenueCard(
                        todayRevenue: transactions.todayRevenue,
                        todayCompletedCount: transactions.todayCompletedCount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Jumlah Bahan',
                              value: '${materials.totalMaterials}',
                              color: FlokowerTheme.accentBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _MetricCard(
                              label: 'Bahan Menipis',
                              value: '${materials.lowStockCount}',
                              color: materials.lowStockCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ─── Bento Grid Row 2: 2 Equal Cards ───
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Produk Aktif',
                      value: '${products.activeProductsCount}',
                      color: FlokowerTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Order Proses',
                      value: '${transactions.inProgressCount}',
                      color: transactions.inProgressCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.mediumGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Recent Transactions ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                  if (transactions.transactions.isNotEmpty)
                    Text('${transactions.transactions.length} total', style: const TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                ],
              ),
              const SizedBox(height: 12),
              if (transactions.transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: FlokowerTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FlokowerTheme.silver),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 40, color: FlokowerTheme.lightGray),
                      const SizedBox(height: 12),
                      const Text('Belum ada transaksi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 4),
                      Text('Buat order pertama Anda', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                    ],
                  ),
                )
              else
                ...transactions.transactions.take(5).map((tx) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FlokowerTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: tx.isCompleted ? FlokowerTheme.accentGreenLight : tx.isCancelled ? FlokowerTheme.accentRedLight : FlokowerTheme.accentOrangeLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: () {
                          final imgUrl = getProductImageUrl(tx.productImageUrl, tx.productId);
                          if (imgUrl != null && imgUrl.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  tx.isCompleted ? Icons.check_rounded : tx.isCancelled ? Icons.close_rounded : Icons.hourglass_empty_rounded,
                                  size: 20,
                                  color: tx.isCompleted ? FlokowerTheme.accentGreen : tx.isCancelled ? FlokowerTheme.accentRed : FlokowerTheme.accentOrange,
                                ),
                              ),
                            );
                          }
                          return Icon(
                            tx.isCompleted ? Icons.check_rounded : tx.isCancelled ? Icons.close_rounded : Icons.hourglass_empty_rounded,
                            size: 20,
                            color: tx.isCompleted ? FlokowerTheme.accentGreen : tx.isCancelled ? FlokowerTheme.accentRed : FlokowerTheme.accentOrange,
                          );
                        }(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FlokowerTheme.black)),
                            const SizedBox(height: 2),
                            Text(
                              '${tx.orderDate.day}/${tx.orderDate.month} • Qty: ${tx.quantity}',
                              style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${_fmt(tx.totalAmount)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tx.isCompleted ? FlokowerTheme.accentGreenLight : tx.isCancelled ? FlokowerTheme.accentRedLight : FlokowerTheme.accentOrangeLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tx.isCompleted ? 'Selesai' : tx.isCancelled ? 'Batal' : 'Proses',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: tx.isCompleted ? FlokowerTheme.accentGreen : tx.isCancelled ? FlokowerTheme.accentRed : FlokowerTheme.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _RevenueCard extends StatelessWidget {
  final double todayRevenue;
  final int todayCompletedCount;

  const _RevenueCard({
    required this.todayRevenue,
    required this.todayCompletedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlokowerTheme.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          const Text('Pendapatan', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            'Rp ${_fmt(todayRevenue)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlokowerTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: FlokowerTheme.black, letterSpacing: -1)),
        ],
      ),
    );
  }
}
