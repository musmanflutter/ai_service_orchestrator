import 'package:ai_service_orchestrator/src/consts/base_colors.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/reasoning_bottom_sheet.dart';
import 'package:ai_service_orchestrator/src/features/providers/widgets/provider_card.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    if (message.isThinking) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: BaseColors.surface,
                  border: Border.all(color: BaseColors.agentThinking),
                  borderRadius: BorderRadius.circular(
                    16,
                  ).copyWith(bottomLeft: const Radius.circular(4)),
                ),
                child: Shimmer.fromColors(
                  baseColor: BaseColors.agentThinking,
                  highlightColor: BaseColors.agentThinking.withValues(
                    alpha: 0.5,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: BaseColors.agentThinking,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Agent is orchestrating workflow...",
                        style: TextStyle(
                          color: BaseColors.agentThinking,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Simulated 'View Reasoning' button hook
              if (message.reasoningText.isNotEmpty)
                InkWell(
                  onTap: () {
                    // TODO: Connect to Bottom Sheet
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 14, color: BaseColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          "View Agent Reasoning",
                          style: TextStyle(
                            fontSize: 12,
                            color: BaseColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    }

    final displayString = isUser ? message.rawText : message.chatText;
    
    // If AI is typing reasoning but hasn't reached chat text yet
    if (!isUser && displayString.isEmpty && message.reasoningText.isNotEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 60.0),
          child: Shimmer.fromColors(
            baseColor: BaseColors.textSecondary.withOpacity(0.5),
            highlightColor: BaseColors.textSecondary.withOpacity(0.2),
            child: const Text("Agent is reasoning..."),
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? BaseColors.userBubble : BaseColors.aiBubble,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayString,
              style: TextStyle(
                color: isUser ? Colors.white : BaseColors.textPrimary,
                fontSize: 15,
              ),
            ),
            if (!isUser && message.reasoningText.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                   showReasoningBottomSheet(context, message.reasoningText);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology, size: 14, color: BaseColors.primary),
                    const SizedBox(width: 4),
                    const Text(
                      "View Reasoning Trace",
                      style: TextStyle(fontSize: 12, color: BaseColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (!isUser && message.providerIds.isNotEmpty) ...[
              for (final id in message.providerIds)
                ProviderCard(providerId: id),
            ]
          ],
        )
      ),
    );
  }
}
