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
    
    String text = '';
    
    // If the full chat tag is closed
    final match = RegExp(r'<chat>(.*?)</chat>', dotAll: true).firstMatch(rawText);
    if (match != null) {
      text = match.group(1)!.trim();
    } else {
      // If chat tag is currently streaming
      final openMatch = RegExp(r'<chat>(.*)', dotAll: true).firstMatch(rawText);
      if (openMatch != null) {
        text = openMatch.group(1)!.trim();
      } else {
        // Fallback: If it's a plain message with no XML formatting at all, just return it
        if (!rawText.contains('<chat>') && !rawText.contains('<reasoning>')) {
          text = rawText;
        }
      }
    }
    
    // Robustly post-process 'text' to ensure NO XML tags or their contents leak to user screen.
    // 1. Strip <asking_for> tag and its contents completely
    text = text.replaceAll(RegExp(r'<asking_for>.*?</asking_for>', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<asking_for>.*', dotAll: true), '');
    
    // 2. Strip <provider> tag and its contents completely
    text = text.replaceAll(RegExp(r'<provider>.*?</provider>', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<provider>.*', dotAll: true), '');
    
    // 3. Strip <context> tag and its contents completely
    text = text.replaceAll(RegExp(r'<context>.*?</context>', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<context>.*', dotAll: true), '');
    
    // 4. Strip <reasoning> tag and its contents completely
    text = text.replaceAll(RegExp(r'<reasoning>.*?</reasoning>', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<reasoning>.*', dotAll: true), '');
    
    // 5. Clean up any loose leftover tag brackets
    text = text.replaceAll('</asking_for>', '');
    text = text.replaceAll('</provider>', '');
    text = text.replaceAll('</context>', '');
    text = text.replaceAll('</reasoning>', '');
    text = text.replaceAll('</chat>', '');
    
    return text.trim();
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

  String get askingFor {
    if (sender != MessageSender.ai) return 'none';
    final match = RegExp(r'<asking_for>(.*?)</asking_for>', dotAll: true).firstMatch(rawText);
    if (match != null) return match.group(1)!.trim().toLowerCase();
    
    // Support streaming/unclosed tag
    final openMatch = RegExp(r'<asking_for>(.*)', dotAll: true).firstMatch(rawText);
    if (openMatch != null) {
      final text = openMatch.group(1)!.trim().toLowerCase();
      // If the text contains '<', it might have started another tag, so clip it
      if (text.contains('<')) {
        return text.split('<').first.trim();
      }
      return text;
    }
    
    return 'none';
  }
}
