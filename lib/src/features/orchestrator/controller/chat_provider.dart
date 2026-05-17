import 'package:flutter_riverpod/legacy.dart';

final chatInputProvider = StateProvider<String>((ref) => '');
final isAgentThinkingProvider = StateProvider<bool>((ref) => false);
