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
  Future<http.Response> updateData<T>(
    List<T> data,
    String pathUrl,
    String commitMessage,
  ) async {
    // Convert data to JSON and then to base64
    final dataInfo = base64Encode(
      utf8.encode(
        json.encode(
          data.map((item) {
            if (item is GitHubModel) return item.toJson();
            throw Exception("Unsupported type: ${T.runtimeType}");
          }).toList(),
        ),
      ),
    );

    // Prepare the request body
    final body = json.encode({
      "message": commitMessage,
      "content": dataInfo,
      "sha": this.githubService.sha,
    });

    // Construct the file URL
    final fileUrl =
        "${this.githubService.repo}/$pathUrl?ref=${this.githubService.branch}";

    // Initialize GitHub client
    var github = GitHub(
      auth: Authentication.withToken(this.githubService.token),
    );

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
