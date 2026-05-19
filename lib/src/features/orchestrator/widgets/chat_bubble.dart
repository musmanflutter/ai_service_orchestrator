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
          margin: EdgeInsets.symmetric(vertical: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: iconColor, size: 20.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message.rawText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13.sp,
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
      final thinkingColor = theme.brightness == Brightness.light 
          ? const Color(0xFF17A2B8) // Vibrant cyan for light mode
          : const Color(0xFF38BDF8); // Bright sky blue for dark mode

      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, right: 60.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(color: thinkingColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(
                    16.r,
                  ).copyWith(bottomLeft: Radius.circular(4.r)),
                ),
                child: Shimmer.fromColors(
                  baseColor: thinkingColor,
                  highlightColor: thinkingColor.withOpacity(0.4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16.r,
                        color: thinkingColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Agent is orchestrating workflow...",
                        style: TextStyle(
                          color: thinkingColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Simulated 'View Reasoning' button hook
              if (message.reasoningText.isNotEmpty)
                InkWell(
                  onTap: () {
                    // Connect to Bottom Sheet
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 14.r,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "View Agent Reasoning",
                          style: TextStyle(
                            fontSize: 12.sp,
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
          padding: EdgeInsets.only(bottom: 16.h, right: 60.w),
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
          bottom: 16.h,
          left: isUser ? 60.w : 0,
          right: isUser ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r).copyWith(
            bottomRight: isUser
                ? Radius.circular(4.r)
                : Radius.circular(16.r),
            bottomLeft: isUser
                ? Radius.circular(16.r)
                : Radius.circular(4.r),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
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
              SizedBox(height: 8.h),
              InkWell(
                onTap: () {
                  showReasoningBottomSheet(context, message.reasoningText);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 14.r,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "View Reasoning Trace",
                      style: TextStyle(
                        fontSize: 12.sp,
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
                ProviderCard(
                  providerId: id,
                  bookingContext: message.bookingContext,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
