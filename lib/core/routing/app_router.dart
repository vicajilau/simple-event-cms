import 'package:go_router/go_router.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

// ignore: avoid_classes_with_only_static_members
class AppRouter {
  // Paths
  static const String homePath = '/';
  static const String adminLoginPath = '/admin';
  static const String adminCreateEventPath = '/admin/events/create';
  static const String adminEditEventPath = '/admin/events/edit/:eventId';
  static const String eventDetailPath = '/event/:eventId';
  static const String speakerFormPath = '/speaker/form/:speakerId';

  // Names
  static const String homeName = 'home';
  static const String loginName = 'login';
  static const String adminName = 'admin';
  static const String adminLoginName = 'admin_login';
  static const String adminCreateEventName = 'admin_create_event';
  static const String adminEditEventName = 'admin_edit_event';
  static const String eventDetailName = 'event_detail';
  static const String speakerFormName = 'speaker_form';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: homeName,
        builder: (context, state) => EventCollectionScreen(crossAxisCount: 4),
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
        builder: (context, state) =>
            EventFormScreen(eventId: state.extra.toString()),
      ),

      GoRoute(
        path: eventDetailPath,
        name: eventDetailName,
        builder: (context, state) {
          final eventId = state.extra.toString();
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: speakerFormPath,
        name: speakerFormName,
        builder: (context, state) {
          final speakerId = state.extra.toString();
          return SpeakerFormScreen(speakerUID: speakerId);
        },
      ),
    ],
  );
}
