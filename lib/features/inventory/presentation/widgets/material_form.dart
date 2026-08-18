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

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameController.text = widget.material!.name;
      _selectedUnit = widget.material!.unit;
      _quantityController.text = widget.material!.currentQuantity.toString();
      _thresholdController.text = widget.material!.threshold.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final material = Material(
        id: widget.material?.id ?? '',
        name: _nameController.text.trim(),
        unit: _selectedUnit,
        currentQuantity: int.parse(_quantityController.text.isEmpty ? '0' : _quantityController.text),
        initialQuantity: widget.material == null
            ? int.parse(_quantityController.text.isEmpty ? '0' : _quantityController.text)
            : widget.material!.initialQuantity,
        threshold: int.parse(_thresholdController.text.isEmpty ? '10' : _thresholdController.text),
        createdAt: widget.material?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await ref.read(materialProvider.notifier).updateMaterial(material);
      } else {
        await ref.read(materialProvider.notifier).addMaterial(material);
      }

      if (mounted) {
        Navigator.pop(context, true);
        showToast(context, message: isEditing ? 'Bahan berhasil diperbarui!' : 'Bahan berhasil ditambahkan!', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) showToast(context, message: 'Error: $e', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 480,
          minWidth: MediaQuery.of(context).size.width > 600 ? 480 : MediaQuery.of(context).size.width,
        ),
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
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
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
                      onPressed: _submit,
                      child: Text(isEditing ? 'Perbarui' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
