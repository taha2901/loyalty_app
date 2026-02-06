import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/helpers/user_roles.dart';
import 'package:loyalty_app/core/routing/routes.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/core/widgets/state_card.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';
import 'package:loyalty_app/features/auth/logic/auth_states.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
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
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = DummyDataRepository();
    final currencyFormat =
        NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0);
    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
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
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<AuthProvider>().logout();
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                          ),
                          Column(
                            children: [
                              Text(
                                'لوحة التحكم',
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
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Stats
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'نظرة عامة',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    verticalSpace(16),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 1.1,
                          children: [
                            StatsCard(
                              title: 'إجمالي النقاط',
                              value: numberFormat
                                  .format(repository.getTotalPoints()),
                              icon: Icons.stars,
                              color: AppTheme.primaryColor,
                            ),
                            StatsCard(
                              title: 'القيمة النقدية',
                              value: currencyFormat
                                  .format(repository.getTotalMoney()),
                              icon: Icons.attach_money,
                              color: AppTheme.successColor,
                            ),
                            StatsCard(
                              title: 'إجمالي المستخدمين',
                              value:
                                  '${repository.getAllUsers().length - 1}',
                              icon: Icons.people,
                              color: AppTheme.accentColor,
                            ),
                            StatsCard(
                              title: 'المعاملات',
                              value:
                                  '${repository.getAllTransactions().length}',
                              icon: Icons.receipt_long,
                              color: AppTheme.secondaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    verticalSpace(32),

                    // Users by Role
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'المستخدمون حسب الدور',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    verticalSpace(16),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildRoleCard(
                              context,
                              'الفنيون',
                              '🔧',
                              repository
                                  .getUserCountByRole(UserRole.technician),
                              AppTheme.accentColor,
                              UserRole.technician,
                            ),
                            verticalSpace(8),
                            _buildRoleCard(
                              context,
                              'التجار',
                              '🏪',
                              repository.getUserCountByRole(UserRole.trader),
                              AppTheme.successColor,
                              UserRole.trader,
                            ),
                            verticalSpace(8),
                            _buildRoleCard(
                              context,
                              'الموزعون',
                              '🚚',
                              repository
                                  .getUserCountByRole(UserRole.distributor),
                              AppTheme.secondaryColor,
                              UserRole.distributor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    verticalSpace(32),

                    // Quick Actions
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'الإجراءات السريعة',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    verticalSpace(16),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildActionButton(
                              context,
                              'إدارة جميع المستخدمين',
                              Icons.people_alt,
                              AppTheme.primaryColor,
                              () {
                                Navigator.pushNamed(
                                    context, Routers.adminAllUsers);
                              },
                            ),
                            verticalSpace(8),
                            _buildActionButton(
                              context,
                              'عرض جميع المعاملات',
                              Icons.receipt_long,
                              AppTheme.accentColor,
                              () {
                                Navigator.pushNamed(
                                    context, Routers.adminAllTransactions);
                              },
                            ),
                            verticalSpace(8),
                            _buildActionButton(
                              context,
                              'إنشاء qr code',
                              Icons.qr_code,
                              AppTheme.secondaryColor,
                              () {
                                Navigator.pushNamed(
                                    context, Routers.adminQRGenerator);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String emoji,
    int count,
    Color color,
    UserRole role,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routers.adminUsers, arguments: role);
      },
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Text(emoji, style: TextStyle(fontSize: 32.sp)),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  verticalSpace(4),
                  Text(
                    '$count مستخدم',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            horizontalSpace(16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }
}