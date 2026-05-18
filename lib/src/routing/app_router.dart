import 'package:ai_service_orchestrator/src/features/orchestrator/pages/orchestrator_chat_page.dart';
import 'package:ai_service_orchestrator/src/features/admin/pages/admin_dashboard_page.dart';
import 'package:ai_service_orchestrator/src/routing/route_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/chat',
    debugLogDiagnostics: true,
    routes: [
      // INITIAL
      GoRoute(
        path: '/chat',
        name: AppRoute.chat.name,
        builder: (_, _) => const OrchestratorChatPage(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRoute.admin.name,
        builder: (_, _) => const AdminDashboardPage(),
      ),
    ],
  );
});
