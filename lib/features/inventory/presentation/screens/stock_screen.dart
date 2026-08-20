import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/flokower_theme.dart';
import '../../../../shared/models/material_model.dart';
import '../../../../shared/models/product_model.dart';
import '../providers/material_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/material_form.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/stock_adjust_dialog.dart';
import '../../../../shared/widgets/settings_button.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlokowerTheme.offWhite,
      appBar: AppBar(
        title: const Text('Stok'),
        actions: const [SettingsButton()],
      ),
      body: Column(
        children: [
          // ─── White unified area (header matches tab bg) ───
          Container(
            color: FlokowerTheme.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    _TabSegment(
                      label: 'Bahan Baku',
                      isActive: _tabController.index == 0,
                      onTap: () => _tabController.animateTo(0),
                    ),
                    _TabSegment(
                      label: 'Produk',
                      isActive: _tabController.index == 1,
                      onTap: () => _tabController.animateTo(1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ─── Swipeable tab content (offWhite bg) ───
          Expanded(
            child: Container(
              color: FlokowerTheme.offWhite,
              child: TabBarView(
                controller: _tabController,
                children: const [_MaterialsTab(), _ProductsTab()],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showMaterialForm(context, null);
          } else {
            _showProductForm(context, null);
          }
        },
        backgroundColor: FlokowerTheme.accentTeal,
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

// ─────────────────────────────────────────────────────────
// Pill-style tab segment
// ─────────────────────────────────────────────────────────
class _TabSegment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? FlokowerTheme.accentTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : FlokowerTheme.darkGray,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BAHAN BAKU TAB — simple list cards
// ─────────────────────────────────────────────────────────
class _MaterialsTab extends ConsumerWidget {
  const _MaterialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(materialProvider);

    if (state.materials.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56, color: FlokowerTheme.lightGray),
            SizedBox(height: 16),
            Text('Belum ada bahan baku',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlokowerTheme.darkGray)),
            SizedBox(height: 6),
            Text('Tekan + untuk menambahkan',
                style: TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: state.materials.length,
      itemBuilder: (context, index) {
        final material = state.materials[index];
        return GestureDetector(
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (ctx) => StockAdjustDialog(material: material),
            );
            if (result == 'edit' && context.mounted) {
              try {
                final latest =
                    ref.read(materialProvider.notifier).materialById(material.id);
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (ctx) => MaterialForm(material: latest));
                }
              } catch (_) {
                // bahan sudah dihapus
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: FlokowerTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDEDED)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // ─── Circular icon ───
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    material.unit == 'lembar'
                        ? Icons.layers_outlined
                        : Icons.eco_outlined,
                    color: FlokowerTheme.accentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // ─── Name + stock info ───
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: FlokowerTheme.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        material.reservedQuantity > 0
                            ? '${material.currentQuantity} ${material.unit} \u2022 reserved: ${material.reservedQuantity}'
                            : '${material.currentQuantity} ${material.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: FlokowerTheme.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRODUK TAB — compact 2-column grid (matches design)
// ─────────────────────────────────────────────────────────
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);

    if (state.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist_outlined,
                size: 56, color: FlokowerTheme.lightGray),
            SizedBox(height: 16),
            Text('Belum ada produk',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlokowerTheme.darkGray)),
            SizedBox(height: 6),
            Text('Tekan + untuk menambahkan',
                style:
                    TextStyle(fontSize: 13, color: FlokowerTheme.mediumGray)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        final hasImage =
            product.imageUrl != null && product.imageUrl!.isNotEmpty;
        return GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (ctx) => ProductFormDialog(product: product)),
          child: Container(
            decoration: BoxDecoration(
              color: FlokowerTheme.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFEDEDED)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Image (square via AspectRatio, fills top area) ───
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: FlokowerTheme.offWhite,
                          child: hasImage
                              ? Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      const _ProductImagePlaceholder(),
                                )
                              : const _ProductImagePlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
                // ─── Name + Price (compact bottom section) ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FlokowerTheme.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${_fmt(product.price)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FlokowerTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    return n
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlokowerTheme.offWhite,
      child: const Center(
        child:
            Icon(Icons.local_florist_rounded, size: 32, color: FlokowerTheme.lightGray),
      ),
    );
  }
}
