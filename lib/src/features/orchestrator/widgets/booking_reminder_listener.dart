import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';
import 'package:ai_service_orchestrator/src/common_widgets.dart/sharedpreference.dart';
import 'package:toastification/toastification.dart';

class BookingReminderListener extends ConsumerStatefulWidget {
  final Widget child;

  const BookingReminderListener({super.key, required this.child});

  @override
  ConsumerState<BookingReminderListener> createState() =>
      _BookingReminderListenerState();
}

class _BookingReminderListenerState
    extends ConsumerState<BookingReminderListener> {
  Timer? _timer;
  final Set<String> _notifiedBookingIds = {};

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[Reminder] BookingReminderListener initialized. Starting poll every 10s...',
    );
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      debugPrint('[Reminder] Polling Firestore...');
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final userId = Preference.getUserId();
        final snapshot = await firestoreService.getPendingBookingsFuture(userId);
        final now = DateTime.now()
            .toUtc(); // Use UTC to match AI-generated timestamps

        debugPrint(
          '[Reminder] ${snapshot.docs.length} pending booking(s) found. Now: $now',
        );

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final bookingId = (data['id'] as String?) ?? doc.id;
          final scheduledTimestamp = data['scheduledTimestamp'] as String?;
          final service = (data['service'] as String?) ?? 'Service Provider';

          debugPrint(
            '[Reminder] Booking=$bookingId | scheduledTimestamp=$scheduledTimestamp | service=$service',
          );

          if (scheduledTimestamp == null) {
            debugPrint(
              '[Reminder] ⚠️  No scheduledTimestamp on $bookingId — skipping.',
            );
            continue;
          }

          if (_notifiedBookingIds.contains(bookingId)) {
            debugPrint('[Reminder] ✅ Already notified $bookingId — skipping.');
            continue;
          }

          try {
            final scheduledTime = DateTime.parse(scheduledTimestamp);
            final difference = scheduledTime.difference(now);
            debugPrint(
              '[Reminder] $bookingId: ${difference.inSeconds}s remaining.',
            );

            // Trigger when 0 < seconds remaining <= 60
            if (difference.inSeconds <= 60 && difference.inSeconds > 0) {
              debugPrint('[Reminder] 🔔 Triggering toast for $bookingId!');
              _notifiedBookingIds.add(bookingId);

              if (mounted) {
                final theme = Theme.of(context);
                toastification.show(
                  context: context,
                  type: ToastificationType.warning,
                  style: ToastificationStyle.fillColored,
                  title: Text(
                    'Booking Reminder!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  description: Text(
                    'Your $service provider is arriving in less than 1 minute!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 10),
                  showProgressBar: true,
                  icon: const Icon(Icons.timer, color: Colors.white),
                  primaryColor: Colors.deepOrange,
                );
              }
            } else if (difference.inSeconds <= 0) {
              debugPrint('[Reminder] ⏰ $bookingId has already passed.');
            }
          } catch (parseError) {
            debugPrint(
              '[Reminder] ❌ Parse error for "$scheduledTimestamp": $parseError',
            );
          }
        }
      } catch (e) {
        debugPrint('[Reminder] ❌ Poll error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
