import 'package:ai_service_orchestrator/my_app.dart';
import 'package:ai_service_orchestrator/src/common_widgets.dart/sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

void main() async {
  //SYSTEM RELATED
  WidgetsFlutterBinding.ensureInitialized();

  //DEVICE ORIENTATION , FIREBASE INITIALIZATION, LOCAL STORAGE
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),

    Preference.init(),
  ]);

  runApp(ProviderScope(child: ToastificationWrapper(child: const MyApp())));
}
