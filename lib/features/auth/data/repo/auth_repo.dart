import 'package:loyalty_app/core/helpers/user_roles.dart';
import 'package:loyalty_app/features/auth/data/models/transaction.dart';
import 'package:loyalty_app/features/auth/data/models/user_model.dart';

class DummyDataRepository {
  static final DummyDataRepository _instance = DummyDataRepository._internal();
  factory DummyDataRepository() => _instance;
  DummyDataRepository._internal();


  // Dummy Users
  final List<User> _users = [
    // Technicians
    User(
      id: '1',
      name: 'أحمد محمد',
      email: 'ahmed@example.com',
      phone: '01012345678',
      role: UserRole.technician,
      points: 1250.0,
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      id: '2',
      name: 'محمد علي',
      email: 'mohamed@example.com',
      phone: '01112345678',
      role: UserRole.technician,
      points: 890.0,
      createdAt: DateTime(2024, 2, 10),
    ),
    User(
      id: '3',
      name: 'خالد حسن',
      email: 'khaled@example.com',
      phone: '01212345678',
      role: UserRole.technician,
      points: 2100.0,
      createdAt: DateTime(2024, 1, 20),
    ),
    
    // Traders
    User(
      id: '4',
      name: 'عمر سعيد',
      email: 'omar@example.com',
      phone: '01512345678',
      role: UserRole.trader,
      points: 5600.0,
      createdAt: DateTime(2024, 1, 5),
    ),
    User(
      id: '5',
      name: 'ياسر فتحي',
      email: 'yasser@example.com',
      phone: '01012345679',
      role: UserRole.trader,
      points: 4200.0,
      createdAt: DateTime(2024, 1, 25),
    ),
    User(
      id: '6',
      name: 'طارق إبراهيم',
      email: 'tarek@example.com',
      phone: '01112345679',
      role: UserRole.trader,
      points: 3800.0,
      createdAt: DateTime(2024, 2, 1),
    ),
    
    // Distributors
    User(
      id: '7',
      name: 'حسام الدين',
      email: 'hossam@example.com',
      phone: '01212345679',
      role: UserRole.distributor,
      points: 12500.0,
      createdAt: DateTime(2023, 12, 10),
    ),
    User(
      id: '8',
      name: 'سامي رشيد',
      email: 'samy@example.com',
      phone: '01512345679',
      role: UserRole.distributor,
      points: 9800.0,
      createdAt: DateTime(2024, 1, 8),
    ),
    User(
      id: '9',
      name: 'وليد عادل',
      email: 'walid@example.com',
      phone: '01012345680',
      role: UserRole.distributor,
      points: 15200.0,
      createdAt: DateTime(2023, 11, 20),
    ),
    
    // Admin
    User(
      id: '10',
      name: 'إبراهيم المدير',
      email: 'admin@example.com',
      phone: '01000000000',
      role: UserRole.admin,
      points: 0.0,
      createdAt: DateTime(2023, 10, 1),
    ),
  ];

  // Dummy Transactions
  final List<Transaction> _transactions = [];

  
  // Get all users
  List<User> getAllUsers() => List.from(_users);

  // Get users by role
  List<User> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get user by email (for login)
  User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Get transactions by user ID
  List<Transaction> getTransactionsByUserId(String userId) {
    return _transactions
        .where((transaction) => transaction.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get all transactions
  List<Transaction> getAllTransactions() {
    return List.from(_transactions)..sort((a, b) => b.date.compareTo(a.date));
  }

  // Add transaction
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    
    // Update user points
    final userIndex = _users.indexWhere((u) => u.id == transaction.userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        points: _users[userIndex].points + transaction.pointsEarned,
      );
    }
  }

  // Get total points across all users
  double getTotalPoints() {
    return _users
        .where((user) => user.role != UserRole.admin)
        .fold(0.0, (sum, user) => sum + user.points);
  }

  // Get total money equivalent
  double getTotalMoney() {
    return getTotalPoints() * 0.5;
  }

  // Get user count by role
  int getUserCountByRole(UserRole role) {
    return _users.where((user) => user.role == role).length;
  }
}