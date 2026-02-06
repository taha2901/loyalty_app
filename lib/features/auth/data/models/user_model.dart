import 'package:loyalty_app/core/helpers/user_roles.dart';
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final double points;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.points,
    required this.createdAt,
  });

  double get moneyEquivalent => points * 0.5;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    double? points,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}