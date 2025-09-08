import 'dart:convert';

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
    //List<dynamic> jsonList = await dataLoader.loadData('speakers/speakers.json');
    final fileUri = Uri.parse(
      "${githubService.repo}/${speakers[0].pathUrl}?ref=${githubService.branch}",
    );
    final speakerInfo = base64Encode(
      utf8.encode(json.encode(speakers.map((speaker) => speaker.toJson()))),
    );
    final body = json.encode({
      "message": "Update speakers from JSON",
      "content": speakerInfo,
      "sha": githubService.sha,
    });
    final res = await http.put(
      fileUri,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(List<Agenda> agenda) async {
    //List<dynamic> jsonList = await dataLoader.loadData('agenda/agenda.json');
    final fileUri = Uri.parse(
      "${githubService.repo}/${agenda[0].pathUrl}?ref=${githubService.branch}",
    );
    final agendaInfo = base64Encode(
      utf8.encode(json.encode(agenda.map((agenda) => agenda.toJson()))),
    );
    final body = json.encode({
      "message": "Update agendas from JSON",
      "content": agendaInfo,
      "sha": githubService.sha,
    });
    final res = await http.put(
      fileUri,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(List<Sponsor> sponsors) async {
    //List<dynamic> jsonList = await dataLoader.loadData('agenda/agenda.json');
    final fileUri = Uri.parse(
      "${githubService.repo}/${sponsors[0].pathUrl}?ref=${githubService.branch}",
    );
    final sponsorInfo = base64Encode(
      utf8.encode(json.encode(sponsors.map((sponsor) => sponsor.toJson()))),
    );
    final body = json.encode({
      "message": "Update agendas from JSON",
      "content": sponsorInfo,
      "sha": githubService.sha,
    });
    final res = await http.put(
      fileUri,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvents(List<Event> events) async {
    //List<dynamic> jsonList = await dataLoader.loadData('agenda/agenda.json');
    final fileUri = Uri.parse(
      "${githubService.repo}/${events[0].pathUrl}?ref=${githubService.branch}",
    );
    final sponsorInfo = base64Encode(
      utf8.encode(json.encode(events.map((event) => event.toJson()))),
    );
    final body = json.encode({
      "message": "Update agendas from JSON",
      "content": sponsorInfo,
      "sha": githubService.sha,
    });
    final res = await http.put(
      fileUri,
      headers: {
        "Authorization": "Bearer ${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  Future<http.Response> getSha(GithubService githubService) async {
    final fileUri = Uri.parse(
      "${githubService.repo}${githubService.repo}?ref=${githubService.branch}",
    );

    final res = await http.get(
      fileUri,
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
}
