import 'package:go_router/go_router.dart';
import 'package:sec/core/routing/screen_factory.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

// ignore: avoid_classes_with_only_static_members
class AppRouter {
  // Paths
  static const String homePath = '/';
  static const String adminLoginPath = '/admin/login';
  static const String adminCreateEventPath = '/admin/events/create';
  static const String adminEditEventPath = '/admin/events/edit/:eventId';
  static const String eventDetailPath = '/event/:eventId';

  // Names
  static const String homeName = 'home';
  static const String loginName = 'login';
  static const String adminName = 'admin';
  static const String adminLoginName = 'admin_login';
  static const String adminCreateEventName = 'admin_create_event';
  static const String adminEditEventName = 'admin_edit_event';
  static const String eventDetailName = 'event_detail';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: homeName,
        builder: (context, state) => ScreenFactory.eventCollectionScreen(),
      ),
      GoRoute(
        path: adminLoginPath,
        name: adminLoginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: adminCreateEventPath,
        name: adminCreateEventName,
        builder: (context, state) => EventFormScreen(),
      ),
      GoRoute(
        path: adminEditEventPath,
        name: adminEditEventName,
        builder: (context, state) => EventFormScreen(eventId: state.pathParameters['eventId'] ?? ''),
      ),
      // Ruta de detalle de evento - ahora usa inyección de dependencias
      GoRoute(
        path: eventDetailPath,
        name: eventDetailName,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return ScreenFactory.eventDetailScreen(eventId);
        },
      ),
    ],
  );
}
