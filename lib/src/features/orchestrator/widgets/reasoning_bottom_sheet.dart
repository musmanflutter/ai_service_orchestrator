import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showReasoningBottomSheet(BuildContext context, String reasoningText) {
  final steps = _parseSteps(reasoningText);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);
      final primary = theme.colorScheme.primary;

      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: primary,
                          size: 26.r, // bigger than step dots
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Reasoning Trace',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.r,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Timeline Steps ────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                    ).copyWith(bottom: 32.h),
                    itemCount: steps.length + 1,
                    itemBuilder: (context, index) {
                      final isLast = index == steps.length;
                      if (isLast) {
                        return _TimelineStep(
                          title: 'Workflow completed',
                          subtitle: 'Provider recommendation is ready',
                          isLast: true,
                          isFinal: true,
                        );
                      }
                      final step = steps[index];
                      return _TimelineStep(
                        title: step.title,
                        subtitle: step.detail,
                        isLast: false,
                        isFinal: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ── Step data model ──────────────────────────────────────────────────────────
class _Step {
  final String title;
  final String detail;
  _Step(this.title, this.detail);
}

// ── Clean up non-human-friendly text ────────────────────────────────────────
String _humanify(String text) {
  return text
      .replaceAll(RegExp(r'\(p\d+\)'), '')
      .replaceAll('`', '')
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
        return (m.group(1) ?? '').toLowerCase().replaceAll('_', ' ');
      })
      .replaceAll('scheduledTimestamp', 'scheduled time')
      .replaceAll('cancellationRate', 'cancellation rate')
      .replaceAll('basePrice', 'base price')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();
}

// ── Parse raw reasoning text into steps ──────────────────────────────────────
List<_Step> _parseSteps(String raw) {
  final lines = raw
      .split('\n')
      .map((l) => l.replaceFirst(RegExp(r'^[-*•–]\s*'), '').trim())
      .where((l) => l.isNotEmpty)
      .toList();

  final steps = <_Step>[];

  for (final line in lines) {
    final cleaned = _humanify(line);
    if (cleaned.isEmpty) continue;

    // Best case: clean "Title: Detail" split
    final colonIdx = cleaned.indexOf(': ');
    if (colonIdx > 0 && colonIdx <= 50) {
      steps.add(
        _Step(
          _capitalise(cleaned.substring(0, colonIdx).trim()),
          cleaned.substring(colonIdx + 2).trim(),
        ),
      );
      continue;
    }

    // Fallback: long sentence — split at first period
    if (cleaned.length > 70) {
      final periodIdx = cleaned.indexOf('. ');
      if (periodIdx > 10 && periodIdx < 80) {
        steps.add(
          _Step(
            cleaned.substring(0, periodIdx + 1).trim(),
            cleaned.substring(periodIdx + 1).trim(),
          ),
        );
        continue;
      }

      // Last resort: split at ~5-word boundary
      final words = cleaned.split(' ');
      final titleWords = words.take(5).join(' ');
      final detailWords = words.skip(5).join(' ');
      steps.add(_Step(titleWords, detailWords));
      continue;
    }

    // Short line with no colon — make it a title with a dash subtitle
    steps.add(_Step(cleaned, 'Processing this step'));
  }

  return steps;
}

String _capitalise(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ── Timeline Step Widget ──────────────────────────────────────────────────────
class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLast;
  final bool isFinal;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isLast,
    required this.isFinal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final successColor = theme.brightness == Brightness.dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    final dotColor = isFinal ? primary : successColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: dot + line ──────────────────────────────────────
          SizedBox(
            width: 28.w,
            child: Column(
              children: [
                // Smaller dot — visually distinct from header icon
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor.withValues(alpha: 0.12),
                    border: Border.all(color: dotColor, width: 1.5),
                  ),
                  child: Center(
                    child: isFinal
                        ? Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary,
                            ),
                          )
                        : Icon(Icons.check, size: 11.r, color: successColor),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: EdgeInsets.symmetric(vertical: 3.h),
                      color: successColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // ── Right: title + subtitle ───────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h, top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isFinal
                          ? primary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
