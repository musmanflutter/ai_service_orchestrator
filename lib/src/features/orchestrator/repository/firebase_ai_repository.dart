import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAiRepositoryProvider = Provider<FirebaseAiRepository>((ref) {
  return FirebaseAiRepository();
});

class FirebaseAiRepository {
  late final GenerativeModel _model;

  FirebaseAiRepository() {
    // ignore: deprecated_member_use
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.5-flash',
    );
  }

  Stream<GenerateContentResponse> streamChatResponse(
    List<Content> history,
    String newMessage,
  ) {
    final chat = _model.startChat(history: history);
    return chat.sendMessageStream(Content.text(newMessage));
  }
}
