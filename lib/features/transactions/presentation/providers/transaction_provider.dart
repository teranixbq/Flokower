import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/transaction_repository.dart';
import '../../../../shared/models/transaction_model.dart';

class TransactionState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionState copyWith({List<TransactionModel>? transactions, bool? isLoading, String? error}) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get inProgressCount => transactions.where((t) => t.isInProgress).length;
  int get completedCount => transactions.where((t) => t.isCompleted).length;
  int get cancelledCount => transactions.where((t) => t.isCancelled).length;
  
  double get totalRevenue => transactions
      .where((t) => t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.totalAmount);

  List<TransactionModel> get inProgressTransactions =>
      transactions.where((t) => t.isInProgress).toList();
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super(const TransactionState());

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> loadTransactions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _repository.getTransactions().listen((transactions) {
        state = state.copyWith(transactions: transactions, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final id = await _repository.createTransaction(transaction);
      state = state.copyWith(isLoading: false);
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> completeTransaction(String transactionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.completeTransaction(transactionId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> cancelTransaction(String transactionId, {String? reason}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.cancelTransaction(transactionId, reason: reason);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final repo = TransactionRepository();
  final notifier = TransactionNotifier(repo);
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.loadTransactions();
  });
  
  return notifier;
});
