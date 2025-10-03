import 'dart:async'; // Added for Future.wait

import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../../../core/models/models.dart';
import '../common/commons_API_services.dart';

/// Service class responsible for loading event_collection data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoader {
  final Organization organization = getIt<Organization>();
  final CommonsServices commonsServices = CommonsServicesImp();

  // --- Start of New Data Loading Methods ---

  Future<List<Session>> loadAllSessions() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.sessionsPath,
    );
    return jsonList.map((jsonItem) => Session.fromJson(jsonItem)).toList();
  }

  Future<List<Track>> loadAllTracks() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.tracksPath,
    );
    return jsonList.map((jsonItem) => Track.fromJson(jsonItem)).toList();
  }

  Future<List<AgendaDay>> loadAllDays() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.daysPath,
    );
    return jsonList.map((jsonItem) => AgendaDay.fromJson(jsonItem)).toList();
  }

  Future<List<Agenda>> loadAgendaStructures() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.agendaPath,
    );
    return jsonList.map((jsonItem) => Agenda.fromJson(jsonItem)).toList();
  }

  /// Loads and assembles the full agenda data from the new JSON structure.
  Future<List<Agenda>> getFullAgendaData() async {
    // Load all data components in parallel
    final results = await Future.wait([
      loadAgendaStructures(),
      loadAllDays(),
      loadAllTracks(),
      loadAllSessions(),
    ]);

    final List<Agenda> agendaStructures = results[0] as List<Agenda>;
    final List<AgendaDay> allDays = results[1] as List<AgendaDay>;
    final List<Track> allTracks = results[2] as List<Track>;
    final List<Session> allSessions = results[3] as List<Session>;

    // Create maps for quick UID lookups
    final Map<String, AgendaDay> daysMap = {
      for (var day in allDays) day.uid: day,
    };
    final Map<String, Track> tracksMap = {
      for (var track in allTracks) track.uid: track,
    };
    final Map<String, Session> sessionsMap = {
      for (var session in allSessions) session.uid: session,
    };

    // Assemble the structure
    for (var agenda in agendaStructures) {
      agenda.resolvedDays = agenda.dayUids
          .map((dayUid) => daysMap[dayUid])
          .where((day) => day != null) // Filter out nulls if a UID is not found
          .cast<AgendaDay>()
          .toList();

      for (var day in agenda.resolvedDays ?? <AgendaDay>[]) {
        day.resolvedTracks = day.trackUids
            .map((trackUid) => tracksMap[trackUid])
            .where((track) => track != null)
            .cast<Track>()
            .toList();

        for (var track in day.resolvedTracks ?? <Track>[]) {
          track.resolvedSessions = track.sessionUids
              .map((sessionUid) => sessionsMap[sessionUid])
              .where((session) => session != null)
              .cast<Session>()
              .toList();
        }
      }
    }
    return agendaStructures;
  }

  // --- End of New Data Loading Methods ---

  /// Loads speaker information from the speakers.json file
  Future<List<Speaker>> loadSpeakers() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.speakerPath,
    );
    return jsonList.map((jsonItem) => Speaker.fromJson(jsonItem)).toList();
  }

  /// Loads sponsor information from the sponsors.json file
  Future<List<Sponsor>> loadSponsors() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.sponsorPath,
    );
    return jsonList.map((jsonItem) => Sponsor.fromJson(jsonItem)).toList();
  }

  /// Loads event information from the events.json file
  Future<List<Event>> loadEvents() async {
    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.eventPath,
    );
    return jsonList
        .map<Event>(
          (jsonItem) => Event.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  }
}
