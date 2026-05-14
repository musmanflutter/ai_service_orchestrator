import 'package:ai_service_orchestrator/src/common_widgets.dart/dialogs/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool?> showErrorDialog({
  required BuildContext context,
  required String message,
  required String title,
  required Object error,
}) async {
  final colorTheme = Theme.of(context).colorScheme;
  return showAlertDialog(
    context: context,
    titleText: title,
    content: message,
    defaultColor: colorTheme.error,
    title:
        // TITLE
        Row(
          spacing: 10.w,
          children: [
            Icon(Icons.error_outline, color: colorTheme.error, size: 26.r),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.displaySmall!.copyWith(color: colorTheme.error),
            ),
          ],
        ),
  );
}
