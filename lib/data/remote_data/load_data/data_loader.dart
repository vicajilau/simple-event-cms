import 'dart:async'; // Added for Future.wait

import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../../../core/models/models.dart';
import '../common/commons_api_services.dart';

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

    final List<Track> allTracks = await loadAllTracks();
    final List<Session> allSessions = await loadAllSessions();

    for (var track in allTracks) {
      track.resolvedSessions = allSessions
          .where((session) => track.sessionUids.contains(session.uid))
          .toList();
    }
    var agendaDays = jsonList
        .map((jsonItem) => AgendaDay.fromJson(jsonItem))
        .toList();
    for (var day in agendaDays) {
      day.resolvedTracks = allTracks
          .where((track) => day.trackUids?.contains(track.uid) == true)
          .toList();
    }
    return agendaDays;
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
    var githubService = await SecureInfo.getGithubKey();

    List<dynamic> jsonList = await commonsServices.loadData(
      PathsGithub.eventPath,
    );
    if (jsonList.isEmpty ||
        (githubService.token == null &&
            jsonList.indexWhere(
                  (event) =>
                      (Event.fromJson(event as Map<String, dynamic>)).isVisible,
                ) ==
                -1)) {
      return [];
    }

    if (githubService.token != null) {
      return jsonList
          .map<Event>(
            (jsonItem) => Event.fromJson(jsonItem as Map<String, dynamic>),
          )
          .toList();
    } else {
      return jsonList
          .map<Event>(
            (jsonItem) => Event.fromJson(jsonItem as Map<String, dynamic>),
          )
          .where((event) => event.isVisible)
          .toList();
    }
  }
}
