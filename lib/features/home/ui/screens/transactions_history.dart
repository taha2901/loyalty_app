import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
import 'package:loyalty_app/features/auth/logic/auth_states.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final transactions = context.watch<TransactionProvider>().transactions;
    final dateFormat = DateFormat('dd MMM yyyy - hh:mm a', 'ar');

    return Scaffold(
      appBar: const CustomAppBar(title: 'سجل المعاملات'),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80.sp,
                    color: Colors.grey.shade300,
                  ),
                  verticalSpace(8),
                  Text(
                    'لا توجد معاملات حتى الآن',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  verticalSpace(4),
                  Text(
                    'قم بمسح كود QR لإضافة معاملة جديدة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: EdgeInsets.all(12.h),
                  padding: EdgeInsets.all(24.h),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المعاملات',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                            verticalSpace(4),
                            Text(
                              '${transactions.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'الكل',
                          isSelected: true,
                          onTap: () {},
                        ),
                        horizontalSpace(8),
                        _FilterChip(
                          label: 'شراء',
                          isSelected: false,
                          onTap: () {},
                          color: AppTheme.accentColor,
                        ),
                        horizontalSpace(8),
                        _FilterChip(
                          label: 'بيع',
                          isSelected: false,
                          onTap: () {},
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                  ),
                ),

                verticalSpace(16),

                // Transactions List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isFirst = index == 0;
                      final currentDate = DateFormat('dd/MM/yyyy').format(transaction.date);
                      final previousDate = index > 0
                          ? DateFormat('dd/MM/yyyy').format(transactions[index - 1].date)
                          : '';
                      final showDateHeader = isFirst || currentDate != previousDate;

                      return Column(
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
                          Container(
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
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12.h),
                              leading: Container(
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
                              title: Text(
                                transaction.productName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  verticalSpace(4),
                                  Row(
                                    children: [
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
                                      horizontalSpace(8),
                                      Text(
                                        '${transaction.quantity} قطعة',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppTheme.textSecondaryColor),
                                      ),
                                    ],
                                  ),
                                  verticalSpace(4),
                                  Text(
                                    DateFormat('hh:mm a', 'ar').format(transaction.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppTheme.textSecondaryColor),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+${transaction.pointsEarned.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppTheme.successColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'نقطة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppTheme.textSecondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
