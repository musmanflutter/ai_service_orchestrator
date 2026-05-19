import 'package:ai_service_orchestrator/src/routing/app_router.dart';
import 'package:ai_service_orchestrator/src/themes/app_theme.dart';
import 'package:ai_service_orchestrator/src/themes/theme_mode.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //GET
    final route = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Determine screen size for responsive design target
    final window = ui.PlatformDispatcher.instance.views.first;
    final size = window.physicalSize / window.devicePixelRatio;
    final isDesktop = size.width > 800;
    
    // Use desktop design size if on a wide screen, otherwise use mobile design size
    final designSize = isDesktop ? const Size(1920, 1080) : const Size(390, 844);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'AI Service Orchestrator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: route,
        );
      },
    );
  }
}
