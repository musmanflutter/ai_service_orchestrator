import 'package:ai_service_orchestrator/src/features/admin/widgets/info_row.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildDesktopLayout extends StatelessWidget {
  const BuildDesktopLayout({
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

    return Row(
      children: [
        Icon(
          Icons.assignment_rounded,
          size: 40.r,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking ID: #$bookingId',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Assigned to: $providerName',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InfoRow(
                            icon: Icons.build_rounded,
                            label: 'Service',
                            value: service,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Time',
                            value: time,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: location,
                          ),
                        ),
                      ],
                    ),
                    if (priceQuote != null && priceQuote!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: InfoRow(
                              icon: Icons.speed_outlined,
                              label: 'Complexity',
                              value: complexity,
                              valueColor: complexity == 'Complex'
                                  ? Colors.red.shade600
                                  : complexity == 'Intermediate'
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: InfoRow(
                              icon: Icons.attach_money_rounded,
                              label: 'Dynamic Price',
                              value: 'PKR $priceQuote',
                              subtitle: priceBreakdown,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: InfoRow(
                              icon: Icons.offline_bolt_rounded,
                              label: 'Urgency',
                              value: urgency,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 24.w),
        Column(
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  firestoreService.updateBookingStatus(bookingId, 'completed'),
              icon: Icon(Icons.check, size: 16.r),
              label: Text('Complete Job', style: TextStyle(fontSize: 13.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton.icon(
              onPressed: () =>
                  firestoreService.updateBookingStatus(bookingId, 'cancelled'),
              icon: Icon(Icons.close, size: 16.r),
              label: Text('Cancel Job', style: TextStyle(fontSize: 13.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
