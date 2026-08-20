import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/settings_button.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../inventory/presentation/providers/product_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _filter = 'all';

  /// Ambil URL gambar produk: pakai `productImageUrl` kalau ada,
  /// fallback ke lookup dari koleksi produk (untuk transaksi lama).
  String? _getProductImageUrl(TransactionModel tx) {
    if (tx.productImageUrl != null && tx.productImageUrl!.isNotEmpty) {
      return tx.productImageUrl;
    }
    try {
      final products = ref.read(productProvider).products;
      return products.firstWhere((p) => p.id == tx.productId).imageUrl;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);

    // Stats dihitung dari SEMUA transaksi (tidak terpengaruh filter)
    final allCompleted =
        txState.transactions.where((t) => t.isCompleted).toList();
    final allCancelled =
        txState.transactions.where((t) => t.isCancelled).toList();
    final totalRevenue =
        allCompleted.fold(0.0, (sum, t) => sum + t.totalAmount);

    // Filter hanya mempengaruhi list di bawah
    final filtered = _filter == 'all'
        ? txState.transactions
        : txState.transactions
            .where((t) => t.status == _filter)
            .toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Laporan Penjualan'),
          actions: const [SettingsButton()]),
      body: Column(
        children: [
          // ─── Summary cards section ───
          Container(
            width: double.infinity,
            color: FlokowerTheme.offWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Summary: 3 cards (Pendapatan besar kiri, Selesai+Batal stacked kanan) ───
                IntrinsicHeight(
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Pendapatan card (60% width) ───
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FlokowerTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Label + green dot
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: FlokowerTheme.accentGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Pendapatan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FlokowerTheme.mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Big nominal value (teal)
                            Text(
                              CurrencyInputFormatter.display(totalRevenue),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: FlokowerTheme.accentTeal,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle
                            Text(
                              '${allCompleted.length} transaksi selesai',
                              style: const TextStyle(
                                fontSize: 11,
                                color: FlokowerTheme.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Green wave decoration
                            CustomPaint(
                              size: const Size(double.infinity, 20),
                              painter: _WavePainter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // ─── Selesai + Batal stacked (40% width) ───
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Selesai card — count atas, label bawah, dot kanan atas
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FlokowerTheme.accentBlueLight,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Dot kanan atas
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: FlokowerTheme.accentBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                // Count + label
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${allCompleted.length}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: FlokowerTheme.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Selesai',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: FlokowerTheme.mediumGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Batal card — count atas, label bawah, dot kanan atas
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FlokowerTheme.accentRedLight,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Dot kanan atas
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: FlokowerTheme.accentRed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                // Count + label
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${allCancelled.length}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: FlokowerTheme.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: FlokowerTheme.mediumGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),

          // ─── Filter chips container (off-white bg with shadow) ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: FlokowerTheme.offWhite,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                      label: 'Semua',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                      label: 'Selesai',
                      selected: _filter == 'completed',
                      onTap: () =>
                          setState(() => _filter = 'completed')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                      label: 'Dalam Proses',
                      selected: _filter == 'in_progress',
                      onTap: () =>
                          setState(() => _filter = 'in_progress')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                      label: 'Dibatalkan',
                      selected: _filter == 'cancelled',
                      onTap: () =>
                          setState(() => _filter = 'cancelled')),
                ),
              ],
            ),
          ),

          // ─── Transaction List (off-white bg) ───
          Expanded(
            child: Container(
              color: FlokowerTheme.offWhite,
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 48, color: FlokowerTheme.lightGray),
                          SizedBox(height: 12),
                          Text('Belum ada transaksi',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: FlokowerTheme.mediumGray)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
                        final dateStr =
                            '${tx.orderDate.day}/${tx.orderDate.month}/${tx.orderDate.year} ${tx.orderDate.hour.toString().padLeft(2, '0')}:${tx.orderDate.minute.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: FlokowerTheme.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // ─── Image (50x50, rounded 10) ───
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: tx.isCompleted
                                      ? FlokowerTheme.accentGreenLight
                                      : tx.isCancelled
                                          ? FlokowerTheme.accentRedLight
                                          : FlokowerTheme.accentOrangeLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Builder(builder: (_) {
                                  final imgUrl = _getProductImageUrl(tx);
                                  if (imgUrl != null &&
                                      imgUrl.isNotEmpty) {
                                    return ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) => Icon(
                                          tx.isCompleted
                                              ? Icons.check_rounded
                                              : tx.isCancelled
                                                  ? Icons.close_rounded
                                                  : Icons
                                                      .hourglass_empty_rounded,
                                          size: 20,
                                          color: tx.isCompleted
                                              ? FlokowerTheme.accentGreen
                                              : tx.isCancelled
                                                  ? FlokowerTheme.accentRed
                                                  : FlokowerTheme
                                                      .accentOrange,
                                        ),
                                      ),
                                    );
                                  }
                                  return Icon(
                                    tx.isCompleted
                                        ? Icons.check_rounded
                                        : tx.isCancelled
                                            ? Icons.close_rounded
                                            : Icons.hourglass_empty_rounded,
                                    size: 20,
                                    color: tx.isCompleted
                                        ? FlokowerTheme.accentGreen
                                        : tx.isCancelled
                                            ? FlokowerTheme.accentRed
                                            : FlokowerTheme.accentOrange,
                                  );
                                }),
                              ),
                              const SizedBox(width: 12),
                              // ─── Middle column: Nama → Tanggal/Qty → Rp ───
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.productName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: FlokowerTheme.black)),
                                    const SizedBox(height: 2),
                                    Text('$dateStr \u2022 Qty: ${tx.quantity}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color:
                                                FlokowerTheme.mediumGray)),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyInputFormatter.display(
                                          tx.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: FlokowerTheme.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ─── Right: Status badge ONLY ───
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tx.isCompleted
                                      ? FlokowerTheme.accentGreenLight
                                      : tx.isCancelled
                                          ? FlokowerTheme.accentRedLight
                                          : FlokowerTheme.accentOrangeLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tx.isCompleted
                                      ? 'Selesai'
                                      : tx.isCancelled
                                          ? 'Batal'
                                          : 'Proses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: tx.isCompleted
                                        ? FlokowerTheme.accentGreen
                                        : tx.isCancelled
                                            ? FlokowerTheme.accentRed
                                            : FlokowerTheme.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Green wave decoration painter
// ─────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FlokowerTheme.accentGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.1,
      size.width * 0.3, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.45, size.height * 0.9,
      size.width * 0.6, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.0,
      size.width * 0.9, size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────
// Filter chip widget (teal active)
// ─────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? FlokowerTheme.accentTeal : FlokowerTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : FlokowerTheme.darkGray,
          ),
        ),
      ),
    );
  }
}
