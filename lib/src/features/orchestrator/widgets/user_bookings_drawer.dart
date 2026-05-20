import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:ai_service_orchestrator/src/features/providers/data/mock_providers.dart';
import 'package:ai_service_orchestrator/src/themes/theme_mode.dart';
import 'package:ai_service_orchestrator/src/common_widgets.dart/sharedpreference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserBookingsDrawer extends ConsumerWidget {
  const UserBookingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = currentThemeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 8.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Bookings', style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.amber : Colors.blueGrey,
                    ),
                    onPressed: () {
                      final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                      ref.read(themeModeProvider.notifier).state = newMode;
                      Preference.setString('theme', isDark ? 'light' : 'dark');
                    },
                    tooltip: 'Toggle Theme',
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, height: 1),

            // ── Bookings list ────────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getAllBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  var bookings = snapshot.data?.docs.toList() ?? [];
                  bookings.sort((a, b) {
                    final aT = (a.data() as Map)['createdAt'] as Timestamp?;
                    final bT = (b.data() as Map)['createdAt'] as Timestamp?;
                    if (aT == null || bT == null) return 0;
                    return bT.compareTo(aT);
                  });

                  if (bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48.r,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No bookings yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final doc =
                          bookings[index].data() as Map<String, dynamic>;
                      final bookingId = doc['id'] as String? ?? '';
                      
                      return Dismissible(
                        key: Key(bookingId),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: theme.scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                    color: theme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header Row
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.r),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.delete_forever_rounded,
                                              color: theme.colorScheme.error,
                                              size: 24.r,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              'Delete Booking',
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      // Content Text
                                      Text(
                                        'Are you sure you want to delete this booking reference?',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      SizedBox(height: 24.h),
                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Cancel Button
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 12.h,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          // Confirm Button
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.error,
                                              foregroundColor: theme.colorScheme.onError,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.w,
                                                vertical: 12.h,
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onError,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ) ?? false;
                        },
                        onDismissed: (direction) {
                          firestoreService.deleteBooking(bookingId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Booking deleted successfully',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: theme.colorScheme.onError,
                            size: 24.r,
                          ),
                        ),
                        child: _BookingCard(doc: doc, theme: theme),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final ThemeData theme;

  const _BookingCard({required this.doc, required this.theme});

  @override
  Widget build(BuildContext context) {
    final status = doc['status'] as String? ?? 'pending';
    final providerName = doc['providerName'] as String? ?? 'Unknown';
    final bookingId = doc['id'] as String? ?? '';
    final time = doc['time'] as String? ?? 'Unknown Time';
    final providerId = doc['providerId'] as String? ?? '';
    final scheduledTimestamp = doc['scheduledTimestamp'] as String?;
    final timeDisplay = _formatBookingTime(scheduledTimestamp, time);

    // Look up provider data from mock
    final provider = mockProviders.where((p) => p.id == providerId).firstOrNull;
    final rating = provider?.rating ?? 0.0;
    final price = provider != null
        ? 'PKR ${provider.basePrice} - ${provider.maxPrice}'
        : '';
    final emoji = provider?.avatarEmoji ?? '👨‍🔧';

    // Status config
    final _StatusConfig cfg = _statusConfig(status, theme);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(left: BorderSide(color: cfg.color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + name + rating + time ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(emoji, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 24.sp)),
                  ),
                ),
                SizedBox(width: 12.w),

                // Name + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating (full width now)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              providerName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating > 0) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14.r,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              rating.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 5.h),
                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.r,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              timeDisplay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12.sp,
                                color: theme.textTheme.bodyMedium?.color,
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

            SizedBox(height: 12.h),
            Divider(height: 1, color: theme.dividerColor),
            SizedBox(height: 10.h),

            // ── Bottom row: status badge + price ───────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status pill (bottom-left)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: cfg.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      cfg.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: cfg.color,
                      ),
                    ),
                  ],
                ),

                // Price (bottom-right)
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 4.h),

            // Booking ID (small, below the status row)
            Text(
              '#${bookingId.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.45,
                ),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status config ─────────────────────────────────────────────────────────────
class _StatusConfig {
  final String label;
  final Color color;
  const _StatusConfig(this.label, this.color);
}

_StatusConfig _statusConfig(String status, ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  switch (status) {
    case 'completed':
      return _StatusConfig('Completed', isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A));
    case 'cancelled':
      return _StatusConfig('Cancelled', theme.colorScheme.error);
    case 'confirmed':
      return _StatusConfig('Confirmed', isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706));
    default:
      return _StatusConfig('In Progress', theme.colorScheme.primary);
  }
}

String _formatBookingTime(String? scheduledTimestamp, String timeFallback) {
  if (scheduledTimestamp == null || scheduledTimestamp.isEmpty) {
    return timeFallback;
  }
  try {
    final parsed = DateTime.parse(scheduledTimestamp).toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[parsed.month - 1];
    final day = parsed.day;
    final hour = parsed.hour > 12
        ? parsed.hour - 12
        : (parsed.hour == 0 ? 12 : parsed.hour);
    final period = parsed.hour >= 12 ? 'PM' : 'AM';
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day $month, $hour:$minute $period';
  } catch (_) {
    return timeFallback;
  }
}
