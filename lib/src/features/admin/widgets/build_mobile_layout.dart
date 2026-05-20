import 'package:ai_service_orchestrator/src/features/admin/widgets/info_row.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildMobileLayout extends StatelessWidget {
  const BuildMobileLayout({
    super.key,
    required this.bookingId,
    required this.providerName,
    required this.service,
    required this.location,
    required this.time,
    required this.complexity,
    required this.urgency,
    this.priceQuote,
    this.priceBreakdown,
    required this.firestoreService,
  });

  final String bookingId;
  final String providerName;
  final String service;
  final String location;
  final String time;
  final String complexity;
  final String urgency;
  final String? priceQuote;
  final String? priceBreakdown;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: Assignment Icon + Header text
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_rounded,
                size: 24.r,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: #$bookingId',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Assigned to: $providerName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),
        Divider(height: 1, color: theme.dividerColor),
        SizedBox(height: 12.h),

        // Service details card box
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                icon: Icons.build_rounded,
                label: 'Service',
                value: service,
              ),
              SizedBox(height: 8.h),
              InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: time,
              ),
              SizedBox(height: 8.h),
              InfoRow(
                icon: Icons.location_on_rounded,
                label: 'Location',
                value: location,
              ),
              SizedBox(height: 8.h),
              InfoRow(
                icon: Icons.speed_outlined,
                label: 'Complexity',
                value: complexity,
                valueColor: complexity == 'Complex'
                    ? theme.colorScheme.error
                    : complexity == 'Intermediate'
                    ? (theme.brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade600)
                    : (theme.brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade600),
              ),
              if (priceQuote != null && priceQuote!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                InfoRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Dynamic Quote',
                  value: 'PKR $priceQuote',
                  subtitle: priceBreakdown,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Double buttons side-by-side
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => firestoreService.updateBookingStatus(
                  bookingId,
                  'completed',
                ),
                icon: Icon(Icons.check_circle_outline_rounded, size: 16.r),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.brightness == Brightness.dark ? Colors.green.shade700 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => firestoreService.updateBookingStatus(
                  bookingId,
                  'cancelled',
                ),
                icon: Icon(Icons.cancel_outlined, size: 16.r),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
