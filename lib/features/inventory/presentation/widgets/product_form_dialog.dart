import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/material_model.dart';
import '../providers/product_provider.dart';
import '../providers/material_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  List<ProductIngredient> _selectedIngredients = [];

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toStringAsFixed(0);
      _descriptionController.text = widget.product!.description ?? '';
      _imageUrlController.text = widget.product!.imageUrl ?? '';
      _selectedIngredients = widget.product!.ingredients.toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  String _getMaterialName(String materialId) {
    try {
      return ref.read(materialProvider.notifier).materialById(materialId).name;
    } catch (e) {
      return materialId;
    }
  }

  Future<void> _showMaterialPicker() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => Consumer(builder: (context, ref, child) {
        final materials = ref.watch(materialProvider).materials;
        final searchController = TextEditingController();
        
        return StatefulBuilder(builder: (context, setDialogState) {
          final query = searchController.text.toLowerCase();
          final filtered = query.isEmpty
              ? materials
              : materials.where((m) => m.name.toLowerCase().contains(query)).toList();
              
          return AlertDialog(
            title: const Text('Pilih Bahan', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari bahan...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final m = filtered[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: FlokowerTheme.accentBlueLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(m.unit == 'lembar' ? Icons.layers_outlined : Icons.eco_outlined, size: 18, color: FlokowerTheme.accentBlue),
                          ),
                          title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${m.availableQuantity} ${m.unit} tersedia', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                          onTap: () => Navigator.pop(ctx, {'materialId': m.id}),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }),
    );

    if (result != null && mounted) {
      final qtyResult = await showDialog<int>(
        context: context,
        builder: (ctx) {
          final qtyController = TextEditingController();
          return AlertDialog(
            title: const Text('Jumlah Dibutuhkan', style: TextStyle(fontWeight: FontWeight.w700)),
            content: TextField(
              controller: qtyController,
              decoration: InputDecoration(
                hintText: 'Contoh: 10',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, int.tryParse(qtyController.text)),
                child: const Text('Tambah'),
              ),
            ],
          );
        },
      );

      if (qtyResult != null && qtyResult > 0) {
        setState(() {
          _selectedIngredients.add(ProductIngredient(
            materialId: result['materialId'],
            quantityNeeded: qtyResult,
          ));
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIngredients.isEmpty) {
      showToast(context, message: 'Minimal pilih 1 bahan!', type: ToastType.warning);
      return;
    }

    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.isEmpty ? '0' : _priceController.text),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        isActive: true,
        ingredients: _selectedIngredients,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await ref.read(productProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productProvider.notifier).addProduct(product);
      }

      if (mounted) {
        Navigator.pop(context, true);
        showToast(context, message: isEditing ? 'Produk berhasil diperbarui!' : 'Produk berhasil ditambahkan!', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) showToast(context, message: 'Error: $e', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85, maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(isEditing ? 'Edit Produk' : 'Tambah Produk Baru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
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
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image URL
                      const Text('Foto Produk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: FlokowerTheme.offWhite,
                              borderRadius: BorderRadius.circular(12),
                              image: _imageUrlController.text.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(_imageUrlController.text), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Icon(Icons.image_outlined, color: FlokowerTheme.lightGray, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                hintText: 'URL gambar produk (opsional)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name
                      const Text('Nama Produk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Teddy Bear Bouquet',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama harus diisi' : null,
                      ),
                      const SizedBox(height: 16),

                      // Price
                      const Text('Harga Jual', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: '150000',
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(color: FlokowerTheme.mediumGray, fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Harga harus diisi';
                          if (double.tryParse(v) == null) return 'Angka tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text('Deskripsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Detail produk (opsional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Ingredients section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bahan yang Dibutuhkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
                          TextButton.icon(
                            onPressed: _showMaterialPicker,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Tambah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_selectedIngredients.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: FlokowerTheme.offWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 32, color: FlokowerTheme.lightGray),
                              const SizedBox(height: 8),
                              Text('Belum ada bahan', style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
                            ],
                          ),
                        )
                      else
                        ..._selectedIngredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ing = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: FlokowerTheme.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: FlokowerTheme.accentGreenLight, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.eco_outlined, size: 16, color: FlokowerTheme.accentGreen),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_getMaterialName(ing.materialId), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.black)),
                                      Text('${ing.quantityNeeded} unit', style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _selectedIngredients.removeAt(i)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close_rounded, size: 18, color: FlokowerTheme.accentRed),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
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
