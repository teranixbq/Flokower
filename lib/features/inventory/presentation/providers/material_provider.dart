import 'package:flutter/material.dart' hide Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/material_repository.dart';
import '../../../../shared/models/material_model.dart';

class MaterialState {
  final List<Material> materials;
  final bool isLoading;
  final String? error;

  const MaterialState({this.materials = const [], this.isLoading = false, this.error});

  MaterialState copyWith({List<Material>? materials, bool? isLoading, String? error}) {
    return MaterialState(materials: materials ?? this.materials, isLoading: isLoading ?? this.isLoading, error: error);
  }

  int get totalMaterials => materials.length;
  int get totalStock => materials.fold(0, (sum, m) => sum + m.currentQuantity);
  int get lowStockCount => materials.where((m) => m.isLowStock).length;
}

class MaterialNotifier extends StateNotifier<MaterialState> {
  final MaterialRepository _repository;
  MaterialNotifier(this._repository) : super(const MaterialState());

  Material materialById(String id) => state.materials.firstWhere((m) => m.id == id);

  /// Cari bahan berdasarkan nama (case-insensitive).
  /// Dipakai untuk mencegah duplikasi bahan saat pembuatan.
  Material? findByName(String name) {
    final target = name.trim().toLowerCase();
    if (target.isEmpty) return null;
    for (final m in state.materials) {
      if (m.name.trim().toLowerCase() == target) return m;
    }
    return null;
  }

  Future<void> loadMaterials() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _repository.getMaterials().listen((materials) {
        state = state.copyWith(materials: materials, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<String> addMaterial(Material material) async {
    try {
      state = state.copyWith(isLoading: true);
      final id = await _repository.createMaterial(material);
      state = state.copyWith(isLoading: false);
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> updateMaterial(Material material) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.updateMaterial(material);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteMaterial(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final materialProvider = StateNotifierProvider<MaterialNotifier, MaterialState>((ref) {
  final repo = MaterialRepository();
  final notifier = MaterialNotifier(repo);
  WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadMaterials());
  return notifier;
});
