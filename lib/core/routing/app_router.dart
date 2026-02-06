import 'package:flutter/material.dart';
import 'package:loyalty_app/core/helpers/user_roles.dart';
import 'package:loyalty_app/core/routing/routes.dart';
import 'package:loyalty_app/features/admin/ui/screens/admin_dashboard.dart';
import 'package:loyalty_app/features/admin/ui/screens/admin_qr_generator.dart';
import 'package:loyalty_app/features/admin/ui/screens/all_transactions_screen.dart';
import 'package:loyalty_app/features/admin/ui/screens/all_users_screen.dart';
import 'package:loyalty_app/features/admin/ui/screens/qr_history_screen.dart';
import 'package:loyalty_app/features/admin/ui/screens/scan_qr_with_duplicate_detection.dart';
import 'package:loyalty_app/features/admin/ui/screens/user_by_role_screen.dart';
import 'package:loyalty_app/features/admin_qr_generator.dart';
import 'package:loyalty_app/features/auth/ui/screens/login_screen.dart';
import 'package:loyalty_app/features/home/ui/screens/home_screen.dart';
import 'package:loyalty_app/features/home/ui/screens/sqan_qr.dart';
import 'package:loyalty_app/features/home/ui/screens/transactions_history.dart';
class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routers.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case Routers.home:
        return MaterialPageRoute(
          builder: (_) => const UserHomeScreen(),
        );
      case Routers.scan:
        return MaterialPageRoute(
          builder: (_) => const ScanQRScreen(),
        );
      case Routers.transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsScreen(),
        );
      case Routers.qrHistory: // ✅ Added
        return MaterialPageRoute(
          builder: (_) => const QRHistoryScreen(),
        );
      case Routers.admin:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );
      case Routers.adminQRGenerator:
        return MaterialPageRoute(
          builder: (_) => const AdminQRGeneratorScreen(),
        );
      case Routers.adminUsers:
        final role = settings.arguments as UserRole?;
        if (role != null) {
          return MaterialPageRoute(
            builder: (_) => UsersByRoleScreen(role: role),
          );
        }
        return null;
      case Routers.adminAllUsers:
        return MaterialPageRoute(
          builder: (_) => const AllUsersScreen(),
        );
      case Routers.adminAllTransactions:
        return MaterialPageRoute(
          builder: (_) => const AllTransactionsScreen(),
        );
      default:
        return null;
    }
  }
}