import 'package:flutter/material.dart';
import 'package:loyalty_app/features/admin/data/models/qr_history_model.dart';
import 'package:uuid/uuid.dart';

class QRHistoryProvider with ChangeNotifier {
  final _uuid = const Uuid();
  final List<QRHistory> _history = [];

  // Duplicate detection settings
  final Duration _duplicateWindow = const Duration(hours: 24); // كم ساعة يعتبر duplicate
  final int _maxScansPerDay = 3; // أقصى عدد مسح لنفس المنتج في اليوم

  List<QRHistory> get history => List.unmodifiable(_history);

  // Get history for specific user
  List<QRHistory> getHistoryForUser(String userId) {
    return _history
        .where((item) => item.userId == userId)
        .toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  // Get history by date range
  List<QRHistory> getHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _history.where((item) {
      return item.userId == userId &&
          item.scannedAt.isAfter(startDate) &&
          item.scannedAt.isBefore(endDate);
    }).toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  // Get today's scans
  List<QRHistory> getTodayScans(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getHistoryByDateRange(userId, startOfDay, endOfDay);
  }

  // Check if QR code is duplicate
  DuplicateCheckResult checkDuplicate(String userId, String qrCode) {
    final now = DateTime.now();
    final cutoffTime = now.subtract(_duplicateWindow);

    // Get all scans of this QR code by this user in the duplicate window
    final recentScans = _history.where((item) {
      return item.userId == userId &&
          item.qrCode == qrCode &&
          item.scannedAt.isAfter(cutoffTime);
    }).toList();

    if (recentScans.isEmpty) {
      return DuplicateCheckResult(
        isDuplicate: false,
        message: null,
        canProceed: true,
      );
    }

    // Check if exceeded max scans per day
    if (recentScans.length >= _maxScansPerDay) {
      final lastScan = recentScans.first;
      final timeSinceLastScan = now.difference(lastScan.scannedAt);
      
      return DuplicateCheckResult(
        isDuplicate: true,
        message: 'لقد قمت بمسح هذا المنتج ${recentScans.length} مرات في آخر 24 ساعة.\nالحد الأقصى هو $_maxScansPerDay مرات يومياً.',
        canProceed: false,
        lastScanTime: lastScan.scannedAt,
        scanCount: recentScans.length,
      );
    }

    // Warning but can proceed
    final lastScan = recentScans.first;
    return DuplicateCheckResult(
      isDuplicate: true,
      message: 'تنبيه: لقد قمت بمسح هذا المنتج من قبل (${recentScans.length} مرة في آخر 24 ساعة).',
      canProceed: true,
      lastScanTime: lastScan.scannedAt,
      scanCount: recentScans.length,
    );
  }

  // Add to history
  QRHistory addToHistory({
    required String userId,
    required String qrCode,
    required String productName,
    required String productCode,
    required String category,
    required String size,
    required double price,
    required int quantity,
    required String transactionType,
    required double pointsEarned,
    bool isDuplicate = false,
  }) {
    final historyItem = QRHistory(
      id: _uuid.v4(),
      userId: userId,
      qrCode: qrCode,
      productName: productName,
      productCode: productCode,
      category: category,
      size: size,
      price: price,
      quantity: quantity,
      transactionType: transactionType,
      pointsEarned: pointsEarned,
      scannedAt: DateTime.now(),
      isDuplicate: isDuplicate,
    );

    _history.insert(0, historyItem);
    notifyListeners();
    return historyItem;
  }

  // Get statistics
  QRHistoryStats getStats(String userId) {
    final userHistory = getHistoryForUser(userId);
    final todayScans = getTodayScans(userId);

    return QRHistoryStats(
      totalScans: userHistory.length,
      todayScans: todayScans.length,
      buyScans: userHistory.where((h) => h.isBuy).length,
      sellScans: userHistory.where((h) => h.isSell).length,
      duplicateScans: userHistory.where((h) => h.isDuplicate).length,
      totalPointsFromScans: userHistory.fold(0.0, (sum, h) => sum + h.pointsEarned),
    );
  }

  // Get most scanned products
  List<ProductScanCount> getMostScannedProducts(String userId, {int limit = 5}) {
    final userHistory = getHistoryForUser(userId);
    final Map<String, ProductScanCount> productCounts = {};

    for (var item in userHistory) {
      if (productCounts.containsKey(item.productCode)) {
        productCounts[item.productCode] = productCounts[item.productCode]!.copyWith(
          count: productCounts[item.productCode]!.count + 1,
        );
      } else {
        productCounts[item.productCode] = ProductScanCount(
          productName: item.productName,
          productCode: item.productCode,
          count: 1,
        );
      }
    }

    final sortedProducts = productCounts.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sortedProducts.take(limit).toList();
  }

  // Clear history (for logout or reset)
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // Delete specific history item
  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

// Duplicate check result
class DuplicateCheckResult {
  final bool isDuplicate;
  final String? message;
  final bool canProceed;
  final DateTime? lastScanTime;
  final int? scanCount;

  DuplicateCheckResult({
    required this.isDuplicate,
    required this.message,
    required this.canProceed,
    this.lastScanTime,
    this.scanCount,
  });
}

// Statistics model
class QRHistoryStats {
  final int totalScans;
  final int todayScans;
  final int buyScans;
  final int sellScans;
  final int duplicateScans;
  final double totalPointsFromScans;

  QRHistoryStats({
    required this.totalScans,
    required this.todayScans,
    required this.buyScans,
    required this.sellScans,
    required this.duplicateScans,
    required this.totalPointsFromScans,
  });
}

// Product scan count model
class ProductScanCount {
  final String productName;
  final String productCode;
  final int count;

  ProductScanCount({
    required this.productName,
    required this.productCode,
    required this.count,
  });

  ProductScanCount copyWith({
    String? productName,
    String? productCode,
    int? count,
  }) {
    return ProductScanCount(
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      count: count ?? this.count,
    );
  }
}