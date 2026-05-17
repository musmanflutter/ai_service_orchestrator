import 'package:flutter/material.dart';
import 'package:ai_service_orchestrator/src/consts/base_colors.dart';

void showReasoningBottomSheet(BuildContext context, String reasoningText) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: BaseColors.primary),
                const SizedBox(width: 8),
                const Text(
                  "Agentic Reasoning Trace",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BaseColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: BaseColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BaseColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BaseColors.border),
              ),
              child: Text(
                reasoningText.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: BaseColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}
