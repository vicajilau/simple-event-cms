import 'dart:async';

import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github_json_model.dart';

import '../../../core/models/models.dart';
import '../common/commons_api_services.dart';

/// Service class responsible for loading event_collection data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoaderManager {
  static final Config config = getIt<Config>();
  static final CommonsServices commonsServices = CommonsServicesImp();
  static GithubJsonModel? _allData;
  static DateTime? _lastFetchTime;

  Future<void> loadAllEventData({bool forceUpdate = false}) async {
    var githubDataSaving = await SecureInfo.getGithubKey();
    // Check if data is already loaded and if it's been less than 5 minutes
    if (_allData != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(minutes: 5) &&
        githubDataSaving.token == null &&
        !forceUpdate) {
      return; // Do not fetch new data
    }
    var data = await commonsServices.loadData(PathsGithub.eventPath);
    _allData = GithubJsonModel.fromJson(data);
    if (githubDataSaving.token == null) {
      _lastFetchTime = DateTime.now();
    }
  }

  // --- Start of New Data Loading Methods ---

  Future<List<Session>> loadAllSessions() async {
    await loadAllEventData();
    List<Session> jsonList = _allData?.sessions ?? List.empty();
    return jsonList.toList();
  }

  Future<List<Track>> loadAllTracks() async {
    await loadAllEventData();
    List<Track> jsonList = _allData?.tracks ?? List.empty();
    return jsonList.toList();
  }

  Future<List<AgendaDay>> loadAllDays() async {
    await loadAllEventData();
    List<AgendaDay> jsonList = _allData?.agendadays ?? List.empty();

    final List<Track> allTracks = _allData?.tracks ?? List.empty();
    final List<Session> allSessions = _allData?.sessions ?? List.empty();

    for (var track in allTracks) {
      track.resolvedSessions = allSessions
          .where((session) => track.sessionUids.contains(session.uid))
          .toList();
    }
    var agendaDays = jsonList.toList();

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
    await loadAllEventData();
    List<Speaker> jsonList = _allData?.speakers ?? List.empty();
    return jsonList.toList();
  }

  /// Loads sponsor information from the sponsors.json file
  Future<List<Sponsor>> loadSponsors() async {
    await loadAllEventData();
    List<Sponsor> jsonList = _allData?.sponsors ?? List.empty();
    return jsonList.toList();
  }

  /// Loads event information from the githubItem.json file
  Future<List<Event>> loadEvents() async {
    await loadAllEventData();
    var githubService = await SecureInfo.getGithubKey();

    List<Event> jsonList = _allData?.events ?? List.empty();
    if (jsonList.isEmpty ||
        (githubService.token == null &&
            jsonList.indexWhere((event) => event.isVisible) == -1)) {
      return List.empty();
    }

    if (githubService.token != null) {
      return jsonList.toList(growable: true);
    } else {
      return jsonList.where((event) => event.isVisible).toList(growable: true);
    }
  }
}
