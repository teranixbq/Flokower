import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/models/product_model.dart';
import '../../../inventory/presentation/providers/product_provider.dart';
import '../../../inventory/presentation/providers/material_provider.dart';
import 'create_order_screen.dart';

class ProductGalleryScreen extends ConsumerStatefulWidget {
  final List<Product>? initialSelectedProducts;

  const ProductGalleryScreen({super.key, this.initialSelectedProducts});

  @override
  ConsumerState<ProductGalleryScreen> createState() => _ProductGalleryScreenState();
}

class _ProductGalleryScreenState extends ConsumerState<ProductGalleryScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize with previously selected products if provided
    if (widget.initialSelectedProducts != null) {
      for (var product in widget.initialSelectedProducts!) {
        _selectedProductIds.add(product.id);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _checkStockAvailable(Product product) {
    final materials = ref.read(materialProvider).materials;
    final stockMap = <String, int>{};
    for (var m in materials) {
      stockMap[m.id] = m.availableQuantity;
    }
    return product.hasSufficientStock(stockMap);
  }

  void _toggleProductSelection(Product product) {
    final hasStock = _checkStockAvailable(product);
    
    if (!hasStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok tidak cukup untuk ${product.name}'),
          backgroundColor: FlokowerTheme.accentOrange,
        ),
      );
      return;
    }

    setState(() {
      if (_selectedProductIds.contains(product.id)) {
        _selectedProductIds.remove(product.id);
      } else {
        _selectedProductIds.add(product.id);
      }
    });
  }

  void _proceedToOrder() {
    final products = ref.read(productProvider).products;
    final selectedProducts = products.where((p) => _selectedProductIds.contains(p.id)).toList();
    
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 produk'),
          backgroundColor: FlokowerTheme.accentOrange,
        ),
      );
      return;
    }

    // If we have initial selected products, we're editing mode - return the updated selection
    if (widget.initialSelectedProducts != null) {
      Navigator.pop(context, selectedProducts);
    } else {
      // First time selection - push to order screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateOrderScreen(selectedProducts: selectedProducts),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider).products.where((p) => p.isActive).toList();
    
    final filteredProducts = _searchQuery.isEmpty
        ? products
        : products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialSelectedProducts != null ? 'Ubah Produk' : 'Pilih Produk'),
        actions: [
          if (_selectedProductIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FlokowerTheme.accentGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_selectedProductIds.length} dipilih',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Product grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: FlokowerTheme.lightGray),
                        const SizedBox(height: 16),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: FlokowerTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isSelected = _selectedProductIds.contains(product.id);
                      final hasStock = _checkStockAvailable(product);

                      return GestureDetector(
                        onTap: () => _toggleProductSelection(product),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlokowerTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? FlokowerTheme.accentGreen : const Color(0xFFEEEEEE),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Product image
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                        Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: FlokowerTheme.lightGray.withOpacity(0.3),
                                              child: Icon(Icons.image_not_supported, size: 40, color: FlokowerTheme.lightGray),
                                            );
                                          },
                                        )
                                      else
                                        Container(
                                          color: FlokowerTheme.lightGray.withOpacity(0.3),
                                          child: Icon(Icons.image, size: 40, color: FlokowerTheme.lightGray),
                                        ),
                                      
                                      // Selection indicator
                                      if (isSelected)
                                        Container(
                                          color: FlokowerTheme.accentGreen.withOpacity(0.3),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check_circle,
                                              color: FlokowerTheme.accentGreen,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      
                                      // Disabled overlay for insufficient stock
                                      if (!hasStock)
                                        Container(
                                          color: FlokowerTheme.lightGray.withOpacity(0.5),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: FlokowerTheme.accentOrange,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Stok Tidak Cukup',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Product name
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: hasStock ? FlokowerTheme.darkGray : FlokowerTheme.lightGray,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: _selectedProductIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FlokowerTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _proceedToOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlokowerTheme.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
