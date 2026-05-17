import 'package:ai_service_orchestrator/src/common_widgets.dart/custom_scaffold.dart';
import 'package:ai_service_orchestrator/src/consts/base_colors.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/send_message_helper.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_bubble.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrchestratorChatPage extends StatelessWidget {
  const OrchestratorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: BaseColors.primary, size: 20),
            SizedBox(width: 8),
            Text("AI Service Orchestrator"),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: BaseColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final messages = ref.watch(aiControllerProvider);
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: false, 
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
