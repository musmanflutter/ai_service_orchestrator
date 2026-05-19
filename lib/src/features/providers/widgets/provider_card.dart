import 'dart:async';
import 'package:ai_service_orchestrator/src/features/providers/models/provider.dart';
import 'package:flutter/material.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_service_orchestrator/src/features/providers/data/mock_providers.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/feedback_dialog.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';

class ProviderCard extends ConsumerStatefulWidget {
  final String providerId;
  final Map<String, String>? bookingContext;

  const ProviderCard({
    super.key,
    required this.providerId,
    this.bookingContext,
  });

  @override
  ConsumerState<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<ProviderCard> {
  String bookingStatus = 'none';
  StreamSubscription<DocumentSnapshot>? _bookingSub;

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreBookingSubscription();
    });
  }

  void _restoreBookingSubscription() {
    if (!mounted) return;
    final persisted = ref.read(
      providerBookingStatesProvider,
    )[widget.providerId];
    if (persisted != null) {
      final bookingId = persisted['bookingId']!;
      final status = persisted['status']!;
      setState(() {
        bookingStatus = status;
      });

      // Restore active listener for live status syncing
      if (_bookingSub == null && (status == 'pending' || status == 'none')) {
        _subscribeToBooking(bookingId);
      }
    }
  }

  void _subscribeToBooking(String bookingId) {
    _bookingSub?.cancel();
    _bookingSub = ref
        .read(firestoreServiceProvider)
        .listenToBooking(bookingId)
        .listen((doc) {
          if (!doc.exists) return;
          final status = doc['status'] as String;

          // Update persisted global state
          ref.read(providerBookingStatesProvider.notifier).update((map) {
            final existing = map[widget.providerId];
            if (existing == null) return map;
            return {
              ...map,
              widget.providerId: {...existing, 'status': status},
            };
          });

          if (status == 'cancelled' && bookingStatus != 'cancelled') {
            setState(() => bookingStatus = 'cancelled');
            ref
                .read(aiControllerProvider.notifier)
                .triggerCancellation(widget.providerId);
            if (!mounted) return;
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          } else if (status == 'completed' && bookingStatus != 'completed') {
            setState(() => bookingStatus = 'completed');
            if (!mounted) return;
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            showFeedbackDialog(context, (rating, comment) {
              ref
                  .read(aiControllerProvider.notifier)
                  .triggerFeedback(widget.providerId, rating, comment);
            });
          } else {
            if (status != bookingStatus) {
              setState(() => bookingStatus = status);
            }
          }
        });
  }

  void _bookProvider(String providerName, int basePrice) {
    setState(() => bookingStatus = 'pending');

    final bookingId =
        'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Persist globally immediately
    ref.read(providerBookingStatesProvider.notifier).update((map) {
      return {
        ...map,
        widget.providerId: {'bookingId': bookingId, 'status': 'pending'},
      };
    });

    ref
        .read(firestoreServiceProvider)
        .createBooking(
          bookingId,
          widget.providerId,
          providerName,
          widget.bookingContext?['service'] ?? 'Unknown Service',
          widget.bookingContext?['location'] ?? 'Unknown Location',
          widget.bookingContext?['time'] ?? 'Unknown Time',
          widget.bookingContext?['scheduledTimestamp'],
        );

    _subscribeToBooking(bookingId);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Sparkle dots + checkmark ───────────────────────────
              Container(
                width: 68.r,
                height: 68.r,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 16.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36.r,
                ),
              ),

              SizedBox(height: 12.h),

              // ── Title + subtitle ──────────────────────────────────
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Your booking has been confirmed.\nWe\'ll notify you once the service is completed.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              // ── Info rows ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _infoRow(theme, 'Provider', providerName),
                    Divider(height: 1, color: theme.dividerColor),
                    _infoRow(
                      theme,
                      'Date & Time',
                      _formatBookingTime(
                        widget.bookingContext?['scheduledTimestamp'],
                        widget.bookingContext?['time'] ?? 'On Request',
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _infoRow(theme, 'Booking ID', '#$bookingId'),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'View Chat Dashboard',
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
      ),
    );
  }

  // Clean info row helper
  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final provider = mockProviders
        .where((p) => p.id == widget.providerId)
        .firstOrNull;

    if (provider == null) return const SizedBox.shrink();

    final service = widget.bookingContext?['service'] ?? provider.category;
    final scheduledTimestamp = widget.bookingContext?['scheduledTimestamp'];
    final rawTime = widget.bookingContext?['time'] ?? 'On Request';
    final availability = _formatBookingTime(scheduledTimestamp, rawTime);
    final priceRange =
        'PKR ${provider.basePrice} - ${provider.maxPrice > 0 ? provider.maxPrice : provider.basePrice + 500}';

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        color: bookingStatus == 'completed'
            ? Colors.green.withValues(alpha: 0.06)
            : bookingStatus == 'cancelled'
            ? Colors.red.withValues(alpha: 0.06)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: bookingStatus == 'none'
              ? theme.dividerColor
              : bookingStatus == 'completed'
              ? Colors.green
              : bookingStatus == 'cancelled'
              ? Colors.red
              : Colors.green,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Provider Header ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circle
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      provider.avatarEmoji,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + verified badge
                      Row(
                        spacing: 6.w,
                        children: [
                          Icon(Icons.verified, color: primary, size: 18.r),
                          Expanded(
                            child: Text(
                              provider.name,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // Rating + distance
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 15.r),
                          SizedBox(width: 3.w),
                          Text(
                            '${provider.rating}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                          Text(
                            ' (${provider.reviewCount})',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.r,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              '${provider.distanceKm} km away',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Tags
                      if (provider.tags.isNotEmpty)
                        Wrap(
                          spacing: 6.w,
                          children: provider.tags.map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    size: 11.r,
                                    color: Colors.green.shade700,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Divider ───────────────────────────────────────────────
          Divider(height: 1, color: theme.dividerColor),

          // ─── Info Grid ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoCell(
                        theme,
                        icon: Icons.build_outlined,
                        label: 'Service',
                        value: service,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _infoCell(
                        theme,
                        icon: Icons.calendar_today_outlined,
                        label: 'Availability',
                        value: availability,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoCell(
                        theme,
                        icon: Icons.attach_money_outlined,
                        label: 'Estimated Price',
                        value: priceRange,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _infoCell(
                        theme,
                        icon: Icons.shield_outlined,
                        label: 'Reliability',
                        value: provider.reliabilityPercent,
                        valueColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Why this provider? ────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ).copyWith(bottom: 14.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why this provider?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ..._getWhyReasons(provider).map(
                    (reason) => Padding(
                      padding: EdgeInsets.only(bottom: 5.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 15.r,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            reason,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Book Now Button ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: bookingStatus == 'none'
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _bookProvider(provider.name, provider.basePrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: bookingStatus == 'cancelled'
                          ? Colors.red
                          : Colors.green,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bookingStatus == 'completed'
                          ? 'Job Completed ✅'
                          : bookingStatus == 'cancelled'
                          ? 'Booking Cancelled ❌'
                          : 'Booking Confirmed ✅',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoCell(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.r, color: theme.textTheme.bodyMedium?.color),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.bodyLarge?.color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<String> _getWhyReasons(ServiceProvider provider) {
    final reasons = <String>[];
    if (provider.rating >= 4.7) reasons.add('Highest Rated in your area');
    if (provider.distanceKm <= 3.0) reasons.add('Quick Availability');
    if (provider.cancellationRate <= 0.05) reasons.add('Best Price');
    if (provider.tags.contains('Fast Response')) {
      reasons.add('Fast Response Time');
    }
    if (reasons.isEmpty) reasons.add('Best Match for your request');
    return reasons.take(3).toList();
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
}
