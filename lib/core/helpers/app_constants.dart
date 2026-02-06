class AppConstants {
  // App Info
  static const String appName = 'مصنع الأسلاك الكهربائية';
  static const String appVersion = '1.0.0';
  
  // Product Types
  static const List<String> wireTypes = [
    'سلك 1.5 مم',
    'سلك 2 مم',
    'سلك 2.5 مم',
    'سلك 4 مم',
    'سلك 6 مم',
  ];
  
  // Points Configuration
  static const double pointToMoneyRatio = 0.5; // 1 point = 0.5 EGP
  
  // Transaction Types
  static const String transactionTypeBuy = 'buy';
  static const String transactionTypeSell = 'sell';
}