import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/theme/flokower_theme.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: FlokowerTheme.black, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.local_florist, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Flokower'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.settings_outlined, color: FlokowerTheme.darkGray),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              offset: const Offset(0, 48),
              onSelected: (value) async {
                if (value == 'logout') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar?', style: TextStyle(fontWeight: FontWeight.w700)),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Keluar', style: TextStyle(color: FlokowerTheme.accentRed, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: FlokowerTheme.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Pengguna',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.black),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(enabled: false, height: 1, child: Divider(height: 1)),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: FlokowerTheme.accentRed, size: 20),
                      SizedBox(width: 10),
                      Text('Keluar', style: TextStyle(color: FlokowerTheme.accentRed, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Greeting ───
              Text(
                'Selamat datang 👋',
                style: TextStyle(fontSize: 14, color: FlokowerTheme.mediumGray, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                user?.displayName ?? 'Pengguna',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: FlokowerTheme.black),
              ),
              const SizedBox(height: 24),

              // ─── Bento Metrics Grid ───
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Jumlah Bahan',
                      value: '${materials.totalMaterials}',
                      subtitle: 'jenis bahan baku',
                      color: FlokowerTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Bahan Menipis',
                      value: '${materials.lowStockCount}',
                      subtitle: materials.lowStockCount > 0 ? 'perlu restock!' : 'semua aman',
                      color: materials.lowStockCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Produk Aktif',
                      value: '${products.activeProductsCount}',
                      subtitle: 'siap dijual',
                      color: FlokowerTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Order Proses',
                      value: '${transactions.inProgressCount}',
                      subtitle: 'sedang dikerjakan',
                      color: transactions.inProgressCount > 0 ? FlokowerTheme.accentOrange : FlokowerTheme.mediumGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Revenue Card ───
              _RevenueCard(),
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
                        child: Icon(
                          tx.isCompleted ? Icons.check_rounded : tx.isCancelled ? Icons.close_rounded : Icons.hourglass_empty_rounded,
                          size: 20,
                          color: tx.isCompleted ? FlokowerTheme.accentGreen : tx.isCancelled ? FlokowerTheme.accentRed : FlokowerTheme.accentOrange,
                        ),
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').where('status', isEqualTo: 'completed').snapshots(),
      builder: (context, snapshot) {
        double todayRevenue = 0;
        int totalCompleted = 0;
        if (snapshot.hasData) {
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalCompleted++;
            final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
            if (completedAt != null && completedAt.isAfter(startOfDay)) {
              todayRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0;
            }
          }
        }
        
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
              Row(
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
                  Text('$totalCompleted order selesai', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Pendapatan', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Rp ${_fmt(todayRevenue)}',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
            ],
          ),
        );
      },
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
  final String subtitle;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.subtitle, required this.color});

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
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: FlokowerTheme.black, letterSpacing: -1)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
        ],
      ),
    );
  }
}
