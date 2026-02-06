class QRHistory {
  final String id;
  final String userId;
  final String qrCode; // The actual QR raw data
  final String productName;
  final String productCode;
  final String category;
  final String size;
  final double price;
  final int quantity;
  final String transactionType; // 'buy' or 'sell'
  final double pointsEarned;
  final DateTime scannedAt;
  final bool isDuplicate; // Was this a duplicate scan?

  QRHistory({
    required this.id,
    required this.userId,
    required this.qrCode,
    required this.productName,
    required this.productCode,
    required this.category,
    required this.size,
    required this.price,
    required this.quantity,
    required this.transactionType,
    required this.pointsEarned,
    required this.scannedAt,
    this.isDuplicate = false,
  });

  String get typeDisplay => transactionType == 'buy' ? 'شراء' : 'بيع';
  bool get isBuy => transactionType == 'buy';
  bool get isSell => transactionType == 'sell';

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'qrCode': qrCode,
      'productName': productName,
      'productCode': productCode,
      'category': category,
      'size': size,
      'price': price,
      'quantity': quantity,
      'transactionType': transactionType,
      'pointsEarned': pointsEarned,
      'scannedAt': scannedAt.toIso8601String(),
      'isDuplicate': isDuplicate,
    };
  }

  // Create from Map
  factory QRHistory.fromMap(Map<String, dynamic> map) {
    return QRHistory(
      id: map['id'] as String,
      userId: map['userId'] as String,
      qrCode: map['qrCode'] as String,
      productName: map['productName'] as String,
      productCode: map['productCode'] as String,
      category: map['category'] as String,
      size: map['size'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      transactionType: map['transactionType'] as String,
      pointsEarned: (map['pointsEarned'] as num).toDouble(),
      scannedAt: DateTime.parse(map['scannedAt'] as String),
      isDuplicate: map['isDuplicate'] as bool? ?? false,
    );
  }

  QRHistory copyWith({
    String? id,
    String? userId,
    String? qrCode,
    String? productName,
    String? productCode,
    String? category,
    String? size,
    double? price,
    int? quantity,
    String? transactionType,
    double? pointsEarned,
    DateTime? scannedAt,
    bool? isDuplicate,
  }) {
    return QRHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qrCode: qrCode ?? this.qrCode,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      category: category ?? this.category,
      size: size ?? this.size,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      transactionType: transactionType ?? this.transactionType,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      scannedAt: scannedAt ?? this.scannedAt,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }
}