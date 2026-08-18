import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final filtered = _filter == 'all' ? txState.transactions : txState.transactions.where((t) => t.status == _filter).toList();
    final completed = filtered.where((t) => t.isCompleted).toList();
    final totalRevenue = completed.fold(0.0, (sum, t) => sum + t.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: FlokowerTheme.white,
            child: Row(
              children: [
                Expanded(child: _SummaryTile(title: 'Pendapatan', value: 'Rp ${_fmt(totalRevenue)}', color: FlokowerTheme.accentGreen)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryTile(title: 'Selesai', value: '${completed.length}', color: FlokowerTheme.accentBlue)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryTile(title: 'Batal', value: '${filtered.where((t) => t.isCancelled).length}', color: FlokowerTheme.accentRed)),
              ],
            ),
          ),

          // Filters
          Container(
            color: FlokowerTheme.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'Semua', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Selesai', selected: _filter == 'completed', onTap: () => setState(() => _filter = 'completed')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Proses', selected: _filter == 'in_progress', onTap: () => setState(() => _filter = 'in_progress')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Batal', selected: _filter == 'cancelled', onTap: () => setState(() => _filter = 'cancelled')),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48, color: FlokowerTheme.lightGray),
                        const SizedBox(height: 12),
                        Text('Belum ada transaksi', style: TextStyle(fontSize: 14, color: FlokowerTheme.mediumGray)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final dateStr = '${tx.orderDate.day}/${tx.orderDate.month}/${tx.orderDate.year} ${tx.orderDate.hour.toString().padLeft(2, '0')}:${tx.orderDate.minute.toString().padLeft(2, '0')}';
                      
                      return Container(
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
                                size: 18,
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
                                  Text('$dateStr • Qty: ${tx.quantity}', style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
                                  if (tx.customerName != null)
                                    Text('👤 ${tx.customerName}', style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rp ${_fmt(tx.totalAmount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tx.isCompleted ? FlokowerTheme.accentGreenLight : tx.isCancelled ? FlokowerTheme.accentRedLight : FlokowerTheme.accentOrangeLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tx.isCompleted ? 'Selesai' : tx.isCancelled ? 'Batal' : 'Proses',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tx.isCompleted ? FlokowerTheme.accentGreen : tx.isCancelled ? FlokowerTheme.accentRed : FlokowerTheme.accentOrange),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryTile({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlokowerTheme.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FlokowerTheme.black, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? FlokowerTheme.black : FlokowerTheme.offWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : FlokowerTheme.darkGray)),
      ),
    );
  }
}
