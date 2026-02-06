import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/auth/data/repo/auth_repo.dart';
import 'package:loyalty_app/features/auth/data/models/transaction.dart';
import 'package:intl/intl.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen>
    with SingleTickerProviderStateMixin {
  final repository = DummyDataRepository();
  late List<Transaction> _allTransactions;
  late List<Transaction> _filteredTransactions;
  String _selectedFilter = 'all'; // all, buy, sell

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _allTransactions = repository.getAllTransactions();
    _filteredTransactions = List.from(_allTransactions);

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

  void _filterTransactions() {
    setState(() {
      if (_selectedFilter == 'all') {
        _filteredTransactions = List.from(_allTransactions);
      } else {
        _filteredTransactions = _allTransactions
            .where((transaction) => transaction.type == _selectedFilter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalTransactions = _filteredTransactions.length;
    final buyTransactions =
        _filteredTransactions.where((t) => t.isBuy).length;
    final sellTransactions =
        _filteredTransactions.where((t) => t.isSell).length;
    final totalPoints = _filteredTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.pointsEarned,
    );

    final numberFormat = NumberFormat('#,##0', 'ar_EG');

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المعاملات'),
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
                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'إجمالي المعاملات',
                            '$totalTransactions',
                            Icons.receipt_long,
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
                      ],
                    ),
                    verticalSpace(8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'عمليات الشراء',
                            '$buyTransactions',
                            Icons.shopping_cart,
                          ),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: _buildStatCard(
                            'عمليات البيع',
                            '$sellTransactions',
                            Icons.sell,
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
              child: Row(
                children: [
                  _buildFilterChip(
                    'الكل',
                    'all',
                    _allTransactions.length,
                  ),
                  horizontalSpace(8),
                  _buildFilterChip(
                    'الشراء',
                    'buy',
                    _allTransactions.where((t) => t.isBuy).length,
                  ),
                  horizontalSpace(8),
                  _buildFilterChip(
                    'البيع',
                    'sell',
                    _allTransactions.where((t) => t.isSell).length,
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80.sp,
                            color: Colors.grey.shade300,
                          ),
                          verticalSpace(16),
                          Text(
                            'لا توجد معاملات',
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
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          final isFirst = index == 0;
                          final currentDate = DateFormat('dd/MM/yyyy')
                              .format(transaction.date);
                          final previousDate = index > 0
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_filteredTransactions[index - 1].date)
                              : '';
                          final showDateHeader =
                              isFirst || currentDate != previousDate;

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader) ...[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 8.h,
                                      top: index == 0 ? 0 : 16.h,
                                    ),
                                    child: Text(
                                      currentDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color:
                                                AppTheme.textSecondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                                _buildTransactionCard(context, transaction),
                              ],
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
          Icon(icon, color: Colors.white, size: 24.sp),
          verticalSpace(4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    Color chipColor;
    if (value == 'buy') {
      chipColor = AppTheme.accentColor;
    } else if (value == 'sell') {
      chipColor = AppTheme.successColor;
    } else {
      chipColor = AppTheme.primaryColor;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
          _filterTransactions();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.white,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              horizontalSpace(4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : chipColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : chipColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction transaction,
  ) {
    final user = repository.getUserById(transaction.userId);
    final userName = user?.name ?? 'مستخدم غير معروف';
    final userRole = user?.role.displayName ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: transaction.isBuy
              ? AppTheme.accentColor.withOpacity(0.2)
              : AppTheme.successColor.withOpacity(0.2),
        ),
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
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            _showTransactionDetailsDialog(context, transaction, user);
          },
          child: Padding(
            padding: EdgeInsets.all(12.h),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: transaction.isBuy
                        ? AppTheme.accentColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    transaction.isBuy ? Icons.shopping_cart : Icons.sell,
                    color: transaction.isBuy
                        ? AppTheme.accentColor
                        : AppTheme.successColor,
                    size: 24.sp,
                  ),
                ),
                horizontalSpace(12),

                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.isBuy
                                  ? AppTheme.accentColor.withOpacity(0.1)
                                  : AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              transaction.typeDisplay,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: transaction.isBuy
                                        ? AppTheme.accentColor
                                        : AppTheme.successColor,
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
                            Icons.person_outline,
                            size: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                          horizontalSpace(4),
                          Expanded(
                            child: Text(
                              '$userName${userRole.isNotEmpty ? ' • $userRole' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                          horizontalSpace(4),
                          Text(
                            '${transaction.quantity} قطعة',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                          horizontalSpace(12),
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                          horizontalSpace(4),
                          Text(
                            DateFormat('hh:mm a', 'ar')
                                .format(transaction.date),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                horizontalSpace(8),

                // Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${transaction.pointsEarned.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'نقطة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
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

  void _showTransactionDetailsDialog(
    BuildContext context,
    Transaction transaction,
    dynamic user,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy - hh:mm a', 'ar_EG');
    final userName = user?.name ?? 'مستخدم غير معروف';
    final userRole = user?.role.displayName ?? 'غير محدد';

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
              // Transaction Icon
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: (transaction.isBuy
                          ? AppTheme.accentColor
                          : AppTheme.successColor)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.isBuy ? Icons.shopping_cart : Icons.sell,
                  color: transaction.isBuy
                      ? AppTheme.accentColor
                      : AppTheme.successColor,
                  size: 48.sp,
                ),
              ),
              verticalSpace(16),

              // Transaction Type
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (transaction.isBuy
                          ? AppTheme.accentColor
                          : AppTheme.successColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  transaction.typeDisplay,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: transaction.isBuy
                            ? AppTheme.accentColor
                            : AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              verticalSpace(24),
              Divider(color: Colors.grey.shade300),
              verticalSpace(16),

              // Details
              _buildDetailRow(
                Icons.inventory_2,
                'المنتج',
                transaction.productName,
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.numbers,
                'الكمية',
                '${transaction.quantity} قطعة',
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.person,
                'المستخدم',
                '$userName ($userRole)',
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.calendar_today,
                'التاريخ',
                dateFormat.format(transaction.date),
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.stars,
                'النقاط المكتسبة',
                '+${transaction.pointsEarned.toStringAsFixed(0)} نقطة',
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