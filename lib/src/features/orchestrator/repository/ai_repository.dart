import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_key.dart';

part 'ai_repository.g.dart';

class AIRepository {
  final GenerativeModel _model;

  AIRepository(String apiKey)
    : _model = GenerativeModel(
        // Using gemini-1.5-flash because the free tier API key blocks Pro models
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

  /// Streams a response from Gemini based on the conversation history
  Stream<GenerateContentResponse> streamChatResponse(
    List<Content> history,
    String newMessage,
  ) {
    final chat = _model.startChat(history: history);
    return chat.sendMessageStream(Content.text(newMessage));
  }
}

@Riverpod(keepAlive: true)
AIRepository aiRepository(Ref ref) {
  return AIRepository(geminiApiKey);
}

