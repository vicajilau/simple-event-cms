import 'package:go_router/go_router.dart';
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
      // Ruta de detalle de evento - ahora usa inyección de dependencias
      GoRoute(
        path: '/event/:eventId',
        name: 'event_detail',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return EventDetailScreen(eventId: eventId);
        },
      ),
    ],
  );
}
