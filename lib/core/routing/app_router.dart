import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const EventCollectionScreen(),
      ),
      // Rutas de administración
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin_login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Ruta de detalle de evento
      GoRoute(
        path: '/event/:eventId',
        name: 'event_detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null) {
            return EventContainerScreen(
              locale: extra['locale'] ?? const Locale('es'),
              localeChanged: (locale) {
                // TODO: Implementar cambio de idioma global
              },
              agendaDays: extra['agendaDays'] ?? [],
              speakers: extra['speakers'] ?? [],
              sponsors: extra['sponsors'] ?? [],
            );
          }
          // Fallback si no se pasan datos
          return const EventCollectionScreen();
        },
      ),
    ],
  );
}
