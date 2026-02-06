class Transaction {
  final String id;
  final String userId;
  final String productName;
  final int quantity;
  final String type; // 'buy' or 'sell'
  final double pointsEarned;
  final DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.pointsEarned,
    required this.date,
  });

  bool get isBuy => type == 'buy';
  bool get isSell => type == 'sell';

  String get typeDisplay => isBuy ? 'شراء' : 'بيع';
}