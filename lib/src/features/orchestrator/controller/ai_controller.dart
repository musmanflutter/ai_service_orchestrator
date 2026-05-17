import 'dart:convert';
import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/ai_repository.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/prompts.dart';
import 'package:ai_service_orchestrator/src/features/providers/repository/provider_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_controller.g.dart';

@riverpod
class AiController extends _$AiController {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        id: 'welcome',
        rawText: '<chat>Hi! I am your AI Service Orchestrator. What service do you need in Pakistan today?</chat>',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void addUserMessage(String text) {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rawText: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];
  }

  Future<void> streamAiResponse(String prompt) async {
    final aiRepo = ref.read(aiRepositoryProvider);
    final providerRepo = ref.read(providerRepositoryProvider);

    // 1. Fetch Mock Providers & Serialize to JSON
    final providers = await providerRepo.fetchAllProviders();
    final providersJson = jsonEncode(providers.map((p) => p.toJson()).toList());

    // 2. Generate the Agentic System Prompt
    final systemPrompt = SystemPrompts.getAgenticOrchestratorPrompt(providersJson);

    // 3. Build History (Inject System Prompt at the very beginning)
    final history = <Content>[
      Content.text(systemPrompt), // The brain instructions
    ];

    final previousMessages = state
        .where((msg) => msg.sender != MessageSender.system && !msg.isThinking && msg.id != 'welcome');
        
    for (var msg in previousMessages) {
       history.add(msg.sender == MessageSender.user
          ? Content.text(msg.rawText)
          : Content.model([TextPart(msg.rawText)]));
    }

    final aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    final aiMsg = ChatMessage(
      id: aiMessageId,
      rawText: '',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isThinking: true, // Set to true to show shimmer animation
    );
    
    state = [...state, aiMsg];

    debugPrint('--- SENDING REQUEST TO GEMINI ---');
    debugPrint('Prompt: $prompt');
    debugPrint('History Length: ${history.length}');

    try {
      final stream = aiRepo.streamChatResponse(history, prompt);

      await for (final chunk in stream) {
        if (chunk.text != null) {
          state = state.map((msg) {
            if (msg.id == aiMessageId) {
              return ChatMessage(
                id: msg.id,
                rawText: msg.rawText + chunk.text!,
                sender: msg.sender,
                timestamp: msg.timestamp,
                isThinking: false,
              );
            }
            return msg;
          }).toList();
        }
      }
    } catch (e, stackTrace) {
      // ADDED DEBUG PRINT HERE FOR ERROR TRACING
      debugPrint('GEMINI API ERROR: $e');
      debugPrint('STACKTRACE: $stackTrace');
      
      state = state.map((msg) {
        if (msg.id == aiMessageId && msg.rawText.isEmpty) {
          return ChatMessage(
            id: msg.id,
            rawText: 'Error connecting to Gemini: $e',
            sender: msg.sender,
            timestamp: msg.timestamp,
          );
        }
        return msg;
      }).toList();
    }
  }
}
