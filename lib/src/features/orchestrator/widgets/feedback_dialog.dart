import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Entry point ───────────────────────────────────────────────────────────────
Future<void> showFeedbackDialog(
  BuildContext context,
  Function(double rating, String comment) onSubmit,
) async {
  final commentController = TextEditingController();
  double selectedRating = 4.0;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final green = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      final greenBg = isDark
          ? const Color(0xFF143A24)
          : const Color(0xFFE8F5E9);
      final greenBorder = isDark
          ? const Color(0xFF1E5235)
          : const Color(0xFFA5D6A7);
      final starActive = Colors.green.shade500;
      final starInactive = Colors.grey.shade300;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Close ──────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Icon(
                        Icons.close,
                        size: 20.r,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // ── Sparkle + checkmark ────────────────────────────
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: greenBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: greenBorder, width: 2),
                    ),
                    child: Icon(Icons.check_rounded, color: green, size: 28.r),
                  ),
                  SizedBox(height: 8.h),

                  // ── Title ──────────────────────────────────────────
                  Text(
                    'Job Completed!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'How was your experience?',
                    style: theme.textTheme.bodyMedium?.copyWith(color: green),
                  ),
                  SizedBox(height: 20.h),

                  // ── Stars ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < selectedRating;
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = i + 1.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: filled ? starActive : starInactive,
                            size: 40.r,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),

                  // ── Comment ────────────────────────────────────────
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your feedback (optional)...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 13.sp,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: green, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Submit ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // close rating dialog
                        if (selectedRating <= 2) {
                          // Show bad-rating issue picker
                          await showBadRatingDialog(
                            context,
                            selectedRating,
                            commentController.text,
                            onSubmit,
                          );
                        } else {
                          onSubmit(selectedRating, commentController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Submit Rating',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ── Bad rating issue picker dialog ────────────────────────────────────────────
Future<void> showBadRatingDialog(
  BuildContext context,
  double rating,
  String existingComment,
  Function(double rating, String comment) onSubmit,
) async {
  const issues = [
    'Late Arrival',
    'Poor Service',
    'Communication',
    'Overpriced',
    'Unprofessional',
    'Other',
  ];
  final selected = <String>{};
  final otherController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final red = theme.colorScheme.error;
      final redBg = isDark ? const Color(0xFF3B1313) : const Color(0xFFFFEBEE);
      final redBorder = isDark
          ? const Color(0xFF5C1D1D)
          : const Color(0xFFFFCDD2);

      return StatefulBuilder(
        builder: (context, setState) {
          final showOther = selected.contains('Other');

          return Dialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Close ────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Still submit with original comment if dismissed
                        onSubmit(rating, existingComment);
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Icon(
                        Icons.close,
                        size: 20.r,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // ── Sad face + sparkles ──────────────────────────
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: redBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: redBorder, width: 2),
                    ),
                    child: Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      color: red,
                      size: 28.r,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // ── Title ────────────────────────────────────────
                  Text(
                    'We\'re Sorry to Hear That 😔',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'What went wrong?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // ── Issue chips ──────────────────────────────────
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: issues.map((issue) {
                      final isSelected = selected.contains(issue);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            selected.remove(issue);
                          } else {
                            selected.add(issue);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? redBg
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? red : theme.dividerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            issue,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? red
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // ── "Other" text field ───────────────────────────
                  if (showOther) ...[
                    SizedBox(height: 14.h),
                    TextField(
                      controller: otherController,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Please describe what happened...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 13.sp,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: redBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: redBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: red, width: 1.5),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20.h),

                  // ── Submit ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Build combined comment
                        final issueList = selected
                            .where((s) => s != 'Other')
                            .toList();
                        final combined = [
                          if (existingComment.isNotEmpty) existingComment,
                          if (issueList.isNotEmpty)
                            'Issues: ${issueList.join(', ')}',
                          if (otherController.text.isNotEmpty)
                            'Other: ${otherController.text}',
                        ].join(' | ');
                        onSubmit(rating, combined);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red.withValues(alpha: 0.8),
                        foregroundColor: theme.colorScheme.onError,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Submit Feedback',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
