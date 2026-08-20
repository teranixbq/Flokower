import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../inventory/presentation/providers/material_provider.dart';
import '../../presentation/providers/transaction_provider.dart';
import 'product_gallery_screen.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final List<Product> selectedProducts;

  const CreateOrderScreen({super.key, required this.selectedProducts});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final Map<String, int> _productQuantities = {};
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize all quantities to 1
    for (var product in widget.selectedProducts) {
      _productQuantities[product.id] = 1;
    }
  }

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
    final quantity = _productQuantities[product.id] ?? 1;
    final adjustedIngredients = product.ingredients.map((ing) {
      return ing.copyWith(quantityNeeded: ing.quantityNeeded * quantity);
    }).toList();
    final adjustedProduct = product.copyWith(ingredients: adjustedIngredients);
    return adjustedProduct.hasSufficientStock(stockMap);
  }

  bool _checkIfCanIncrease(Product product) {
    final materials = ref.read(materialProvider).materials;
    final stockMap = <String, int>{};
    for (var m in materials) { stockMap[m.id] = m.availableQuantity; }
    final currentQuantity = _productQuantities[product.id] ?? 1;
    final nextQuantity = currentQuantity + 1;
    final adjustedIngredients = product.ingredients.map((ing) {
      return ing.copyWith(quantityNeeded: ing.quantityNeeded * nextQuantity);
    }).toList();
    final adjustedProduct = product.copyWith(ingredients: adjustedIngredients);
    return adjustedProduct.hasSufficientStock(stockMap);
  }

  void _removeProduct(Product product) {
    setState(() {
      widget.selectedProducts.remove(product);
      _productQuantities.remove(product.id);
    });
  }

  bool _checkAggregatedStockAvailable() {
    final materials = ref.read(materialProvider).materials;
    final stockMap = <String, int>{};
    for (var m in materials) {
      stockMap[m.id] = m.availableQuantity;
    }

    // Aggregate all ingredients from all products with their quantities
    final Map<String, int> aggregatedNeeds = {};
    for (final product in widget.selectedProducts) {
      final quantity = _productQuantities[product.id] ?? 1;
      for (final ing in product.ingredients) {
        final needed = ing.quantityNeeded * quantity;
        aggregatedNeeds[ing.materialId] = (aggregatedNeeds[ing.materialId] ?? 0) + needed;
      }
    }

    // Check if aggregated needs can be fulfilled
    for (final entry in aggregatedNeeds.entries) {
      final available = stockMap[entry.key] ?? 0;
      if (available < entry.value) {
        return false;
      }
    }

    return true;
  }

  bool _hasAnyInsufficientStock() {
    return !_checkAggregatedStockAvailable();
  }

  String _getMaterialName(String id) {
    try { return ref.read(materialProvider.notifier).materialById(id).name; } catch (e) { return id; }
  }

  Future<void> _submitOrder() async {
    if (widget.selectedProducts.isEmpty) {
      showToast(context, message: 'Pilih produk terlebih dahulu', type: ToastType.warning);
      return;
    }

    if (_hasAnyInsufficientStock()) {
      showToast(context, message: 'Ada produk dengan stok tidak cukup', type: ToastType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final materials = ref.read(materialProvider).materials;
      final stockMap = <String, int>{};
      for (var m in materials) { stockMap[m.id] = m.availableQuantity; }

      // Create a transaction for each product
      for (final product in widget.selectedProducts) {
        final quantity = _productQuantities[product.id] ?? 1;
        
        final List<TransactionIngredient> ingredients = [];
        for (final ing in product.ingredients) {
          final needed = ing.quantityNeeded * quantity;
          final available = stockMap[ing.materialId] ?? 0;
          if (available < needed) {
            throw Exception('Stok ${_getMaterialName(ing.materialId)} tidak cukup untuk ${product.name}! Tersedia: $available, Dibutuhkan: $needed');
          }
          ingredients.add(TransactionIngredient(materialId: ing.materialId, materialName: _getMaterialName(ing.materialId), quantityNeeded: needed));
        }

        final transaction = TransactionModel(
          id: '',
          productId: product.id,
          productName: product.name,
          productImageUrl: product.imageUrl,
          productPriceAtSale: product.price,
          quantity: quantity,
          totalAmount: product.price * quantity,
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
        
        // Update stock map for next product
        for (final ing in ingredients) {
          stockMap[ing.materialId] = (stockMap[ing.materialId] ?? 0) - ing.quantityNeeded;
        }
      }

      if (mounted) {
        // Pop back to home screen (MainScreen) instead of just ProductGalleryScreen
        Navigator.of(context).popUntil((route) => route.isFirst);
        showToast(context, message: '${widget.selectedProducts.length} order berhasil dibuat! Status: Dalam Proses', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) showToast(context, message: '$e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Order Baru'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Ubah Produk'),
            onPressed: () async {
              final result = await Navigator.push<List<Product>>(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductGalleryScreen(
                    initialSelectedProducts: widget.selectedProducts,
                  ),
                ),
              );
              
              if (result != null && mounted) {
                setState(() {
                  widget.selectedProducts.clear();
                  widget.selectedProducts.addAll(result);
                  
                  // Reset quantities for products that are still selected
                  _productQuantities.removeWhere((productId, _) => 
                    !result.any((p) => p.id == productId));
                  
                  // Initialize quantities for new products
                  for (var product in result) {
                    if (!_productQuantities.containsKey(product.id)) {
                      _productQuantities[product.id] = 1;
                    }
                  }
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selected products with quantity controls
            const Text('Produk Dipilih', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
            const SizedBox(height: 10),
            ...widget.selectedProducts.map((product) {
              final quantity = _productQuantities[product.id] ?? 1;
              final hasStock = _checkStockAvailable(product);
              final canIncrease = _checkIfCanIncrease(product);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FlokowerTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hasStock ? const Color(0xFFEEEEEE) : FlokowerTheme.accentRed.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    // Product info
                    Row(
                      children: [
                        // Product image
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: FlokowerTheme.offWhite,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.image, color: FlokowerTheme.lightGray),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              if (!hasStock)
                                const Text('Stok tidak cukup', style: TextStyle(fontSize: 12, color: FlokowerTheme.accentRed)),
                            ],
                          ),
                        ),
                        // Delete button - only show when there's more than 1 product
                        if (widget.selectedProducts.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: FlokowerTheme.accentRed),
                            onPressed: () => _removeProduct(product),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quantity control
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: FlokowerTheme.offWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove_rounded,
                            onTap: quantity > 1 ? () => setState(() => _productQuantities[product.id] = quantity - 1) : null,
                          ),
                          const Spacer(),
                          Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: FlokowerTheme.black)),
                          const Spacer(),
                          _QtyButton(
                            icon: Icons.add_rounded,
                            onTap: canIncrease ? () => setState(() => _productQuantities[product.id] = quantity + 1) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 8),

            // Ingredients preview for all products
            const Text('Bahan yang Dibutuhkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FlokowerTheme.black)),
            const SizedBox(height: 10),
            ..._getAggregatedIngredients().map((ing) {
              final name = _getMaterialName(ing.materialId);
              try {
                final mat = ref.read(materialProvider.notifier).materialById(ing.materialId);
                final available = mat.availableQuantity;
                final isEnough = available >= ing.quantityNeeded;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlokowerTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isEnough ? const Color(0xFFEEEEEE) : FlokowerTheme.accentRed.withValues(alpha: 0.3)),
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
                            Text('Tersedia: $available ${mat.unit}', style: const TextStyle(fontSize: 12, color: FlokowerTheme.mediumGray)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEnough ? FlokowerTheme.accentGreenLight : FlokowerTheme.accentRedLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Butuh: ${ing.quantityNeeded}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isEnough ? FlokowerTheme.accentGreen : FlokowerTheme.accentRed)),
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
                  Text('Rp ${_fmt(_calculateTotal())}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                onPressed: _isSubmitting || _hasAnyInsufficientStock() || widget.selectedProducts.isEmpty ? null : _submitOrder,
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : widget.selectedProducts.isEmpty
                        ? const Text('Pilih Produk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))
                        : Text('Buat ${widget.selectedProducts.length} Order', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<TransactionIngredient> _getAggregatedIngredients() {
    final Map<String, int> aggregated = {};
    final Map<String, String> names = {};
    
    for (final product in widget.selectedProducts) {
      final quantity = _productQuantities[product.id] ?? 1;
      for (final ing in product.ingredients) {
        final needed = ing.quantityNeeded * quantity;
        aggregated[ing.materialId] = (aggregated[ing.materialId] ?? 0) + needed;
        names[ing.materialId] = _getMaterialName(ing.materialId);
      }
    }
    
    return aggregated.entries.map((e) => TransactionIngredient(materialId: e.key, materialName: names[e.key] ?? '', quantityNeeded: e.value)).toList();
  }

  double _calculateTotal() {
    double total = 0;
    for (final product in widget.selectedProducts) {
      final quantity = _productQuantities[product.id] ?? 1;
      total += product.price * quantity;
    }
    return total;
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
          color: onTap != null ? FlokowerTheme.offWhite : FlokowerTheme.offWhite.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: onTap != null ? FlokowerTheme.black : FlokowerTheme.lightGray),
      ),
    );
  }
}
