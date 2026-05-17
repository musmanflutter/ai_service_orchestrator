import 'package:ai_service_orchestrator/src/features/orchestrator/pages/orchestrator_chat_page.dart';
import 'package:ai_service_orchestrator/src/routing/route_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // INITIAL
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (_, _) => const OrchestratorChatPage(),
      ),
    ],
  );
});
