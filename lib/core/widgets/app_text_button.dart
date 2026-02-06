import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'package:loyalty_app/core/theming/colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
   final buttonColor = color ?? AppTheme.primaryColor;

return Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(AppRadius.md),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), // ScreenUtil
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: buttonColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: buttonColor, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: buttonColor,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    ),
  ),
);
 }
}