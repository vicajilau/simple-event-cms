import 'package:go_router/go_router.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

// ignore: avoid_classes_with_only_static_members
class AppRouter {
  // Paths
  static const String homePath = '/';
  static const String adminPath = '/admin';
  static const String eventFormPath = '/events/edit';
  static const String eventDetailPath = '/event/detail/:eventId';
  static const String agendaFormPath = 'agenda/form/:agendaId';
  static const String speakerFormPath = 'speaker/form/:speakerId';
  static const String sponsorFormPath = 'sponsor/form';

  // Names
  static const String homeName = 'home';
  static const String adminName = 'admin';
  static const String eventFormName = 'admin_edit_event';
  static const String eventDetailName = 'event_detail';
  static const String agendaFormName = 'agenda_form';
  static const String speakerFormName = 'speaker_form';
  static const String sponsorFormName = 'sponsor_form';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: homeName,
        builder: (context, state) => EventCollectionScreen(crossAxisCount: 4),
        routes: [
          GoRoute(
            path: eventDetailPath,
            name: eventDetailName,
            builder: (context, state) {
              final eventId = state.pathParameters['eventId'] ?? '';
              return EventDetailScreen(eventId: eventId);
            },
            routes: [
              GoRoute(
                path: agendaFormPath,
                name: agendaFormName,
                builder: (context, state) {
                  final agendaId = state.extra.toString();
                  return AgendaFormScreen(
                    agendaId: agendaId,
                    data: EventFormData(
                      rooms: [],
                      days: [],
                      speakers: [],
                      sessionTypes: [],
                      session: null,
                      track: '',
                      day: '',
                    ),
                  );
                },
              ),
              GoRoute(
                path: speakerFormPath,
                name: speakerFormName,
                builder: (context, state) {
                  final speaker = state.extra as Speaker?;
                  return SpeakerFormScreen(speaker: speaker);
                },
              ),
              GoRoute(
                path: sponsorFormPath,
                name: sponsorFormName,
                builder: (context, state) {
                  final sponsor = state.extra as Sponsor?;
                  return SponsorFormScreen(sponsor: sponsor);
                },
              ),
            ],
          ),
          GoRoute(
            path: adminPath,
            name: adminName,
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: eventFormPath,
            name: eventFormName,
            builder: (context, state) =>
                EventFormScreen(eventId: state.extra.toString()),
          ),
        ],
      ),
    ],
  );
}
