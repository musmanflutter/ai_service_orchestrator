import 'dart:async';
import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/widgets/reasoning_bottom_sheet.dart';
import 'package:ai_service_orchestrator/src/features/providers/widgets/provider_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:flutter/material.dart';

String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

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
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, right: 60.w),
          child: const _OrchestratingWidget(),
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
          child: const _ReasoningWidget(),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16.h,
          left: isUser ? 60.w : 0,
          right: isUser ? 0 : (message.providerIds.isNotEmpty ? 16.w : 60.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r).copyWith(
            bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(16.r),
            bottomLeft: isUser ? Radius.circular(16.r) : Radius.circular(4.r),
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
            // Timestamp row
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.6,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Orchestrating Animation ───────────────────────────────────────────────
class _OrchestratingWidget extends StatefulWidget {
  const _OrchestratingWidget();
  @override
  State<_OrchestratingWidget> createState() => _OrchestratingWidgetState();
}

class _OrchestratingWidgetState extends State<_OrchestratingWidget>
    with SingleTickerProviderStateMixin {
  int _activeStep = 0;
  Timer? _stepTimer;
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  static const _steps = [
    'Understanding your request',
    'Finding best available providers',
    'Checking availability & pricing',
    'Preparing recommendation',
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.5, end: 1.0).animate(_pulse);
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (mounted) {
        setState(() => _activeStep = (_activeStep + 1) % _steps.length);
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          16.r,
        ).copyWith(bottomLeft: Radius.circular(4.r)),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, color: primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'Agent is orchestrating workflow...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...List.generate(_steps.length, (i) {
            final isActive = i == _activeStep;
            final isPast = i < _activeStep;
            final isLast = i == _steps.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, _) => Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? primary.withValues(alpha: _pulseAnim.value)
                                : isPast
                                ? primary
                                : Colors.grey.withValues(alpha: 0.3),
                            border: isActive || isPast
                                ? null
                                : Border.all(
                                    color: Colors.grey.withValues(alpha: 0.4),
                                  ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: EdgeInsets.symmetric(vertical: 3.h),
                            color: isPast
                                ? primary.withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                      child: Text(
                        _steps[i],
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isActive
                              ? theme.textTheme.bodyLarge?.color
                              : isPast
                              ? theme.textTheme.bodyMedium?.color
                              : theme.textTheme.bodyMedium?.color?.withValues(
                                  alpha: 0.45,
                                ),
                          fontWeight: isActive
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Reasoning Animation ───────────────────────────────────────────────────
class _ReasoningWidget extends StatefulWidget {
  const _ReasoningWidget();
  @override
  State<_ReasoningWidget> createState() => _ReasoningWidgetState();
}

class _ReasoningWidgetState extends State<_ReasoningWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _dots;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );
    _anims = _dots
        .map(
          (c) => Tween(
            begin: 0.3,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _dots[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _dots) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          16.r,
        ).copyWith(bottomLeft: Radius.circular(4.r)),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.psychology_outlined, size: 20.r, color: primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent is reasoning...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Analyzing providers for the best match',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            children: List.generate(
              3,
              (i) => AnimatedBuilder(
                animation: _anims[i],
                builder: (_, _) => Container(
                  margin: EdgeInsets.only(left: 3.w),
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: _anims[i].value),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
