import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 14.r, color: theme.colorScheme.primary),
            SizedBox(width: 8.w),
            Text(
              '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 22.w, top: 2.h),
            child: Text(
              subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
