import 'dart:convert';
import 'dart:async'; // Added for Future.wait
import 'package:flutter/services.dart' show rootBundle;
import 'package:github/github.dart' hide Event, Organization; // Keep existing hide clauses
import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../../../core/config/config_loader.dart';
import '../../../core/models/models.dart';

/// Service class responsible for loading event_collection data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoader {
  final Organization organization = getIt<Organization>();

  /// Generic method to load data from a specified path
  /// Automatically determines whether to load from local assets or remote URL
  /// based on the configuration's base URL
  Future<List<dynamic>> loadData(String path) async {
    String content = "";
    if (ConfigLoader.appEnv != 'dev') {
      final url = 'events/${organization.year}/$path';
      var github = GitHub();
      var repositorySlug = RepositorySlug(
        organization.githubUser,
        (await SecureInfo.getGithubKey()).projectName ??
            organization.projectName,
      );
      RepositoryContents res;
      try{
        res = await github.repositories.getContents(
          repositorySlug,
          url,
          ref: "feature/refactor_json_structure",
        );
      }catch(e){
        throw Exception("Error loading production configuration from $url");
      }
      if (res.file == null || res.file!.content == null) {
        throw Exception("Error loading production configuration from $url");
      }
      final file = utf8.decode(
        base64.decode(res.file!.content!.replaceAll("\\n", "")),
      );
      content = file;
    } else if (ConfigLoader.appEnv == 'dev') {
      final localPath = 'events/${organization.year}/$path';
      content = await rootBundle.loadString(localPath);
    }
    // Handle cases where content might be a list or a map containing a list
    final decodedContent = json.decode(content);
    if (path == PathsGithub.eventPath && decodedContent is Map) {
      return decodedContent["events"] as List<dynamic>;
    } else if (decodedContent is List) {
      return decodedContent;
    } else if (decodedContent is Map && decodedContent.containsKey('UID')) {
      // If it's a single object (like a single agenda structure), wrap it in a list
      return [decodedContent];
    }
    // Fallback or specific handling if the root is not a list
    // For now, assuming most JSON roots will be lists of objects
    // or the specific 'events' case handled above.
    // If you have single objects at the root of other JSONs, adjust accordingly.
    // For safety, if it's not a list at this point, treat as error or empty.
    // This part might need adjustment based on actual structure of agenda_days.json, etc.
    // if they are single objects at root instead of lists.
    // Assuming agenda_days.json, days.json, etc., are LISTS of objects.
    if (decodedContent is Map && decodedContent.values.first is List) {
      // If it's a map with a single key and the value is a list (another common pattern for root objects)
      return decodedContent.values.first as List<dynamic>;
    }

    // If after all checks decodedContent is not a List, and not the special eventPath case,
    // this indicates an unexpected JSON structure for the given path.
    // For loadData, we expect a List<dynamic> to be returned for general processing.
    // If your individual JSON files (days.json, tracks.json, sessions.json, agenda_days.json)
    // are single JSON objects at the root rather than arrays, this will need adjustment
    // or the parsing in the specific _loadAll methods will need to handle it.
    // For now, this error helps identify such mismatches.
    throw Exception("Decoded JSON for path $path is not a List as expected by loadData's return type, nor the handled eventPath map structure.");
  }

  // --- Start of New Data Loading Methods ---

  Future<List<Session>> loadAllSessions() async {
    List<dynamic> jsonList = await loadData(PathsGithub.sessionsPath);
    return jsonList.map((jsonItem) => Session.fromJson(jsonItem)).toList();
  }

  Future<List<Track>> loadAllTracks() async {
    List<dynamic> jsonList = await loadData(PathsGithub.tracksPath);
    return jsonList.map((jsonItem) => Track.fromJson(jsonItem)).toList();
  }

  Future<List<AgendaDay>> loadAllDays() async {
    List<dynamic> jsonList = await loadData(PathsGithub.daysPath);
    return jsonList.map((jsonItem) => AgendaDay.fromJson(jsonItem)).toList();
  }

  Future<List<Agenda>> loadAgendaStructures() async {
    List<dynamic> jsonList = await loadData(PathsGithub.agendaPath);
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
    final Map<String, AgendaDay> daysMap = {for (var day in allDays) day.uid: day};
    final Map<String, Track> tracksMap = {for (var track in allTracks) track.uid: track};
    final Map<String, Session> sessionsMap = {for (var session in allSessions) session.uid: session};

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
    List<dynamic> jsonList = await loadData(PathsGithub.speakerPath);
    return jsonList.map((jsonItem) => Speaker.fromJson(jsonItem)).toList();
  }

  /// Loads sponsor information from the sponsors.json file
  Future<List<Sponsor>> loadSponsors() async {
    List<dynamic> jsonList = await loadData(PathsGithub.sponsorPath);
    return jsonList.map((jsonItem) => Sponsor.fromJson(jsonItem)).toList();
  }

  /// Loads event information from the events.json file
  Future<List<Event>> loadEvents() async {
    List<dynamic> jsonList = await loadData(PathsGithub.eventPath);
    return jsonList
        .map<Event>(
          (jsonItem) => Event.fromJson(jsonItem as Map<String, dynamic>),
    )
        .toList();
  }

}
