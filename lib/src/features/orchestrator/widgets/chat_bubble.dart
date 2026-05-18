import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/reasoning_bottom_sheet.dart';
import 'package:ai_service_orchestrator/src/features/providers/widgets/provider_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.sender == MessageSender.user;

    if (message.sender == MessageSender.system) {
      final isSuccess = message.rawText.contains('SYSTEM SUCCESS:');
      final bgColor = isSuccess ? Colors.green.shade50 : Colors.red.shade50;
      final borderColor = isSuccess
          ? Colors.green.shade200
          : Colors.red.shade200;
      final iconColor = isSuccess ? Colors.green : Colors.red;
      final iconData = isSuccess
          ? Icons.check_circle_outline
          : Icons.warning_amber_rounded;

      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.rawText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(
                    16,
                  ).copyWith(bottomLeft: const Radius.circular(4)),
                ),
                child: Shimmer.fromColors(
                  baseColor: theme.colorScheme.secondary,
                  highlightColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Agent is orchestrating workflow...",
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
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
                    // Connect to Bottom Sheet
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "View Agent Reasoning",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            baseColor: (theme.textTheme.bodyMedium?.color ?? Colors.grey)
                .withValues(alpha: 0.5),
            highlightColor: (theme.textTheme.bodyMedium?.color ?? Colors.grey)
                .withValues(alpha: 0.2),
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
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownWidget(
              data: displayString,
              shrinkWrap: true,
              config: MarkdownConfig(
                configs: [
                  PConfig(
                    textStyle: TextStyle(
                      color: isUser
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),
                ],
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
                    Icon(
                      Icons.psychology,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "View Reasoning Trace",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isUser && message.providerIds.isNotEmpty) ...[
              for (final id in message.providerIds)
                ProviderCard(providerId: id),
            ],
          ],
        ),
      ),
    );
  }
}
