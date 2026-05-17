import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void handleSendMessage(WidgetRef ref) {
  final text = ref.read(chatInputProvider).trim();
  if (text.isEmpty) return;

  // Clear input field state immediately
  ref.read(chatInputProvider.notifier).state = '';

  // 1. Add user message
  ref.read(aiControllerProvider.notifier).addUserMessage(text);

  // 2. Stream AI response (Using standard Chatbot mode for now)
  ref.read(aiControllerProvider.notifier).streamAiResponse(text);
}
