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
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            children: [
              // ── Text input field ────────────────────────────────
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return TextFormField(
                      controller: _controller,
                      onChanged: (val) {
                        ref.read(chatInputProvider.notifier).state = val;
                      },
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 10.h,
                        ),
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.45,
                          ),
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(width: 8.w),

              // ── Send Button ────────────────────────────────────
              Consumer(
                builder: (context, ref, child) {
                  final input = ref.watch(chatInputProvider);
                  final isThinking = ref.watch(isAgentThinkingProvider);
                  final canSend = input.trim().isNotEmpty && !isThinking;

                  return GestureDetector(
                    onTap: canSend
                        ? () {
                            widget.onSend();
                            _controller.clear();
                            ref.read(chatInputProvider.notifier).state = '';
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: canSend
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.25,
                                  ),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 3.h),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: canSend
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.4,
                                ),
                          size: 20.r,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
