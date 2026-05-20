import 'package:ai_service_orchestrator/src/common_widgets.dart/custom_scaffold.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/controller/ai_controller.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/send_message_helper.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_bubble.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/chat_input_field.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/user_bookings_drawer.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/booking_reminder_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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

    return BookingReminderListener(
      child: CustomScaffold(
        drawer: const UserBookingsDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          toolbarHeight: 68.h,
          titleSpacing: 16.w,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                size: 24.r,
                color: theme.textTheme.bodyLarge?.color,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Service Orchestrator',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'Powered by Agentic AI',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.admin_panel_settings_rounded,
                size: 24.r,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => context.go('/admin'),
              tooltip: 'Admin Dashboard',
            ),
            SizedBox(width: 8.w),
          ],
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
                      final message = messages[index];
                      final isLastMessage = index == messages.length - 1;
                      return ChatBubble(
                        message: message,
                        isLatest: isLastMessage,
                      );
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
      ),
    );
  }
}
