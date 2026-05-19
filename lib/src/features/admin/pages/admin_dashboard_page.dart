import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.read(firestoreServiceProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin / Provider Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPendingBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
            return const Center(child: Text('No active pending bookings.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(24.w),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final bookingId = booking['id'] as String? ?? 'Unknown';
              final providerName = booking['providerName'] as String? ?? 'Unknown';
              final service = booking['service'] as String? ?? 'Unknown Service';
              final location = booking['location'] as String? ?? 'Unknown Location';
              final time = booking['time'] as String? ?? 'Unknown Time';

              return Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 40.r,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking ID: $bookingId',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
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
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.build, size: 14.r, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Service: $service',
                                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14.r, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Time: $time',
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14.r, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Location: $location',
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          firestoreService.updateBookingStatus(
                            bookingId,
                            'completed',
                          );
                        },
                        icon: Icon(Icons.check, size: 16.r),
                        label: Text('Complete Job', style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        onPressed: () {
                          firestoreService.updateBookingStatus(
                            bookingId,
                            'cancelled',
                          );
                        },
                        icon: Icon(Icons.close, size: 16.r),
                        label: Text('Cancel Job', style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
