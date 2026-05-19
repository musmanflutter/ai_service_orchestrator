import 'package:flutter_riverpod/legacy.dart';

final chatInputProvider = StateProvider<String>((ref) => '');
final isAgentThinkingProvider = StateProvider<bool>((ref) => false);

// Maps providerId -> { 'bookingId': String, 'status': String }
final providerBookingStatesProvider = StateProvider<Map<String, Map<String, String>>>((ref) => {});
