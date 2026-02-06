import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/helpers/user_roles.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/auth/data/models/user_model.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';
import 'package:intl/intl.dart';

class UsersByRoleScreen extends StatefulWidget {
  final UserRole role;

  const UsersByRoleScreen({super.key, required this.role});

  @override
  State<UsersByRoleScreen> createState() => _UsersByRoleScreenState();
}

class _UsersByRoleScreenState extends State<UsersByRoleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.technician:
        return AppTheme.accentColor;
      case UserRole.trader:
        return AppTheme.successColor;
      case UserRole.distributor:
        return AppTheme.secondaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.technician:
        return 'الفنيون';
      case UserRole.trader:
        return 'التجار';
      case UserRole.distributor:
        return 'الموزعون';
      default:
        return 'المستخدمون';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.technician:
        return 'يمكنهم شراء المنتجات فقط';
      case UserRole.trader:
        return 'يمكنهم شراء وبيع المنتجات';
      case UserRole.distributor:
        return 'يمكنهم شراء وبيع المنتجات';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = DummyDataRepository();
    final users = repository.getUsersByRole(widget.role);
    final roleColor = _getRoleColor(widget.role);
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    // Calculate statistics
    final totalPoints = users.fold<double>(0, (sum, user) => sum + user.points);
    final totalMoney = totalPoints * 0.5;
    final avgPoints = users.isEmpty ? 0.0 : totalPoints / users.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                _getRoleIcon(widget.role),
                                style: TextStyle(fontSize: 32.sp),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(16),
                        Text(
                          _getRoleTitle(widget.role),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        verticalSpace(8),
                        Text(
                          _getRoleDescription(widget.role),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Statistics Cards
            Padding(
              padding: EdgeInsets.all(24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'إجمالي المستخدمين',
                            '${users.length}',
                            Icons.people,
                            roleColor,
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'إجمالي النقاط',
                            numberFormat.format(totalPoints),
                            Icons.stars,
                            AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'القيمة النقدية',
                            currencyFormat.format(totalMoney),
                            Icons.account_balance_wallet,
                            AppTheme.successColor,
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'متوسط النقاط',
                            numberFormat.format(avgPoints),
                            Icons.trending_up,
                            AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Users List Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'قائمة المستخدمين',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '${users.length} مستخدم',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: roleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            verticalSpace(16),

            // Users List
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80.sp,
                              color: Colors.grey.shade300,
                            ),
                            verticalSpace(16),
                            Text(
                              'لا يوجد مستخدمون',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 8.h),
                          physics: const BouncingScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 300 + (index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildUserCard(
                                context,
                                user,
                                roleColor,
                                currencyFormat,
                                numberFormat,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          verticalSpace(12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpace(4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    User user,
    Color roleColor,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar_EG');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: roleColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person,
                  color: roleColor,
                  size: 28.sp,
                ),
              ),
              horizontalSpace(12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    verticalSpace(4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                        horizontalSpace(4),
                        Expanded(
                          child: Text(
                            user.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpace(12),
          Divider(color: Colors.grey.shade200, height: 1),
          verticalSpace(12),

          // Points and Money
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.stars,
                  'النقاط',
                  numberFormat.format(user.points),
                  AppTheme.primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.account_balance_wallet,
                  'المحفظة',
                  currencyFormat.format(user.moneyEquivalent),
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          verticalSpace(12),

          // Additional Info
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
              horizontalSpace(4),
              Text(
                user.phone,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              horizontalSpace(16),
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
              horizontalSpace(4),
              Expanded(
                child: Text(
                  'انضم في ${dateFormat.format(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16.sp),
            horizontalSpace(4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
        verticalSpace(4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}