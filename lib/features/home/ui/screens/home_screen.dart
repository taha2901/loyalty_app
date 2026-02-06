import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_app/core/helpers/user_roles.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/core/widgets/app_text_button.dart';
import 'package:loyalty_app/core/widgets/gradient_card.dart';
import 'package:intl/intl.dart';
import 'package:loyalty_app/features/auth/logic/auth_states.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Load transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<TransactionProvider>().loadTransactions(user.id);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.technician:
        return '🔧';
      case UserRole.trader:
        return '🏪';
      case UserRole.distributor:
        return '🚚';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionProvider>().loadTransactions(user.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // باقي الكود زي ما هو

                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        16.h,
                        24.w,
                        32.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showLogoutDialog(context);
                                },
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'مرحباً',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                  ),
                                  Text(
                                    user.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  _getRoleIcon(user.role),
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                            ],
                          ),

                          verticalSpace(24),

                          // Role Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                                horizontalSpace(8),
                                Text(
                                  user.role.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Points & Money Cards
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Row(
                            children: [
                              // Points Card
                              Expanded(
                                child: GradientCard(
                                  gradient: AppTheme.primaryGradient,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              Icons.stars,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                          ),
                                          horizontalSpace(8),
                                          Text(
                                            'النقاط',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace(16),
                                      Text(
                                        numberFormat.format(user.points),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      verticalSpace(4),
                                      Text(
                                        'نقطة',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              horizontalSpace(16),

                              // Money Card
                              Expanded(
                                child: GradientCard(
                                  gradient: AppTheme.successGradient,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                          ),
                                          horizontalSpace(8),
                                          Text(
                                            'المحفظة',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace(16),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          currencyFormat
                                              .format(user.moneyEquivalent),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      verticalSpace(4),
                                      Text(
                                        'قيمة نقدية',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      verticalSpace(16),

                      // Quick Actions
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الإجراءات السريعة',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              verticalSpace(16),
                              ActionButton(
                                label: 'مسح كود QR',
                                icon: Icons.qr_code_scanner,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/scan');
                                },
                                color: AppTheme.secondaryColor,
                              ),
                              verticalSpace(8),
                              ActionButton(
                                label: 'عرض المعاملات',
                                icon: Icons.history,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/transactions');
                                },
                                color: AppTheme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      verticalSpace(16),

                      // Recent Transactions
                      _buildRecentTransactions(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final recentTransactions = transactions.take(5).toList();

    if (recentTransactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppRadius.xl.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: Colors.grey.shade300,
            ),
            verticalSpace(AppRadius.md.h),
            Text(
              'لا توجد معاملات حتى الآن',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppRadius.lg.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر المعاملات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transactions');
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          verticalSpace(AppRadius.md.h),
          ...recentTransactions.map((transaction) {
            final dateFormat = DateFormat('dd/MM/yyyy', 'ar_EG');
            return Container(
              margin: EdgeInsets.only(bottom: AppRadius.sm.h),
              padding: EdgeInsets.all(AppRadius.md.h),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: Border.all(
                  color: transaction.isBuy
                      ? AppTheme.accentColor.withOpacity(0.2)
                      : AppTheme.successColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: transaction.isBuy
                          ? AppTheme.accentColor.withOpacity(0.1)
                          : AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      transaction.isBuy ? Icons.shopping_cart : Icons.sell,
                      color: transaction.isBuy
                          ? AppTheme.accentColor
                          : AppTheme.successColor,
                      size: 20.sp,
                    ),
                  ),
                  horizontalSpace(AppRadius.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.productName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        verticalSpace(2.h),
                        Text(
                          '${transaction.typeDisplay} • ${transaction.quantity} قطعة',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${transaction.pointsEarned.toStringAsFixed(0)} نقطة',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      verticalSpace(2.h),
                      Text(
                        dateFormat.format(transaction.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج', style: TextStyle(fontSize: 18.sp)),
        content: Text('هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(fontSize: 16.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text('تسجيل الخروج', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
