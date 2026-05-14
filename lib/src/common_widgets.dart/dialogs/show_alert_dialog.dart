import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool?> showAlertDialog({
  required BuildContext context,
  required String titleText,
  required String content,
  Widget? title,
  String? cancelActionText,
  String defaultActionText = 'OK',
  Color? defaultColor,
  void Function()? onPressed,
}) async {
  final textTheme = Theme.of(context).textTheme;
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: title ?? Text(titleText, style: textTheme.displaySmall),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150.h),
            child: SingleChildScrollView(
              child: Text(content, style: textTheme.bodyMedium),
            ),
          ),
          actions: <Widget>[
            if (cancelActionText != null)
              TextButton(
                child: Text(
                  cancelActionText,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),

            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(true),
              child: Text(
                defaultActionText,
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: defaultColor,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
