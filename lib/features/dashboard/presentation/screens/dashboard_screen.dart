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
      backgroundColor: FlokowerTheme.offWhite,
      appBar: AppBar(
        backgroundColor: FlokowerTheme.offWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/flokower-logo.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Flokower', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 16.0),
            child: const SettingsButton(),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Bento Grid Row 1: Revenue (60%) + 2 Stacked Cards (40%) ───
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: _RevenueCard(
                        todayRevenue: transactions.todayRevenue,
                        todayCompletedCount: transactions.todayCompletedCount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Jumlah Bahan',
                              value: '${materials.totalMaterials}',
                              color: FlokowerTheme.accentBlue,
                              icon: Icons.inventory_2_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _MetricCard(
                              label: 'Bahan Menipis',
                              value: '${materials.lowStockCount}',
                              color: materials.lowStockCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.accentGreen,
                              icon: Icons.warning_amber_rounded,
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
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Produk Aktif',
                        value: '${products.activeProductsCount}',
                        color: FlokowerTheme.accentGreen,
                        icon: Icons.local_florist_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Order Proses',
                        value: '${transactions.inProgressCount}',
                        color: transactions.inProgressCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.mediumGray,
                        icon: Icons.pending_actions_outlined,
                      ),
                    ),
                  ],
                ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
        boxShadow: [
          BoxShadow(
            color: FlokowerTheme.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlokowerTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: FlokowerTheme.black, letterSpacing: -1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
