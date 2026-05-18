import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:ai_service_orchestrator/src/themes/theme_mode.dart';
import 'package:ai_service_orchestrator/src/common_widgets.dart/sharedpreference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            Padding(
              padding: const EdgeInsets.all(20.0),
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
            Divider(color: theme.dividerColor),
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
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return bTime.compareTo(aTime); // descending
                  });

                  if (bookings.isEmpty) {
                    return Center(
                      child: Text(
                        'You have no bookings yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final doc =
                          bookings[index].data() as Map<String, dynamic>;
                      final status = doc['status'] as String;
                      final providerName = doc['providerName'] as String;
                      final bookingId = doc['id'] as String;
                      final createdAt = doc['createdAt'] as Timestamp?;

                      Color statusColor;
                      IconData statusIcon;
                      if (status == 'completed') {
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                      } else if (status == 'cancelled') {
                        statusColor = Colors.redAccent;
                        statusIcon = Icons.cancel;
                      } else {
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending_actions;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.cardTheme.color,
                        shape: theme.cardTheme.shape,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(
                              alpha: 0.15,
                            ),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          title: Text(
                            providerName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                bookingId,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              if (createdAt != null)
                                Text(
                                  createdAt.toDate().toString().split('.')[0],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
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
