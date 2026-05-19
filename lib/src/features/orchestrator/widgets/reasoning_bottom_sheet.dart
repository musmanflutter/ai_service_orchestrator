import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void showReasoningBottomSheet(BuildContext context, String reasoningText) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);
      
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  "Agentic Reasoning Trace",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: theme.textTheme.bodyMedium?.color),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                reasoningText.trim(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.sp,
                  color: theme.textTheme.bodyLarge?.color,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      );
    },
  );
}
