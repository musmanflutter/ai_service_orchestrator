import 'package:ai_service_orchestrator/src/common_widgets.dart/dialogs/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomScaffold extends StatefulWidget {
  const CustomScaffold({super.key, this.appBar, this.body, this.drawer});
  final AppBar? appBar;
  final Widget? body;
  final Widget? drawer;

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1: CLOSE DRAWER IF OPEN
        if (scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.of(context).pop();
          return;
        }

        // 2: NORMAL NAVIGATION
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        // 3: ROOT SCREEN → ASK EXIT
        final shouldExit = await showAlertDialog(
          context: context,
          titleText: 'Exit?',
          content: 'Are you sure you want to exit?',
          cancelActionText: 'Cancel',
          defaultActionText: 'Exit',
        );
        if (shouldExit == true) SystemNavigator.pop();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            appBar: widget.appBar,
            drawer: widget.drawer,
            body: widget.body,
          ),
        ),
      ),
    );
  }
}
