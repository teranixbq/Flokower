import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/material_model.dart';
import '../providers/material_provider.dart';

/// Dialog ubah stok cepat saat bahan diklik dari list.
///
/// Menampilkan jumlah saat ini + stepper (− / +) untuk menambah
/// atau mengurangi stok. Mengembalikan:
/// - `null`  → ditutup tanpa aksi
/// - `'edit'` → user ingin membuka form edit detail bahan
class StockAdjustDialog extends ConsumerStatefulWidget {
  final Material material;
  const StockAdjustDialog({super.key, required this.material});

  @override
  ConsumerState<StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends ConsumerState<StockAdjustDialog> {
  late final TextEditingController _deltaController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _deltaController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  /// Ambil data bahan terbaru dari provider (stok bisa berubah real-time).
  Material get _material {
    try {
      return ref.read(materialProvider.notifier).materialById(widget.material.id);
    } catch (_) {
      return widget.material;
    }
  }

  int get _delta => int.tryParse(_deltaController.text.trim()) ?? 0;

  int _minDelta(Material m) => -(m.currentQuantity - m.reservedQuantity);

  void _step(int change) {
    final m = _material;
    final next = (_delta + change).clamp(_minDelta(m), 999999);
    setState(() => _deltaController.text = '$next');
  }

  Future<void> _save() async {
    final m = _material;
    final delta = _delta;

    if (delta == 0) {
      Navigator.pop(context);
      return;
    }

    final newQty = m.currentQuantity + delta;
    if (newQty < m.reservedQuantity) {
      showToast(context, message: 'Stok tidak boleh kurang dari reserved (${m.reservedQuantity})!', type: ToastType.warning);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = m.copyWith(
        currentQuantity: newQty,
        totalAdditions: m.totalAdditions + (delta > 0 ? delta : 0),
        totalDeductions: m.totalDeductions + (delta < 0 ? -delta : 0),
        updatedAt: DateTime.now(),
      );
      await ref.read(materialProvider.notifier).updateMaterial(updated);
      if (mounted) {
        Navigator.pop(context);
        showToast(context, message: 'Stok "${m.name}" sekarang $newQty ${m.unit}', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showToast(context, message: 'Gagal menyimpan: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _material;
    final delta = _delta;
    final newQty = m.currentQuantity + delta;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Header ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: m.isLowStock ? FlokowerTheme.accentOrangeLight : FlokowerTheme.accentBlueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        m.unit == 'lembar' ? Icons.layers_outlined : Icons.eco_outlined,
                        color: m.isLowStock ? FlokowerTheme.accentOrange : FlokowerTheme.accentBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                          const SizedBox(height: 2),
                          Text('Stok: ${m.currentQuantity} ${m.unit}', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: FlokowerTheme.mediumGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ─── Body ───
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Jumlah saat ini
                    const Text('Jumlah saat ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FlokowerTheme.mediumGray, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: FlokowerTheme.offWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${m.currentQuantity} ${m.unit}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                          if (m.reservedQuantity > 0)
                            Text('reserved: ${m.reservedQuantity}', style: const TextStyle(fontSize: 11, color: FlokowerTheme.accentOrange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tambah / ubah stok
                    const Text('+ Tambah stok', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FlokowerTheme.mediumGray, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: FlokowerTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: FlokowerTheme.silver),
                      ),
                      child: Row(
                        children: [
                          _StepButton(
                            icon: Icons.remove_rounded,
                            enabled: delta > _minDelta(m),
                            onTap: () => _step(-1),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _deltaController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                                LengthLimitingTextInputFormatter(6),
                              ],
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: FlokowerTheme.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          Text(m.unit, style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                          const SizedBox(width: 8),
                          _StepButton(icon: Icons.add_rounded, enabled: true, onTap: () => _step(1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Preview stok baru
                    Row(
                      children: [
                        Text(
                          delta == 0
                              ? 'Stok tidak berubah'
                              : 'Stok baru: $newQty ${m.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: delta > 0
                                ? FlokowerTheme.accentGreen
                                : delta < 0
                                    ? FlokowerTheme.accentRed
                                    : FlokowerTheme.mediumGray,
                          ),
                        ),
                        if (delta < 0) ...[
                          const SizedBox(width: 6),
                          Text('(mengurangi stok)', style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
                        ],
                      ],
                    ),
                    if (m.reservedQuantity > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Stok tidak bisa kurang dari reserved (${m.reservedQuantity} ${m.unit})',
                        style: TextStyle(fontSize: 11, color: FlokowerTheme.lightGray),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),

              // ─── Footer ───
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _isSaving ? null : () => Navigator.pop(context, 'edit'),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit detail', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: enabled ? FlokowerTheme.offWhite : FlokowerTheme.offWhite.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? FlokowerTheme.silver : Colors.transparent),
        ),
        child: Icon(icon, size: 20, color: enabled ? FlokowerTheme.black : FlokowerTheme.lightGray),
      ),
    );
  }
}
