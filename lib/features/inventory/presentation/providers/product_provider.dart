import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/product_repository.dart';
import '../../../../shared/models/product_model.dart';

class ProductState {
  final List<Product> products;
  final List<Product> activeProducts;
  final bool isLoading;
  final String? error;

  const ProductState({this.products = const [], this.activeProducts = const [], this.isLoading = false, this.error});

  ProductState copyWith({List<Product>? products, List<Product>? activeProducts, bool? isLoading, String? error}) {
    return ProductState(
      products: products ?? this.products,
      activeProducts: activeProducts ?? this.activeProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalProducts => products.length;
  int get activeProductsCount => activeProducts.length;
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;
  ProductNotifier(this._repository) : super(const ProductState());

  Future<void> loadProducts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _repository.getAllProducts().listen((products) {
        final active = products.where((p) => p.isActive).toList();
        state = state.copyWith(products: products, activeProducts: active, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      state = state.copyWith(isLoading: true);
      final id = await _repository.createProduct(product);
      state = state.copyWith(isLoading: false);
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.updateProduct(product);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteProduct(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await _repository.toggleActive(id, isActive);
    } catch (e) {
      rethrow;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repo = ProductRepository();
  final notifier = ProductNotifier(repo);
  WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadProducts());
  return notifier;
});
