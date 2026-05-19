import 'dart:convert';

enum MessageSender { user, ai, system }

class ChatMessage {
  final String id;
  final String rawText;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.rawText,
    required this.sender,
    required this.timestamp,
    this.isThinking = false,
  });

  // GETTERS FOR PARSING THE AI'S STRUCTURED STREAMING RESPONSE
  
  String get chatText {
    if (sender != MessageSender.ai) return rawText;
    
    // If the full chat tag is closed
    final match = RegExp(r'<chat>(.*?)</chat>', dotAll: true).firstMatch(rawText);
    if (match != null) return match.group(1)!.trim();
    
    // If chat tag is currently streaming
    final openMatch = RegExp(r'<chat>(.*)', dotAll: true).firstMatch(rawText);
    if (openMatch != null) return openMatch.group(1)!.trim();
    
    // If it hasn't reached the chat tag yet (still thinking/reasoning)
    // Fallback: If it's a plain message with no XML formatting at all, just return it
    if (!rawText.contains('<chat>') && !rawText.contains('<reasoning>')) {
      return rawText;
    }
    
    return '';
  }

  String get reasoningText {
    if (sender != MessageSender.ai) return '';
    
    final match = RegExp(r'<reasoning>(.*?)</reasoning>', dotAll: true).firstMatch(rawText);
    if (match != null) return match.group(1)!.trim();
    
    final openMatch = RegExp(r'<reasoning>(.*)', dotAll: true).firstMatch(rawText);
    if (openMatch != null) return openMatch.group(1)!.trim();
    
    return '';
  }

  List<String> get providerIds {
    if (sender != MessageSender.ai) return [];
    final matches = RegExp(r'<provider>(.*?)</provider>', dotAll: true).allMatches(rawText);
    return matches.map((m) => m.group(1)!.trim()).where((id) => id.isNotEmpty).toList();
  }

  Map<String, String>? get bookingContext {
    if (sender != MessageSender.ai) return null;
    final match = RegExp(r'<context>(.*?)</context>', dotAll: true).firstMatch(rawText);
    if (match != null) {
      try {
        final jsonString = match.group(1)!.trim();
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return map.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
