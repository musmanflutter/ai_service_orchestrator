import 'package:ai_service_orchestrator/src/features/admin/widgets/build_desktop_layout.dart';
import 'package:ai_service_orchestrator/src/features/admin/widgets/build_mobile_layout.dart';
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
        title: Text(
          'Admin Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                : Text(
                    'User Chat',
                    style: theme.textTheme.bodyMedium?.copyWith(
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
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
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
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No active pending bookings.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.5,
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

              final accentColor = theme.brightness == Brightness.dark
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFFF59E0B);

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border(
                    left: BorderSide(color: accentColor, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: isMobile
                      ? BuildMobileLayout(
                          bookingId: bookingId,
                          providerName: providerName,
                          service: service,
                          location: location,
                          time: time,
                          complexity: complexity,
                          urgency: urgency,
                          priceQuote: priceQuote,
                          priceBreakdown: priceBreakdown,
                          firestoreService: firestoreService,
                        )
                      : BuildDesktopLayout(
                          bookingId: bookingId,
                          providerName: providerName,
                          service: service,
                          location: location,
                          time: time,
                          complexity: complexity,
                          urgency: urgency,
                          priceQuote: priceQuote,
                          priceBreakdown: priceBreakdown,
                          firestoreService: firestoreService,
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
