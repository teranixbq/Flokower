import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/material_model.dart';
import '../providers/material_provider.dart';

class MaterialForm extends ConsumerStatefulWidget {
  final Material? material;
  const MaterialForm({super.key, this.material});

  @override
  ConsumerState<MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends ConsumerState<MaterialForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedUnit = 'lembar';
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController(text: '10');
  bool _isSaving = false;
  bool _isNameDuplicate = false;

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameController.text = widget.material!.name;
      _selectedUnit = widget.material!.unit;
      _quantityController.text = widget.material!.currentQuantity.toString();
      _thresholdController.text = widget.material!.threshold.toString();
      _checkNameDuplicate(widget.material!.name);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _checkNameDuplicate(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      setState(() => _isNameDuplicate = false);
      return;
    }

    final notifier = ref.read(materialProvider.notifier);
    final existing = notifier.findByName(trimmedName);
    
    // Jika editing, abaikan material yang sedang diedit
    if (isEditing && existing?.id == widget.material!.id) {
      setState(() => _isNameDuplicate = false);
    } else {
      setState(() => _isNameDuplicate = existing != null);
    }
  }

  bool get _isFormValid {
    return !_isNameDuplicate && !_isSaving;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final dialogContext = context;
    final notifier = ref.read(materialProvider.notifier);
    final newName = _nameController.text.trim();

    try {
      final newQty = int.parse(_quantityController.text.isEmpty ? '0' : _quantityController.text);
      final reserved = widget.material?.reservedQuantity ?? 0;

      // Prevent setting quantity below reserved amount
      if (newQty < reserved) {
        showToast(dialogContext, message: 'Jumlah tidak boleh kurang dari reserved ($reserved)!', type: ToastType.warning);
        return;
      }

      // ─── Cegah duplikasi bahan ───
      // Saat buat baru: jika nama sudah ada, JANGAN buat bahan baru —
      // tambahkan saja stoknya ke bahan yang sudah ada.
      if (!isEditing) {
        final existing = notifier.findByName(newName);
        if (existing != null) {
          if (existing.unit != _selectedUnit) {
            showToast(
              dialogContext,
              message: 'Bahan "${existing.name}" sudah ada dengan satuan ${existing.unit}. Gunakan bahan yang sudah ada untuk menambah stok.',
              type: ToastType.error,
            );
            return;
          }
          final confirmed = await showDialog<bool>(
            context: dialogContext,
            builder: (ctx) => AlertDialog(
              title: const Text('Bahan Sudah Ada', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              content: Text(
                'Bahan "${existing.name}" sudah ada dengan stok ${existing.currentQuantity} ${existing.unit}.\n\n'
                'Tambahkan $newQty ${existing.unit} ke bahan yang sudah ada?',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tambahkan')),
              ],
            ),
          );
          if (confirmed != true) return;

          final merged = existing.copyWith(
            currentQuantity: existing.currentQuantity + newQty,
            totalAdditions: existing.totalAdditions + newQty,
            updatedAt: DateTime.now(),
          );
          await notifier.updateMaterial(merged);
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext, true);
            showToast(
              dialogContext,
              message: 'Stok "${existing.name}" ditambahkan $newQty ${existing.unit} (total: ${merged.currentQuantity})',
              type: ToastType.success,
            );
          }
          return;
        }
      } else {
        // Saat edit: nama tidak boleh sama dengan bahan LAIN
        final clash = notifier.findByName(newName);
        if (clash != null && clash.id != widget.material!.id) {
          showToast(dialogContext, message: 'Nama bahan sudah dipakai oleh "${clash.name}"!', type: ToastType.error);
          return;
        }
      }

      final material = Material(
        id: widget.material?.id ?? '',
        name: newName,
        unit: _selectedUnit,
        currentQuantity: newQty,
        reservedQuantity: reserved,
        initialQuantity: widget.material == null ? newQty : widget.material!.initialQuantity,
        totalAdditions: widget.material?.totalAdditions ?? 0,
        totalDeductions: widget.material?.totalDeductions ?? 0,
        threshold: int.parse(_thresholdController.text.isEmpty ? '10' : _thresholdController.text),
        createdAt: widget.material?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await ref.read(materialProvider.notifier).updateMaterial(material);
      } else {
        await ref.read(materialProvider.notifier).addMaterial(material);
      }

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext, true);
        showToast(dialogContext, message: isEditing ? 'Bahan berhasil diperbarui!' : 'Bahan berhasil ditambahkan!', type: ToastType.success);
      }
    } catch (e) {
      if (dialogContext.mounted) {
        showToast(dialogContext, message: 'Gagal menyimpan: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Bahan' : 'Tambah Bahan Baru',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: FlokowerTheme.black),
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

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Nama Bahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Mawar Merah',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          errorText: _isNameDuplicate ? 'Nama bahan sudah ada' : null,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama harus diisi';
                          if (_isNameDuplicate) return 'Nama bahan sudah ada';
                          return null;
                        },
                        onChanged: _checkNameDuplicate,
                      ),
                      const SizedBox(height: 20),
                      const Text('Satuan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _UnitChip(label: 'Lembar', icon: Icons.layers_outlined, selected: _selectedUnit == 'lembar', onTap: () => setState(() => _selectedUnit = 'lembar')),
                          const SizedBox(width: 10),
                          _UnitChip(label: 'Tangkai', icon: Icons.eco_outlined, selected: _selectedUnit == 'tangkai', onTap: () => setState(() => _selectedUnit = 'tangkai')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Jumlah Stok', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: _selectedUnit,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Jumlah harus diisi';
                          if (int.tryParse(v) == null) return 'Angka tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Batas Peringatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 4),
                      Text('Notifikasi muncul jika stok di bawah angka ini', style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _thresholdController,
                        decoration: InputDecoration(
                          hintText: '10',
                          suffixText: _selectedUnit,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Batas harus diisi';
                          if (int.tryParse(v) == null) return 'Angka tidak valid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _submit : null,
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEditing ? 'Perbarui' : 'Simpan'),
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

class _UnitChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UnitChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? FlokowerTheme.black : FlokowerTheme.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? FlokowerTheme.black : FlokowerTheme.silver),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : FlokowerTheme.darkGray),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : FlokowerTheme.darkGray)),
            ],
          ),
        ),
      ),
    );
  }
}
