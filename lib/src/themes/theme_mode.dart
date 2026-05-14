//PROVIDER
import 'package:ai_service_orchestrator/src/common_widgets.dart/sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final theme = Preference.getString('theme');
  ThemeMode mode;

  switch (theme) {
    case 'system':
      mode = ThemeMode.system;
      break;
    case 'light':
      mode = ThemeMode.light;
      break;
    case 'dark':
      mode = ThemeMode.dark;
      break;
    default:
      mode = ThemeMode.light;
  }

  return mode;
});
