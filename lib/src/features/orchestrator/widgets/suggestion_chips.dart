import 'package:ai_service_orchestrator/src/features/orchestrator/controller/chat_provider.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/models/chat_message.dart';
import 'package:ai_service_orchestrator/src/features/orchestrator/utils/send_message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SuggestionType { service, location, time, none }

class SuggestionOption {
  final String label;
  final String messageToSend;
  final IconData icon;
  final bool isHighlighted;

  const SuggestionOption({
    required this.label,
    required this.messageToSend,
    required this.icon,
    this.isHighlighted = false,
  });
}

class SuggestionChipsList extends ConsumerWidget {
  final ChatMessage message;

  const SuggestionChipsList({super.key, required this.message});

  static const List<SuggestionOption> serviceSuggestions = [
    SuggestionOption(
      label: 'Electrician',
      messageToSend: 'Electrician',
      icon: Icons.electrical_services_rounded,
    ),
    SuggestionOption(
      label: 'Plumber',
      messageToSend: 'Plumber',
      icon: Icons.plumbing_rounded,
    ),
    SuggestionOption(
      label: 'AC Technician',
      messageToSend: 'AC Technician',
      icon: Icons.ac_unit_rounded,
    ),
  ];

  static const List<SuggestionOption> locationSuggestions = [
    SuggestionOption(
      label: 'G-13',
      messageToSend: 'G-13',
      icon: Icons.location_on_rounded,
    ),
    SuggestionOption(
      label: 'E-11',
      messageToSend: 'E-11',
      icon: Icons.location_on_rounded,
    ),
    SuggestionOption(
      label: 'I-8',
      messageToSend: 'I-8',
      icon: Icons.location_on_rounded,
    ),
    SuggestionOption(
      label: 'DHA',
      messageToSend: 'DHA',
      icon: Icons.location_on_rounded,
    ),
    SuggestionOption(
      label: 'Clifton',
      messageToSend: 'Clifton',
      icon: Icons.location_on_rounded,
    ),
  ];

  static const List<SuggestionOption> timeSuggestions = [
    SuggestionOption(
      label: 'Today',
      messageToSend: 'Today',
      icon: Icons.today_rounded,
    ),
    SuggestionOption(
      label: 'Tomorrow',
      messageToSend: 'Tomorrow',
      icon: Icons.calendar_today_rounded,
    ),
    SuggestionOption(
      label: 'Custom Date',
      messageToSend: 'Custom Date',
      icon: Icons.calendar_month_rounded,
    ),
  ];

  static SuggestionType detectSuggestionType(ChatMessage message) {
    if (message.sender != MessageSender.ai) return SuggestionType.none;

    // Do not show suggestions if a provider recommendation has been served
    if (message.providerIds.isNotEmpty || message.bookingContext != null) {
      return SuggestionType.none;
    }

    final askingFor = message.askingFor;
    if (askingFor == 'service') return SuggestionType.service;
    if (askingFor == 'location') return SuggestionType.location;
    if (askingFor == 'time') return SuggestionType.time;

    return SuggestionType.none;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThinking = ref.watch(isAgentThinkingProvider);
    if (isThinking) return const SizedBox.shrink();

    final type = detectSuggestionType(message);
    if (type == SuggestionType.none) return const SizedBox.shrink();

    final List<SuggestionOption> options;
    switch (type) {
      case SuggestionType.service:
        options = serviceSuggestions;
        break;
      case SuggestionType.location:
        options = locationSuggestions;
        break;
      case SuggestionType.time:
        options = timeSuggestions;
        break;
      case SuggestionType.none:
        options = [];
        break;
    }

    if (options.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color subCardBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.grey.shade50;

    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: subCardBgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor, width: 1.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header inside the nested card
          Row(
            children: [
              Icon(
                type == SuggestionType.service
                    ? Icons.build_circle_outlined
                    : type == SuggestionType.location
                    ? Icons.location_on_outlined
                    : Icons.calendar_today_outlined,
                size: 18.r,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                type == SuggestionType.service
                    ? 'Select a service'
                    : type == SuggestionType.location
                    ? 'Select a location'
                    : 'Choose a booking time',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Horizontal list of chips
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final option = options[index];
                final primaryColor = theme.colorScheme.primary;

                final Color borderColor;
                final Color textColor;
                final Color iconColor;
                final Color bgColor;

                if (option.isHighlighted) {
                  borderColor = primaryColor;
                  textColor = primaryColor;
                  iconColor = primaryColor;
                  bgColor = primaryColor.withValues(alpha: isDark ? 0.18 : 0.1);
                } else {
                  borderColor = theme.dividerColor;
                  textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
                  iconColor = (theme.textTheme.bodyMedium?.color ?? Colors.grey)
                      .withValues(alpha: 0.8);
                  bgColor = theme.colorScheme.surface;
                }

                return Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18.r),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: () async {
                      if (option.label == 'Custom Date') {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (pickedDate != null && context.mounted) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            final finalDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            final hour = finalDateTime.hour % 12 == 0
                                ? 12
                                : finalDateTime.hour % 12;
                            final minute = finalDateTime.minute
                                .toString()
                                .padLeft(2, '0');
                            final period = finalDateTime.hour < 12
                                ? 'AM'
                                : 'PM';
                            final formattedDate =
                                "${finalDateTime.year}-${finalDateTime.month.toString().padLeft(2, '0')}-${finalDateTime.day.toString().padLeft(2, '0')}";
                            final formattedTime = "$hour:$minute $period";
                            final messageText =
                                "$formattedDate at $formattedTime";
                            handleSendMessageWithText(ref, messageText);
                          }
                        }
                      } else {
                        handleSendMessageWithText(ref, option.messageToSend);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: borderColor,
                          width: option.isHighlighted ? 1.5.r : 1.r,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(option.icon, size: 15.r, color: iconColor),
                          SizedBox(width: 6.w),
                          Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: option.isHighlighted
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
