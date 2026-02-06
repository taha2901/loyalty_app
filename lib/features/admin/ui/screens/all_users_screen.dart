import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';
import 'package:loyalty_app/features/auth/data/models/user_model.dart';
import 'package:intl/intl.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen>
    with SingleTickerProviderStateMixin {
  final repository = DummyDataRepository();
  late List<User> _allUsers;
  late List<User> _filteredUsers;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, technician, trader, distributor

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _allUsers = repository
        .getAllUsers()
        .where((user) => user.id != '10') // Exclude admin
        .toList();
    _filteredUsers = List.from(_allUsers);

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

  void _filterUsers() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        // Search filter
        final matchesSearch = user.name.contains(_searchQuery) ||
            user.email.contains(_searchQuery) ||
            user.phone.contains(_searchQuery);

        // Role filter
        final matchesRole = _selectedFilter == 'all' ||
            user.role.name == _selectedFilter;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    // Calculate statistics
    final totalPoints =
        _filteredUsers.fold<double>(0, (sum, user) => sum + user.points);
    final totalMoney = totalPoints * 0.5;
    final avgPoints =
        _filteredUsers.isEmpty ? 0.0 : totalPoints / _filteredUsers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _filterUsers();
                        },
                        decoration: InputDecoration(
                          hintText: 'البحث عن مستخدم...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    verticalSpace(16),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'إجمالي المستخدمين',
                            '${_filteredUsers.length}',
                            Icons.people,
                          ),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: _buildStatCard(
                            'إجمالي النقاط',
                            numberFormat.format(totalPoints),
                            Icons.stars,
                          ),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: _buildStatCard(
                            'القيمة النقدية',
                            currencyFormat.format(totalMoney),
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('الكل', 'all', _allUsers.length),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'الفنيون',
                      'technician',
                      _allUsers
                          .where((u) => u.role.name == 'technician')
                          .length,
                    ),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'التجار',
                      'trader',
                      _allUsers.where((u) => u.role.name == 'trader').length,
                    ),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'الموزعون',
                      'distributor',
                      _allUsers
                          .where((u) => u.role.name == 'distributor')
                          .length,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child: _filteredUsers.isEmpty
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
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300 + (index * 50)),
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          verticalSpace(4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _filterUsers();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            horizontalSpace(4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    User user,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar_EG');
    final roleColor = _getRoleColor(user.role.name);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            _showUserDetailsDialog(context, user);
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: roleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
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
          ),
        ),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'technician':
        return AppTheme.accentColor;
      case 'trader':
        return AppTheme.successColor;
      case 'distributor':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _showUserDetailsDialog(BuildContext context, User user) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    final numberFormat = NumberFormat('#,##0', 'ar_EG');
    final dateFormat = DateFormat('dd MMMM yyyy', 'ar_EG');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Avatar
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role.name).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: _getRoleColor(user.role.name),
                  size: 48.sp,
                ),
              ),
              verticalSpace(16),

              // User Name
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(8),

              // Role Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  user.role.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getRoleColor(user.role.name),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              verticalSpace(24),
              Divider(color: Colors.grey.shade300),
              verticalSpace(16),

              // Details
              _buildDetailRow(Icons.email, 'البريد الإلكتروني', user.email),
              verticalSpace(12),
              _buildDetailRow(Icons.phone, 'رقم الهاتف', user.phone),
              verticalSpace(12),
              _buildDetailRow(
                Icons.calendar_today,
                'تاريخ التسجيل',
                dateFormat.format(user.createdAt),
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.stars,
                'إجمالي النقاط',
                numberFormat.format(user.points),
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.account_balance_wallet,
                'القيمة النقدية',
                currencyFormat.format(user.moneyEquivalent),
              ),

              verticalSpace(24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: AppTheme.textSecondaryColor,
        ),
        horizontalSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              verticalSpace(2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}