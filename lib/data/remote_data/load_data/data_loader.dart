import 'dart:async';

import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github_json_model.dart';

import '../../../core/models/models.dart';
import '../common/commons_api_services.dart';

/// Service class responsible for loading event_collection data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoader {
  static final Organization organization = getIt<Organization>();
  static final CommonsServices commonsServices = CommonsServicesImp();
  static GithubJsonModel? _allData;
  static Completer<void> _dataCompleter = Completer<void>();
  static DateTime? _lastFetchTime;

  Future<void> _loadAllEventData() async {
    if (_dataCompleter.isCompleted) {
      if (_lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
        return _dataCompleter.future;
      }
      _dataCompleter = Completer<void>(); // Reset for re-fetching
    }

    // If a fetch is already in progress, just wait for it to complete.
    if (_dataCompleter.isCompleted == false && _allData != null) {
      return _dataCompleter.future;
    }

    try {
      final data = await commonsServices.loadData(PathsGithub.eventPath);
      _allData = GithubJsonModel.fromJson(data);
      _lastFetchTime = DateTime.now();
      _dataCompleter.complete();
    } catch (e) {
      _dataCompleter.completeError(e);
    }
    return _dataCompleter.future;
  }

  // --- Start of New Data Loading Methods ---

  Future<List<Session>> loadAllSessions() async {
    await _loadAllEventData();
    List<Session> jsonList = _allData?.sessions  ?? [];
    return jsonList.toList();
  }

  Future<List<Track>> loadAllTracks() async {
    await _loadAllEventData();
    List<Track> jsonList = _allData?.tracks  ?? [];
    return jsonList.toList();
  }

  Future<List<AgendaDay>> loadAllDays() async {
    await _loadAllEventData();
    List<dynamic> jsonList = _allData?.agendadays  ?? [];

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
  Future<List<Speaker>?> loadSpeakers() async {
    await _loadAllEventData();
    List<Speaker> jsonList = _allData?.speakers  ?? [];
    return jsonList.toList();
  }

  /// Loads sponsor information from the sponsors.json file
  Future<List<Sponsor>> loadSponsors() async {
    await _loadAllEventData();
    List<Sponsor> jsonList = _allData?.sponsors ?? [];
    return jsonList.toList();
  }

  /// Loads event information from the events.json file
  Future<List<Event>> loadEvents() async {
    await _loadAllEventData();
    var githubService = await SecureInfo.getGithubKey();

    List<Event> jsonList = _allData?.events ?? [];
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
          .toList();
    } else {
      return jsonList
          .where((event) => event.isVisible)
          .toList();
    }
  }
}
