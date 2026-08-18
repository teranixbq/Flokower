import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/material_model.dart';
import '../../../inventory/presentation/providers/material_provider.dart';
import '../../../inventory/presentation/providers/product_provider.dart';
import '../../presentation/providers/transaction_provider.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  Product? _selectedProduct;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _checkStockAvailable(Product product) {
    final materials = ref.read(materialProvider).materials;
    final stockMap = <String, int>{};
    for (var m in materials) { stockMap[m.id] = m.availableQuantity; }
    return product.hasSufficientStock(stockMap);
  }

  String _getMaterialName(String id) {
    try { return ref.read(materialProvider.notifier).materialById(id).name; } catch (e) { return id; }
  }

  Future<void> _submitOrder() async {
    if (_selectedProduct == null) {
      showToast(context, message: 'Pilih produk terlebih dahulu', type: ToastType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final materials = ref.read(materialProvider).materials;
      final stockMap = <String, int>{};
      for (var m in materials) { stockMap[m.id] = m.availableQuantity; }

      final List<TransactionIngredient> ingredients = [];
      for (final ing in _selectedProduct!.ingredients) {
        final needed = ing.quantityNeeded * _quantity;
        final available = stockMap[ing.materialId] ?? 0;
        if (available < needed) {
          throw Exception('Stok ${_getMaterialName(ing.materialId)} tidak cukup! Tersedia: $available, Dibutuhkan: $needed');
        }
        ingredients.add(TransactionIngredient(materialId: ing.materialId, materialName: _getMaterialName(ing.materialId), quantityNeeded: needed));
      }

      final transaction = TransactionModel(
        id: '',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        productPriceAtSale: _selectedProduct!.price,
        quantity: _quantity,
        totalAmount: _selectedProduct!.price * _quantity,
        status: 'in_progress',
        customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isEmpty ? null : _customerPhoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        materialsUsed: ingredients,
        orderDate: DateTime.now(),
        startedAt: DateTime.now(),
        createdBy: 'user',
      );

      await ref.read(transactionProvider.notifier).createTransaction(transaction);

      if (mounted) {
        Navigator.pop(context, true);
        showToast(context, message: 'Order berhasil dibuat! Status: Dalam Proses', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) showToast(context, message: '$e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider).products.where((p) => p.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Order Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product selector
            const Text('Pilih Produk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: FlokowerTheme.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Product>(
                  value: _selectedProduct,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(14),
                  hint: Text('-- Pilih Produk --', style: TextStyle(color: FlokowerTheme.mediumGray)),
                  items: products.map((Product p) {
                    final hasStock = _checkStockAvailable(p);
                    return DropdownMenuItem<Product>(
                      value: p,
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: hasStock ? FlokowerTheme.accentGreenLight : FlokowerTheme.accentRedLight,
                              borderRadius: BorderRadius.circular(8),
                              image: p.imageUrl != null ? DecorationImage(image: NetworkImage(p.imageUrl!), fit: BoxFit.cover) : null,
                            ),
                            child: p.imageUrl == null
                                ? Icon(hasStock ? Icons.check_rounded : Icons.close_rounded, size: 16, color: hasStock ? FlokowerTheme.accentGreen : FlokowerTheme.accentRed)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Text('Rp ${_fmt(p.price)}', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Product? v) => setState(() => _selectedProduct = v),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quantity
            const Text('Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: FlokowerTheme.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEEEEEE))),
              child: Row(
                children: [
                  _QtyButton(icon: Icons.remove_rounded, onTap: _quantity > 1 ? () => setState(() => _quantity--) : null),
                  const Spacer(),
                  Text('$_quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: FlokowerTheme.black)),
                  const Spacer(),
                  _QtyButton(icon: Icons.add_rounded, onTap: () => setState(() => _quantity++)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ingredients preview
            if (_selectedProduct != null) ...[
              const Text('Bahan yang Dibutuhkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
              const SizedBox(height: 10),
              ..._selectedProduct!.ingredients.map((ing) {
                final name = _getMaterialName(ing.materialId);
                final needed = ing.quantityNeeded * _quantity;
                try {
                  final mat = ref.read(materialProvider.notifier).materialById(ing.materialId);
                  final available = mat.availableQuantity;
                  final isEnough = available >= needed;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlokowerTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isEnough ? const Color(0xFFEEEEEE) : FlokowerTheme.accentRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: isEnough ? FlokowerTheme.accentGreenLight : FlokowerTheme.accentRedLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(isEnough ? Icons.check_rounded : Icons.close_rounded, size: 18, color: isEnough ? FlokowerTheme.accentGreen : FlokowerTheme.accentRed),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FlokowerTheme.black)),
                              Text('Tersedia: $available ${mat.unit}', style: TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEnough ? FlokowerTheme.accentGreenLight : FlokowerTheme.accentRedLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Butuh: $needed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isEnough ? FlokowerTheme.accentGreen : FlokowerTheme.accentRed)),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  return Container(margin: const EdgeInsets.only(bottom: 8), child: Text(name));
                }
              }),
              const SizedBox(height: 12),

              // Total
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: FlokowerTheme.black, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('Rp ${_fmt(_selectedProduct!.price * _quantity)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Customer info
            const Text('Info Pelanggan (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(hintText: 'Nama pelanggan', prefixIcon: const Icon(Icons.person_outline_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _customerPhoneController,
              decoration: InputDecoration(hintText: 'No. WhatsApp', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(hintText: 'Catatan khusus', prefixIcon: const Icon(Icons.note_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Buat Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: onTap != null ? FlokowerTheme.offWhite : FlokowerTheme.offWhite.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: onTap != null ? FlokowerTheme.black : FlokowerTheme.lightGray),
      ),
    );
  }
}
