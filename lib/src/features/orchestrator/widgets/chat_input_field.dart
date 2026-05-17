import 'package:ai_service_orchestrator/src/consts/base_colors.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: BaseColors.surface,
        border: Border(top: BorderSide(color: BaseColors.border)),
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
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: BaseColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final input = ref.watch(chatInputProvider);
                final isThinking = ref.watch(isAgentThinkingProvider);
                final canSend = input.trim().isNotEmpty && !isThinking;

                return InkWell(
                  onTap: canSend ? () {
                    widget.onSend();
                    _controller.clear();
                    ref.read(chatInputProvider.notifier).state = '';
                  } : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: canSend ? BaseColors.primary : BaseColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: canSend ? Colors.white : BaseColors.textSecondary,
                      size: 20,
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
