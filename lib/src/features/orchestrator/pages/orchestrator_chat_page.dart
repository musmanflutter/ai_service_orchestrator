import 'package:ai_service_orchestrator/src/common_widgets.dart/custom_scaffold.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/send_message_helper.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_bubble.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_input_field.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/user_bookings_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrchestratorChatPage extends ConsumerStatefulWidget {
  const OrchestratorChatPage({super.key});

  @override
  ConsumerState<OrchestratorChatPage> createState() =>
      _OrchestratorChatPageState();
}

class _OrchestratorChatPageState extends ConsumerState<OrchestratorChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      drawer: const UserBookingsDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.w,
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 20.r,
            ),
            const Text("AI Service Orchestrator"),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final messages = ref.watch(aiControllerProvider);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.r),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return ChatInputField(
                onSend: () {
                  handleSendMessage(ref);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
