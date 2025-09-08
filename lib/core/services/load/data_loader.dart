import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sec/core/config/paths_github.dart';

import '../../config/config_loader.dart';
import '../../models/models.dart';

/// Service class responsible for loading event data from various sources
/// Supports both local asset loading and remote HTTP loading based on configuration
class DataLoader {
  /// Site configuration containing base URL and other settings
  final List<Event> config;

  final Organization organization;

  /// Creates a new DataLoader with the specified configuration
  DataLoader(this.config, this.organization);

  /// Generic method to load data from a specified path
  /// Automatically determines whether to load from local assets or remote URL
  /// based on the configuration's base URL
  ///
  /// [path] The relative path to the data file
  /// Returns a Future containing the parsed JSON data as a dynamic list
  /// Throws an Exception if the data cannot be loaded
  Future<List<dynamic>> loadData(String path,String year) async {
    String content = '';
    if (ConfigLoader.appEnv != 'dev' &&
        organization.pathUrl.startsWith('http')) {
      // Remote loading
      final url = '${organization.pathUrl}/$path';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception("Error loading data from $url");
      }
      content = res.body;
    } else if (ConfigLoader.appEnv == 'dev') {
      // Local loading
      final localPath = 'events/$year/$path';
      content = await rootBundle.loadString(localPath);
    }
    return json.decode(content);
  }

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<List<Speaker>> loadSpeakers(String year) async {
    List<dynamic> jsonList = await loadData(PathsGithub.SPEAKER_PATH,year);
    return jsonList.map((jsonItem) => Speaker.fromJson(jsonItem)).toList();
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<List<Agenda>> loadAgenda(String year) async {
    var jsonList = await loadData(PathsGithub.AGENDA_PATH,year);
    return jsonList.map((jsonItem) => Agenda.fromJson(jsonItem)).toList();
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<List<Sponsor>> loadSponsors(String year) async {
    List<dynamic> jsonList = await loadData(PathsGithub.SPONSOR_PATH,year);
    return jsonList.map((jsonItem) => Sponsor.fromJson(jsonItem)).toList();
  }
}
