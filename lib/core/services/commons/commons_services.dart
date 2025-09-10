import 'dart:convert';

import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/github/github_services.dart';

class CommonsServices {
  final GithubService githubService;

  CommonsServices({required this.githubService});

  Future<http.Response> getSha(GithubService githubService) async {
    final fileUri = Uri.parse(
      "${githubService.repo}?ref=${githubService.branch}",
    );

    final res = await http.get(
      fileUri,
      headers: {
        "Authorization": "${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
        "Access-Control-Allow-Origin": "*"
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
  Future<http.Response> updateData<T>(
    List<GitHubModel> dataOriginal,
    GitHubModel data,
    String pathUrl,
    String commitMessage,
  ) async {
    // Find the index of the data to update, if it exists
    int indexElementFounded = dataOriginal.indexWhere((item) => item.uid == data.uid);

    // If data exists, replace it; otherwise, add it
    if (dataOriginal.indexWhere((item) => item.uid == data.uid) != -1) {
      dataOriginal[indexElementFounded] = data;
    } else {
      dataOriginal.add(data);
    }

    // Convert data to JSON and then to base64
    final dataInfo = base64Encode(
      utf8.encode(
        json.encode(dataOriginal.map((item) => item.toJson()).toList()),
      ),
    );

    // Prepare the request body
    final body = json.encode({
      "message": commitMessage,
      "content": dataInfo,
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
        "Authorization": "${githubService.token}",
        "Accept": "application/vnd.github.v3+json",
        "Access-Control-Allow-Origin": "*"
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
