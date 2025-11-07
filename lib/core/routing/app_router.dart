import 'package:go_router/go_router.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

import '../../presentation/ui/screens/organization/organization_screen.dart';

// ignore: avoid_classes_with_only_static_members
class AppRouter {
  // Paths
  static const String homePath = '/'; 
  static const String eventFormPath = '/events/edit';
  static const String eventDetailPath = '/event/detail/:eventId/:location/:onlyOneEvent';
  static const String agendaFormPath = '/agenda/form';
  static const String speakerFormPath = '/speaker/form';
  static const String sponsorFormPath = '/sponsor/form';
  static const String organizationFormPath = '/config/form';

  // Names
  static const String homeName = 'home';
  static const String eventFormName = 'admin_edit_event';
  static const String eventDetailName = 'event_detail';
  static const String agendaFormName = 'agenda_form';
  static const String speakerFormName = 'speaker_form';
  static const String sponsorFormName = 'sponsor_form';
  static const String organizationFormName = 'organization_form';

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
              final location = state.pathParameters['location'] ?? '';
              bool onlyOneEvent = bool.tryParse(state.pathParameters['onlyOneEvent'].toString()) ?? false;
              return EventDetailScreen(eventId: eventId,location: location,onlyOneEvent: onlyOneEvent);
            },
          ),
        ],
      ),
      GoRoute(
        path: eventFormPath,
        name: eventFormName,
        builder: (context, state) => state.extra == null
            ? EventFormScreen()
            : EventFormScreen(eventId: state.extra.toString()),
      ),
      GoRoute(
        path: organizationFormPath,
        name: organizationFormName,
        builder: (context, state) => OrganizationScreen(),
      ),
      GoRoute(
        path: agendaFormPath,
        name: agendaFormName,
        builder: (context, state) {
          final agendaFormData = state.extra as AgendaFormData;
          return AgendaFormScreen(data: agendaFormData);
        },
      ),
      GoRoute(
        path: speakerFormPath,
        name: speakerFormName,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final speaker = extras['speaker'] as Speaker?;
          final eventId = extras['eventId'] as String;
          return SpeakerFormScreen(speaker: speaker, eventUID: eventId);
        },
      ),
      GoRoute(
        path: sponsorFormPath,
        name: sponsorFormName,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final sponsor = extras['sponsor'] as Sponsor?;
          final eventId = extras['eventId'] as String;
          return SponsorFormScreen(sponsor: sponsor, eventUID: eventId);
        },
      ),
    ],
  );
}
