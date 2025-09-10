import 'dart:convert';

import 'package:github/github.dart' hide Event;
import 'package:http/http.dart' as http;
import 'package:sec/core/core.dart';

import '../../models/github/github_services.dart';
import '../../models/models.dart';

class DataUpdateInfo {
  /// Site configuration containing base URL and other settings
  final DataLoader dataLoader;

  // Variable de tipo GithubService para interactuar con la API de GitHub
  final GithubService githubService;

  DataUpdateInfo({required this.dataLoader, required this.githubService});

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeakers(List<Speaker> speakers) async {
    return _updateData(speakers,speakers[0].pathUrl, "Update speakers from JSON");
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(List<Agenda> agenda) async {
    return _updateData(agenda,agenda[0].pathUrl, "Update agendas from JSON");
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(List<Sponsor> sponsors) async {
    return _updateData(sponsors,sponsors[0].pathUrl, "Update sponsors from JSON");
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvents(List<Event> events) async {
    return _updateData(events,events[0].pathUrl, "Update events from JSON");
  }

  Future<http.Response> getSha(GithubService githubService) async {
    final fileUrl =
        "${githubService.repo}${githubService.repo}?ref=${githubService.branch}";

    var github = GitHub(auth: Authentication.withToken(githubService.token));
    final res = await github.putJSON(
      fileUrl,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      //final content = utf8.decode(base64Decode(data['content']));
      return data['sha'];
    } else {
      throw Exception("Failed to get sha");
    }
  }

  /// Generic function to update data on GitHub
  Future<http.Response> _updateData<T>(
      List<T> data,
      String pathUrl,
      String commitMessage,
      ) async {
    // Convert data to JSON and then to base64
    final dataInfo = base64Encode(
      utf8.encode(
        json.encode(
          data.map((item) {
            if (item is Speaker) return item.toJson();
            if (item is Agenda) return item.toJson();
            if (item is Sponsor) return item.toJson();
            if (item is Event) return item.toJson();
            throw Exception("Unsupported type: ${T.runtimeType}");
          }).toList(),
        ),
      ),
    );

    // Prepare the request body
    final body = json.encode({
      "message": commitMessage,
      "content": dataInfo,
      "sha": githubService.sha,
    });

    // Construct the file URL
    final fileUrl =
        "${githubService.repo}/$pathUrl?ref=${githubService.branch}";

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    // Make the PUT request
    final res = await github.putJSON(
      fileUrl,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
      body: body,
    );

    // Check the response status
    if (res.statusCode != 200) {
      throw Exception("Failed to update $pathUrl: ${res.body}");
    }
    return res;
  }
}
