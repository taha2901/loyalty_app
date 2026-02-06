import 'package:flutter/material.dart';
import 'package:loyalty_app/features/auth/data/models/transaction.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final DummyDataRepository _repository = DummyDataRepository();
  final _uuid = const Uuid();

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Load transactions for a user
  void loadTransactions(String userId) {
    _isLoading = true;
    notifyListeners();

    _transactions = _repository.getTransactionsByUserId(userId);

    _isLoading = false;
    notifyListeners();
  }

  // Add new transaction with custom points
  Transaction addTransaction({
    required String userId,
    required String productName,
    required int quantity,
    required String type,
    double? pointsEarned, // Custom points from QR data
  }) {
    // If custom points not provided, use default calculation
    final points = pointsEarned ?? (quantity * (type == 'buy' ? 5.0 : 8.0));

    final transaction = Transaction(
      id: _uuid.v4(),
      userId: userId,
      productName: productName,
      quantity: quantity,
      type: type,
      pointsEarned: points,
      date: DateTime.now(),
    );

    _repository.addTransaction(transaction);
    _transactions.insert(0, transaction);
    notifyListeners();

    return transaction;
  }

  // Get total points from transactions
  double getTotalPoints() {
    return _transactions.fold(
        0.0, (sum, transaction) => sum + transaction.pointsEarned);
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get buy transactions count
  int getBuyTransactionsCount() {
    return _transactions.where((t) => t.type == 'buy').length;
  }

  // Get sell transactions count
  int getSellTransactionsCount() {
    return _transactions.where((t) => t.type == 'sell').length;
  }
}