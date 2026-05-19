import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.read(firestoreServiceProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: isMobile,
        actions: [
          // Switch back to User View
          TextButton.icon(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.forum_rounded, color: Colors.white),
            label: isMobile
                ? const SizedBox.shrink()
                : const Text(
                    'User Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPendingBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var bookings = snapshot.data?.docs.toList() ?? [];

          // Sort locally to avoid Firestore Composite Index requirements
          bookings.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // descending
          });

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 64.r,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No active pending bookings.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.w : 24.w,
              vertical: 20.h,
            ),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final bookingId = booking['id'] as String? ?? 'Unknown';
              final providerName =
                  booking['providerName'] as String? ?? 'Unknown';
              final service =
                  booking['service'] as String? ?? 'Unknown Service';
              final location =
                  booking['location'] as String? ?? 'Unknown Location';
              final time = booking['time'] as String? ?? 'Unknown Time';

              // Agentic dynamic metadata
              final complexity = booking['complexity'] as String? ?? 'Basic';
              final urgency = booking['urgency'] as String? ?? 'Normal';
              final priceQuote = booking['priceQuote'] as String?;
              final priceBreakdown = booking['priceBreakdown'] as String?;

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border(
                    left: BorderSide(color: Colors.orange.shade400, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: isMobile
                      ? _buildMobileLayout(
                          context,
                          theme,
                          bookingId,
                          providerName,
                          service,
                          location,
                          time,
                          complexity,
                          urgency,
                          priceQuote,
                          priceBreakdown,
                          firestoreService,
                        )
                      : _buildDesktopLayout(
                          context,
                          theme,
                          bookingId,
                          providerName,
                          service,
                          location,
                          time,
                          complexity,
                          urgency,
                          priceQuote,
                          priceBreakdown,
                          firestoreService,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Mobile Responsive Card Layout ──────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    String bookingId,
    String providerName,
    String service,
    String location,
    String time,
    String complexity,
    String urgency,
    String? priceQuote,
    String? priceBreakdown,
    FirestoreService firestoreService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: Assignment Icon + Header text
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Assigned to: $providerName',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
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
              _infoRow(theme, Icons.build_rounded, 'Service', service),
              SizedBox(height: 8.h),
              _infoRow(theme, Icons.access_time_rounded, 'Time', time),
              SizedBox(height: 8.h),
              _infoRow(theme, Icons.location_on_rounded, 'Location', location),
              SizedBox(height: 8.h),
              _infoRow(
                theme,
                Icons.speed_outlined,
                'Complexity',
                complexity,
                valueColor: complexity == 'Complex'
                    ? Colors.red.shade600
                    : complexity == 'Intermediate'
                    ? Colors.blue.shade600
                    : Colors.green.shade600,
              ),
              if (priceQuote != null && priceQuote.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _infoRow(
                  theme,
                  Icons.attach_money_rounded,
                  'Dynamic Quote',
                  'PKR $priceQuote',
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
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
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
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Desktop Card Layout ──────────────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    String bookingId,
    String providerName,
    String service,
    String location,
    String time,
    String complexity,
    String urgency,
    String? priceQuote,
    String? priceBreakdown,
    FirestoreService firestoreService,
  ) {
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
                          child: _infoRow(
                            theme,
                            Icons.build_rounded,
                            'Service',
                            service,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _infoRow(
                            theme,
                            Icons.access_time_rounded,
                            'Time',
                            time,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _infoRow(
                            theme,
                            Icons.location_on_rounded,
                            'Location',
                            location,
                          ),
                        ),
                      ],
                    ),
                    if (priceQuote != null && priceQuote.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _infoRow(
                              theme,
                              Icons.speed_outlined,
                              'Complexity',
                              complexity,
                              valueColor: complexity == 'Complex'
                                  ? Colors.red.shade600
                                  : complexity == 'Intermediate'
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _infoRow(
                              theme,
                              Icons.attach_money_rounded,
                              'Dynamic Price',
                              'PKR $priceQuote',
                              subtitle: priceBreakdown,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _infoRow(
                              theme,
                              Icons.offline_bolt_rounded,
                              'Urgency',
                              urgency,
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

  // ── Info Row Helper ────────────────────────────────────────────────────────
  Widget _infoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    String? subtitle,
  }) {
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
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 22.w, top: 2.h),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
