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

  /// Generic method to load data from a specified path
  /// Automatically determines whether to load from local assets or remote URL
  /// based on the configuration's base URL
  ///
  /// [path] The relative path to the data file
  /// Returns a Future containing the parsed JSON data as a dynamic list
  /// Throws an Exception if the data cannot be loaded
  Future<List<dynamic>> loadData(String path) async {
    String content = "";
    if (ConfigLoader.appEnv != 'dev') {
      // Remote loading
      final url = 'events/${organization.year}/$path';
      var github = GitHub();
      var repositorySlug = RepositorySlug(
        organization.githubUser,
        (await SecureInfo.getGithubKey()).projectName ??
            organization.projectName,
      );
      final res = await github.repositories.getContents(
        repositorySlug,
        url,
        ref: "main",
      );
      if (res.file == null || res.file!.content == null) {
        throw Exception(
          "Error cargando configuración de producción desde $url",
        );
      }
      final file = utf8.decode(
        base64.decode(res.file!.content!.replaceAll("\n", "")),
      );
      content =
          file; // No es necesario codificar a JSON aquí, ya es una cadena JSON
    } else if (ConfigLoader.appEnv == 'dev') {
      // Local loading
      final localPath = 'events/${organization.year}/$path';
      content = await rootBundle.loadString(localPath);
    }
    if (path == PathsGithub.eventPath) {
      return json.decode(content)["events"];
    } else {
      return json.decode(content);
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
