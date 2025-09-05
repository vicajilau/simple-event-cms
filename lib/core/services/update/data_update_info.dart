import 'dart:convert';

import 'package:sec/core/core.dart';
import 'package:http/http.dart' as http;

import '../github_services/GithubService.dart';


class DataUpdateInfo {
  /// Site configuration containing base URL and other settings
  final DataLoader dataLoader;

  // Variable de tipo GithubService para interactuar con la API de GitHub
  final GithubService githubService;

  DataUpdateInfo(this.dataLoader)
      : githubService = GithubService(owner: '', repo: '', token: '', branch: '');

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeakers(List<Speaker> speakers, String filePath) async {
    //List<dynamic> jsonList = await dataLoader.loadData('speakers/speakers.json');
    final fileUri = Uri.parse("${githubService.repo}/$filePath");
    final speakerInfo = base64Encode(utf8.encode(json.encode(speakers.map((speaker) => speaker.toJson()))));
    final body = json.encode({
      "message": "Update speakers from JSON",
      "content": speakerInfo,
      "sha": ""
    });
    final res = await http.put(fileUri, headers: {
      "Authorization": "Bearer ${githubService.token}",
      "Accept": "application/vnd.github.v3+json"
    }, body: body);

    if(res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(List<Agenda> agenda, String filePath) async {
    //List<dynamic> jsonList = await dataLoader.loadData('agenda/agenda.json');
    final fileUri = Uri.parse("${githubService.repo}/$filePath");
    final agendaInfo = base64Encode(utf8.encode(json.encode(agenda.map((agenda) => agenda.toJson()))));
    final body = json.encode({
      "message": "Update agendas from JSON",
      "content": agendaInfo,
      "sha": ""
    });
    final res = await http.put(fileUri, headers: {
      "Authorization": "Bearer ${githubService.token}",
      "Accept": "application/vnd.github.v3+json"
    }, body: body);

    if(res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(List<Sponsor> sponsors, String filePath) async {
    //List<dynamic> jsonList = await dataLoader.loadData('agenda/agenda.json');
    final fileUri = Uri.parse("${githubService.repo}/$filePath");
    final sponsorInfo = base64Encode(utf8.encode(json.encode(sponsors.map((sponsor) => sponsor.toJson()))));
    final body = json.encode({
      "message": "Update agendas from JSON",
      "content": sponsorInfo,
      "sha": ""
    });
    final res = await http.put(fileUri, headers: {
      "Authorization": "Bearer ${githubService.token}",
      "Accept": "application/vnd.github.v3+json"
    }, body: body);

    if(res.statusCode != 200) {
      throw Exception("Failed to update speakers");
    }
    return res;
  }
}
