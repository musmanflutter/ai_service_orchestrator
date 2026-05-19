import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputField extends StatefulWidget {
  final VoidCallback onSend;

  const ChatInputField({super.key, required this.onSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  return TextFormField(
                    controller: _controller,
                    onChanged: (val) {
                      ref.read(chatInputProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: "Need an AC technician?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Consumer(
              builder: (context, ref, child) {
                final input = ref.watch(chatInputProvider);
                final isThinking = ref.watch(isAgentThinkingProvider);
                final canSend = input.trim().isNotEmpty && !isThinking;

                return InkWell(
                  onTap: canSend
                      ? () {
                          widget.onSend();
                          _controller.clear();
                          ref.read(chatInputProvider.notifier).state = '';
                        }
                      : null,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: canSend
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: canSend
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                      size: 20.r,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
