import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

import '../../presentation/ui/screens/organization/organization_screen.dart';

// ignore: avoid_classes_with_only_static_members
class AppRouter {
  // Paths
  static const String homePath = '/';
  static const String adminPath = '/admin';
  static const String eventFormPath = '/events/edit';
  static const String eventDetailPath = '/event/detail/:eventId';
  static const String agendaFormPath = '/agenda/form';
  static const String speakerFormPath = '/speaker/form';
  static const String sponsorFormPath = '/sponsor/form';
  static const String organizationFormPath = '/organization/form';

  // Names
  static const String homeName = 'home';
  static const String adminName = 'admin';
  static const String eventFormName = 'admin_edit_event';
  static const String eventDetailName = 'event_detail';
  static const String agendaFormName = 'agenda_form';
  static const String speakerFormName = 'speaker_form';
  static const String sponsorFormName = 'sponsor_form';
  static const String organizationFormName = 'organization_form';

  // Router estático
  static late GoRouter router;

  static Future<bool> _hasAdminSession() async {
    final githubData = await SecureInfo.getGithubKey();
    return githubData.token != null && githubData.token!.isNotEmpty;
  }

  static void init() {
    router = GoRouter(
      initialLocation: homePath,
      redirect: (context, state) async {
        final hasAdminSession = await _hasAdminSession();

        // si ya hay token guardado y el usuario intenta ir al login admin, lo mandamos al home
        if (hasAdminSession && state.matchedLocation == adminPath) {
          return homePath;
        }

        return null;
      },
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
            ),
          ],
        ),

        GoRoute(
          path: adminPath,
          name: adminName,
          builder: (context, state) {
            return FutureBuilder(
              future: _hasAdminSession(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.data == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) context.go(homePath);
                  });
                  return const SizedBox.shrink();
                }

                return const AdminLoginScreen();
              },
            );
          },
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
}
