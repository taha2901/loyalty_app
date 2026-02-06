import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/admin/data/models/qr_history_model.dart';
import 'package:loyalty_app/features/admin/logic/qr_history_provider.dart';
import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
import 'package:loyalty_app/features/auth/logic/auth_states.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class QRHistoryScreen extends StatefulWidget {
  const QRHistoryScreen({super.key});

  @override
  State<QRHistoryScreen> createState() => _QRHistoryScreenState();
}

class _QRHistoryScreenState extends State<QRHistoryScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all'; // all, buy, sell, duplicate
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final qrHistory = context.watch<QRHistoryProvider>();
    final allHistory = qrHistory.getHistoryForUser(user.id);
    final stats = qrHistory.getStats(user.id);
    final mostScanned = qrHistory.getMostScannedProducts(user.id);

    // Apply filter
    final filteredHistory = _selectedFilter == 'all'
        ? allHistory
        : _selectedFilter == 'duplicate'
            ? allHistory.where((h) => h.isDuplicate).toList()
            : allHistory.where((h) => h.transactionType == _selectedFilter).toList();

    final dateFormat = DateFormat('dd/MM/yyyy', 'ar_EG');
    final timeFormat = DateFormat('hh:mm a', 'ar_EG');

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل مسح الأكواد'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics Header
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
                    // Main Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'إجمالي المسح',
                            '${stats.totalScans}',
                            Icons.qr_code_scanner,
                          ),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: _buildStatCard(
                            'اليوم',
                            '${stats.todayScans}',
                            Icons.today,
                          ),
                        ),
                        horizontalSpace(8),
                        Expanded(
                          child: _buildStatCard(
                            'مكرر',
                            '${stats.duplicateScans}',
                            Icons.content_copy,
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
                    _buildFilterChip('الكل', 'all', allHistory.length),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'شراء',
                      'buy',
                      stats.buyScans,
                      AppTheme.accentColor,
                    ),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'بيع',
                      'sell',
                      stats.sellScans,
                      AppTheme.successColor,
                    ),
                    horizontalSpace(8),
                    _buildFilterChip(
                      'مكرر',
                      'duplicate',
                      stats.duplicateScans,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Most Scanned Products
          if (mostScanned.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          color: AppTheme.primaryColor, size: 20.sp),
                      horizontalSpace(8),
                      Text(
                        'الأكثر مسحاً',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  verticalSpace(8),
                  SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mostScanned.length,
                      itemBuilder: (context, index) {
                        final product = mostScanned[index];
                        return Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.productName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              horizontalSpace(4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Text(
                                  '${product.count}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(16),
          ],

          // History List
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 80.sp,
                            color: Colors.grey.shade300,
                          ),
                          verticalSpace(16),
                          Text(
                            'لا يوجد سجل',
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
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        final isFirst = index == 0;
                        final currentDate = dateFormat.format(item.scannedAt);
                        final previousDate = index > 0
                            ? dateFormat.format(filteredHistory[index - 1].scannedAt)
                            : '';
                        final showDateHeader = isFirst || currentDate != previousDate;

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
                                          color: AppTheme.textSecondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                              _buildHistoryCard(context, item, timeFormat),
                            ],
                          ),
                        );
                      },
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

  Widget _buildFilterChip(String label, String value, int count,
      [Color? color]) {
    final isSelected = _selectedFilter == value;
    final chipColor = color ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    QRHistory item,
    DateFormat timeFormat,
  ) {
    final borderColor = item.isBuy
        ? AppTheme.accentColor
        : AppTheme.successColor;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: item.isDuplicate
              ? Colors.orange.withOpacity(0.3)
              : borderColor.withOpacity(0.2),
          width: item.isDuplicate ? 2 : 1,
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
            _showHistoryDetails(context, item);
          },
          child: Padding(
            padding: EdgeInsets.all(12.h),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: (item.isDuplicate
                            ? Colors.orange
                            : borderColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    item.isDuplicate
                        ? Icons.content_copy
                        : (item.isBuy ? Icons.shopping_cart : Icons.sell),
                    color: item.isDuplicate ? Colors.orange : borderColor,
                    size: 24.sp,
                  ),
                ),
                horizontalSpace(12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isDuplicate)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'مكرر',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10.sp,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      verticalSpace(4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: borderColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              item.typeDisplay,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: borderColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          horizontalSpace(8),
                          Text(
                            '${item.quantity} قطعة',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                          horizontalSpace(8),
                          Icon(Icons.access_time,
                              size: 12.sp, color: AppTheme.textSecondaryColor),
                          horizontalSpace(4),
                          Text(
                            timeFormat.format(item.scannedAt),
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
                      '+${item.pointsEarned.toStringAsFixed(0)}',
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

  void _showHistoryDetails(BuildContext context, QRHistory item) {
    final dateFormat = DateFormat('dd MMMM yyyy - hh:mm a', 'ar_EG');

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
              // Icon
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: (item.isDuplicate
                          ? Colors.orange
                          : (item.isBuy
                              ? AppTheme.accentColor
                              : AppTheme.successColor))
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isDuplicate
                      ? Icons.content_copy
                      : (item.isBuy ? Icons.shopping_cart : Icons.sell),
                  color: item.isDuplicate
                      ? Colors.orange
                      : (item.isBuy
                          ? AppTheme.accentColor
                          : AppTheme.successColor),
                  size: 48.sp,
                ),
              ),
              verticalSpace(16),

              // Type Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (item.isBuy
                          ? AppTheme.accentColor
                          : AppTheme.successColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.typeDisplay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: item.isBuy
                                ? AppTheme.accentColor
                                : AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (item.isDuplicate) ...[
                      horizontalSpace(8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'مكرر',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              verticalSpace(24),
              Divider(color: Colors.grey.shade300),
              verticalSpace(16),

              // Details
              _buildDetailRow(Icons.inventory_2, 'المنتج', item.productName),
              verticalSpace(12),
              _buildDetailRow(Icons.qr_code, 'كود المنتج', item.productCode),
              verticalSpace(12),
              _buildDetailRow(Icons.category, 'الفئة', item.category),
              verticalSpace(12),
              _buildDetailRow(Icons.straighten, 'المقاس', item.size),
              verticalSpace(12),
              _buildDetailRow(
                  Icons.attach_money, 'السعر', '${item.price} ج.م'),
              verticalSpace(12),
              _buildDetailRow(Icons.numbers, 'الكمية', '${item.quantity} قطعة'),
              verticalSpace(12),
              _buildDetailRow(
                Icons.calendar_today,
                'التاريخ',
                dateFormat.format(item.scannedAt),
              ),
              verticalSpace(12),
              _buildDetailRow(
                Icons.stars,
                'النقاط المكتسبة',
                '+${item.pointsEarned.toStringAsFixed(0)} نقطة',
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