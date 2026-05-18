import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_service_orchestrator/src/features/providers/data/mock_providers.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/feedback_dialog.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firestore_service.dart';

class ProviderCard extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderCard({super.key, required this.providerId});

  @override
  ConsumerState<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<ProviderCard> {
  String bookingStatus = 'none'; // none, pending, completed, cancelled
  StreamSubscription<DocumentSnapshot>? _bookingSub;

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  void _bookProvider(BuildContext context, String providerName, int basePrice) {
    setState(() => bookingStatus = 'pending');

    // Generate random mock booking ID
    final bookingId =
        'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Write to Firestore
    ref
        .read(firestoreServiceProvider)
        .createBooking(bookingId, widget.providerId, providerName);

    // Listen to Firestore for Admin updates
    _bookingSub = ref
        .read(firestoreServiceProvider)
        .listenToBooking(bookingId)
        .listen((doc) {
          if (!doc.exists) return;
          final status = doc['status'] as String;

          if (status == 'cancelled' && bookingStatus != 'cancelled') {
            setState(() => bookingStatus = 'cancelled');
            ref
                .read(aiControllerProvider.notifier)
                .triggerCancellation(widget.providerId);
            if (Navigator.canPop(context)) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // Close receipt if open
            }
          } else if (status == 'completed' && bookingStatus != 'completed') {
            setState(() => bookingStatus = 'completed');
            if (Navigator.canPop(context)) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // Close receipt if open
            }

            showFeedbackDialog(context, (rating, comment) {
              ref
                  .read(aiControllerProvider.notifier)
                  .triggerFeedback(widget.providerId, rating, comment);
            });
          }
        });

    final theme = Theme.of(context);

    // Show Receipt Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              'Booking Confirmed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking ID:',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        bookingId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Provider:',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost Estimate:',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Rs. $basePrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                      Text(
                        'Waiting for Provider...',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'An automated SMS has been sent to the provider. The AI is monitoring the status.',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Chat Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = mockProviders
        .where((p) => p.id == widget.providerId)
        .firstOrNull;

    if (provider == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bookingStatus == 'completed'
            ? Colors.green.withValues(alpha: 0.1)
            : (bookingStatus == 'cancelled'
                  ? Colors.redAccent.withValues(alpha: 0.1)
                  : theme.cardTheme.color),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bookingStatus == 'none'
              ? theme.dividerColor
              : (bookingStatus == 'completed'
                    ? Colors.green
                    : (bookingStatus == 'cancelled'
                          ? Colors.redAccent
                          : Colors.green)),
        ),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    provider.rating.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    ' (${provider.reviewCount})',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 4),
              Text(
                '${provider.distanceKm} km away',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                'Rs. ${provider.basePrice}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bookingStatus == 'none')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _bookProvider(context, provider.name, provider.basePrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: bookingStatus == 'completed'
                    ? Colors.green
                    : (bookingStatus == 'cancelled'
                          ? Colors.red
                          : Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                bookingStatus == 'completed'
                    ? 'Job Completed ✅'
                    : (bookingStatus == 'cancelled'
                          ? 'Booking Cancelled ❌'
                          : 'Booking Confirmed ✅'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (bookingStatus == 'pending') ...[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Waiting for provider updates in Admin panel...",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
