import 'dart:async';
import 'dart:convert';
import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/prompts.dart';
import 'package:ai_service_orchestrator/src/features/providers/repository/provider_repository.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/repository/firebase_ai_repository.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ggi;
import 'package:firebase_vertexai/firebase_vertexai.dart' as fva;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_controller.g.dart';

@Riverpod(keepAlive: true)
class AiController extends _$AiController {
  StreamSubscription<fva.GenerateContentResponse>? _subscription;

  @override
  List<ChatMessage> build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [
      ChatMessage(
        id: 'welcome',
        rawText:
            '<chat>**Hi! I\'m AI Service Orchestrator** 👋\nHow can I help you today?</chat>',
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

  Future<void> triggerCancellation(String providerId) async {
    final systemAlert = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rawText:
          'SYSTEM ALERT: The provider with ID $providerId has just cancelled the booking! You MUST apologize to the user and immediately recommend the NEXT BEST provider from the database for their original request.',
      sender: MessageSender.system,
      timestamp: DateTime.now(),
    );
    state = [...state, systemAlert];

    // Trigger AI response without a new user prompt
    await streamAiResponse(null);
  }

  Future<void> triggerFeedback(
    String providerId,
    double rating,
    String comment,
  ) async {
    final alertText = rating <= 3
        ? 'SYSTEM ALERT: The user has completed the job with Provider ID $providerId but gave a POOR rating of $rating stars. Their complaint: "$comment". You MUST immediately initiate Dispute Resolution: Apologize to the user, assure them that the provider will be heavily penalized in our database, and offer support.'
        : 'SYSTEM SUCCESS: The user has completed the job with Provider ID $providerId and gave a GREAT rating of $rating stars. Comment: "$comment". Thank the user for using the AI Orchestrator and let them know the provider will be rewarded and ranked higher next time.';

    final systemAlert = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rawText: alertText,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
    );
    state = [...state, systemAlert];
    await streamAiResponse(null);
  }

  void stopGenerating() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    ref.read(isAgentThinkingProvider.notifier).state = false;

    state = state.map((msg) {
      if (msg.isThinking) {
        final currentText = msg.rawText;
        String stoppedText = currentText;
        
        // Handle unclosed asking_for tag
        if (stoppedText.contains('<asking_for>') && !stoppedText.contains('</asking_for>')) {
          stoppedText = '${stoppedText.replaceAll(RegExp(r'<asking_for>.*', dotAll: true), '')}<asking_for>none</asking_for>';
        }

        if (!stoppedText.contains('</chat>')) {
          if (stoppedText.contains('<chat>')) {
            stoppedText = '$stoppedText [Stopped by user]</chat>';
          } else if (stoppedText.contains('</reasoning>')) {
            stoppedText = '$stoppedText\n\n<chat>Generation stopped by user.</chat>';
          } else if (stoppedText.contains('<reasoning>')) {
            stoppedText = '$stoppedText [Stopped by user]</reasoning>\n\n<chat>Generation stopped by user.</chat>';
          } else {
            stoppedText = '<chat>Generation stopped by user.</chat>';
          }
        }

        return ChatMessage(
          id: msg.id,
          rawText: stoppedText,
          sender: msg.sender,
          timestamp: msg.timestamp,
          isThinking: false,
        );
      }
      return msg;
    }).toList();
  }

  Future<void> streamAiResponse(String? prompt) async {
    // Cancel existing subscription if any
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    // Set thinking state to true
    ref.read(isAgentThinkingProvider.notifier).state = true;

    final providerRepo = ref.read(providerRepositoryProvider);

    // 1. Fetch Mock Providers & Serialize to JSON
    final providers = await providerRepo.fetchAllProviders();
    final providersJson = jsonEncode(providers.map((p) => p.toJson()).toList());

    // 2. Generate the Agentic System Prompt
    final currentTime = DateTime.now()
        .toUtc()
        .toIso8601String(); // Always UTC so AI computes correct timestamps
    final systemPrompt = SystemPrompts.getAgenticOrchestratorPrompt(
      providersJson,
      currentTime,
    );

    // 3. Build History (Inject System Prompt at the very beginning)
    final historyGgi = <ggi.Content>[ggi.Content.text(systemPrompt)];
    final historyFva = <fva.Content>[fva.Content.text(systemPrompt)];

    final previousMessages = state.where(
      (msg) => !msg.isThinking && msg.id != 'welcome',
    );

    for (var msg in previousMessages) {
      historyGgi.add(
        msg.sender == MessageSender.user || msg.sender == MessageSender.system
            ? ggi.Content.text(msg.rawText)
            : ggi.Content.model([ggi.TextPart(msg.rawText)]),
      );

      historyFva.add(
        msg.sender == MessageSender.user || msg.sender == MessageSender.system
            ? fva.Content.text(msg.rawText)
            : fva.Content.model([fva.TextPart(msg.rawText)]),
      );
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

    debugPrint('--- SENDING REQUEST ---');

    final completer = Completer<void>();

    try {
      final stream = prompt != null
          ? ref
                .read(firebaseAiRepositoryProvider)
                .streamChatResponse(historyFva, prompt)
          : ref
                .read(firebaseAiRepositoryProvider)
                .streamChatResponse(historyFva, '');

      _subscription = stream.listen(
        (chunk) {
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
        },
        onError: (e, stackTrace) {
          debugPrint('API ERROR: $e $stackTrace');

          state = state.map((msg) {
            if (msg.id == aiMessageId && msg.rawText.isEmpty) {
              return ChatMessage(
                id: msg.id,
                rawText: 'Error connecting to AI Backend: $e',
                sender: msg.sender,
                timestamp: msg.timestamp,
              );
            }
            return msg;
          }).toList();

          ref.read(isAgentThinkingProvider.notifier).state = false;
          _subscription = null;
          completer.complete();
        },
        onDone: () {
          ref.read(isAgentThinkingProvider.notifier).state = false;
          _subscription = null;
          completer.complete();
        },
        cancelOnError: true,
      );

      await completer.future;

    } catch (e, stackTrace) {
      debugPrint('API ERROR: $e $stackTrace');

      state = state.map((msg) {
        if (msg.id == aiMessageId && msg.rawText.isEmpty) {
          return ChatMessage(
            id: msg.id,
            rawText: 'Error connecting to AI Backend: $e',
            sender: msg.sender,
            timestamp: msg.timestamp,
          );
        }
        return msg;
      }).toList();

      ref.read(isAgentThinkingProvider.notifier).state = false;
      _subscription = null;
    }
  }
}
