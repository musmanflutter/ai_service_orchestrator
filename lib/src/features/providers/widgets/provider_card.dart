import 'package:flutter/material.dart';
import 'package:ai_service_orchestrator/src/consts/base_colors.dart';
import 'package:ai_service_orchestrator/src/features/providers/data/mock_providers.dart';

class ProviderCard extends StatelessWidget {
  final String providerId;

  const ProviderCard({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final provider = mockProviders.where((p) => p.id == providerId).firstOrNull;

    if (provider == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaseColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: BaseColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    provider.rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: BaseColors.textPrimary),
                  ),
                  Text(
                    ' (${provider.reviewCount})',
                    style: const TextStyle(color: BaseColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: BaseColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${provider.distanceKm} km away',
                style: const TextStyle(color: BaseColors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              Text(
                'Rs. ${provider.basePrice}',
                style: const TextStyle(color: BaseColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Handle Booking Confirmation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BaseColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
