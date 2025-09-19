import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:github/github.dart' hide Event, Organization;
import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../../../core/config/config_loader.dart';
import '../../../core/models/models.dart';

/// Service class responsible for loading event_collection data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoader {
  final Organization organization = getIt<Organization>();

  /// Generic method to load data from a specified path.
  /// Automatically determines whether to load from local assets or a remote GitHub URL
  /// based on the `ConfigLoader.appEnv` configuration.
  ///
  /// [path] The relative path to the data file (e.g., 'config/events.json').
  /// Returns a Future containing the parsed JSON data as a dynamic list.
  /// Throws an Exception if the data cannot be loaded or parsed.
  Future<List<dynamic>> loadData(String path) async {
    String jsonString = "";

    if (ConfigLoader.appEnv != 'dev') {
      // --- Remote Loading from GitHub ---
      final githubData = await SecureInfo.getGithubKey();
      final branch =
          githubData.branch; // Use dynamic branch with a fallback
      final url = 'events/${organization.year}/$path';

      // Initialize authenticated GitHub client
      final github = GitHub(auth: Authentication.withToken(githubData.token));
      final repositorySlug = RepositorySlug(
        organization.githubUser,
        githubData.projectName ?? organization.projectName,
      );

      try {
        final contents = await github.repositories.getContents(
          repositorySlug,
          url,
          ref: branch, // Use the dynamically fetched branch
        );

        final file = contents.file;
        if (file == null || file.content == null) {
          throw Exception(
            "The path '$url' on branch '$branch' is not a file or is empty.",
          );
        }

        // Decode the Base64 content to a readable JSON string
        jsonString = utf8.decode(
          base64.decode(file.content!.replaceAll("\n", "")),
        );
      } catch (e) {
        // Provide more context on the error
        throw Exception(
          "Failed to load remote data from '$url' on branch '$branch': $e",
        );
      }
    } else {
      // --- Local Loading from Assets ---
      final localPath = 'events/${organization.year}/$path';
      jsonString = await rootBundle.loadString(localPath);
    }

    // --- Unified Parsing Logic ---
    // Now, parse the jsonString regardless of its source (local or remote)
    final dynamic jsonData = json.decode(jsonString);
      // For all other files (speakers, agenda, etc.), assume the root is a list
      if (jsonData is List<dynamic>) {
        return jsonData;
      } else {
        throw Exception(
          "Expected data from '$path' to be a JSON list, but got ${jsonData.runtimeType}.",
        );
      }

  }

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<List<Speaker>> loadSpeakers() async {
    List<dynamic> jsonList = await loadData(PathsGithub.speakerPath);
    return jsonList.map((jsonItem) => Speaker.fromJson(jsonItem)).toList();
  }

  /// Loads event_collection agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<List<Agenda>> loadAgenda() async {
    var jsonList = await loadData(PathsGithub.agendaPath);
    return jsonList.map((jsonItem) => Agenda.fromJson(jsonItem)).toList();
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<List<Sponsor>> loadSponsors() async {
    List<dynamic> jsonList = await loadData(PathsGithub.sponsorPath);
    return jsonList.map((jsonItem) => Sponsor.fromJson(jsonItem)).toList();
  }

  /// Loads event information from the events.json file
  /// Returns a Future containing a list of event data
  Future<List<Event>> loadEvents() async {
    List<dynamic> jsonList = await loadData(PathsGithub.eventPath);
    return jsonList
        .map<Event>(
          (jsonItem) => Event.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  }
}
