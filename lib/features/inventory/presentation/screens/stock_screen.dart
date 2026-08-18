import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../shared/widgets/settings_button.dart';
import '../../../../shared/models/material_model.dart';
import '../../../../shared/models/product_model.dart';
import '../providers/material_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/material_form.dart';
import '../widgets/product_form_dialog.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok'),
        actions: const [SettingsButton()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bahan Baku'),
            Tab(text: 'Produk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MaterialsTab(), _ProductsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showMaterialForm(context, null);
          } else {
            _showProductForm(context, null);
          }
        },
        backgroundColor: FlokowerTheme.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showMaterialForm(BuildContext context, Material? material) {
    showDialog(context: context, builder: (ctx) => MaterialForm(material: material));
  }

  void _showProductForm(BuildContext context, Product? product) {
    showDialog(context: context, builder: (ctx) => ProductFormDialog(product: product));
  }
}

class _MaterialsTab extends ConsumerWidget {
  const _MaterialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(materialProvider);

    if (state.materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: FlokowerTheme.lightGray),
            const SizedBox(height: 16),
            const Text('Belum ada bahan baku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
            const SizedBox(height: 6),
            Text('Tekan + untuk menambahkan', style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.materials.length,
      itemBuilder: (context, index) {
        final material = state.materials[index];
        return GestureDetector(
          onTap: () => showDialog(context: context, builder: (ctx) => MaterialForm(material: material)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlokowerTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: material.isLowStock ? FlokowerTheme.accentOrange.withOpacity(0.4) : const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: material.isLowStock ? FlokowerTheme.accentOrangeLight : FlokowerTheme.accentBlueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    material.unit == 'lembar' ? Icons.layers_outlined : Icons.eco_outlined,
                    color: material.isLowStock ? FlokowerTheme.accentOrange : FlokowerTheme.accentBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FlokowerTheme.black)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('${material.currentQuantity} ${material.unit}', style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
                          if (material.reservedQuantity > 0) ...[
                            Text(' • reserved: ${material.reservedQuantity}', style: const TextStyle(fontSize: 11, color: FlokowerTheme.accentOrange)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (material.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FlokowerTheme.accentOrangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Menipis', style: TextStyle(fontSize: 11, color: FlokowerTheme.accentOrange, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: FlokowerTheme.lightGray, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist_outlined, size: 56, color: FlokowerTheme.lightGray),
            const SizedBox(height: 16),
            const Text('Belum ada produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FlokowerTheme.darkGray)),
            const SizedBox(height: 6),
            Text('Tekan + untuk menambahkan', style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return GestureDetector(
          onTap: () => showDialog(context: context, builder: (ctx) => ProductFormDialog(product: product)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlokowerTheme.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: product.isActive ? const Color(0xFFEEEEEE) : FlokowerTheme.accentRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // Product image or placeholder
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: product.isActive ? FlokowerTheme.accentGreenLight : FlokowerTheme.offWhite,
                    borderRadius: BorderRadius.circular(12),
                    image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? Icon(Icons.local_florist_rounded, color: product.isActive ? FlokowerTheme.accentGreen : FlokowerTheme.lightGray, size: 24)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FlokowerTheme.black)),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} • ${product.ingredients.length} bahan',
                        style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray),
                      ),
                    ],
                  ),
                ),
                if (!product.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: FlokowerTheme.accentRedLight, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Nonaktif', style: TextStyle(fontSize: 11, color: FlokowerTheme.accentRed, fontWeight: FontWeight.w600)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: FlokowerTheme.accentGreenLight, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Aktif', style: TextStyle(fontSize: 11, color: FlokowerTheme.accentGreen, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: FlokowerTheme.lightGray, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
