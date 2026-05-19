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
      final green = Colors.green.shade600;

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
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.check_rounded, color: green, size: 28.r),
                  ),
                  SizedBox(height: 8.h),

                  // ── Title ──────────────────────────────────────────
                  Text(
                    'Job Completed!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'How was your experience?',
                    style: TextStyle(fontSize: 14.sp, color: green),
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
                            color: filled
                                ? Colors.green.shade500
                                : Colors.grey.shade300,
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
                    style: TextStyle(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Share your feedback (optional)...',
                      hintStyle: TextStyle(
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
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
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
      final red = Colors.red.shade600;

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
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade200, width: 2),
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
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'What went wrong?',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.textTheme.bodyMedium?.color,
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
                                ? Colors.red.shade50
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? red : theme.dividerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            issue,
                            style: TextStyle(
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
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: 'Please describe what happened...',
                        hintStyle: TextStyle(
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
                          borderSide: BorderSide(color: Colors.red.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red.shade200),
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
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
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
