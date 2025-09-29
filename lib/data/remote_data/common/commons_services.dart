import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:github/github.dart' hide Organization;
import 'package:http/http.dart' as http;
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/models.dart';

class CommonsServices {
  GithubData? githubService;
  Organization organization = getIt<Organization>();

  /// Generic function to update or create data on GitHub.
  /// Returns an http.Response for consistency.
  Future<http.Response> updateData<T extends GitHubModel>(
    List<T> dataOriginal,
    T data,
    String pathUrl,
    String commitMessage,
  ) async {
    RepositorySlug repositorySlug = RepositorySlug(
      organization.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? organization.projectName,
    );
    githubService = await SecureInfo.getGithubKey();
    if (githubService?.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService!.token));

    String? currentSha;
    try {
      // 1. GET THE CURRENT FILE CONTENT TO OBTAIN ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw Exception("Could not get the SHA of the existing file.");
      }
    } on NotFound {
      // If the file is not found (NotFound), the SHA remains null.
      // The logic below will create the file instead of updating it.
      currentSha = null;
      debugPrint("File not found at $pathUrl. A new file will be created.");
    } catch (e) {
      // Any other error while getting the file.
      throw Exception("Failed to get file contents from $pathUrl: $e");
    }

    // 2. MODIFY THE DATA LIST (Your current logic)
    int indexElementFounded = dataOriginal.indexWhere(
      (item) => item.uid == data.uid,
    );

    if (indexElementFounded != -1) {
      dataOriginal[indexElementFounded] = data;
    } else {
      dataOriginal.add(data);
    }

    // 3. CONVERT THE FINAL CONTENT TO JSON AND THEN TO BASE64
    final dataInJsonString = json.encode(
      dataOriginal.map((item) => item.toJson()).toList(),
    );
    var base64Content = "";
      base64Content = base64.encode(utf8.encode(dataInJsonString));

    // 4. PREPARE THE REQUEST BODY FOR THE GITHUB API
    // The body requires the message, content, and the sha (for updates).
    final requestBody = <String, String>{
      'message': commitMessage,
      'content': base64Content,
    };

    // Only add the 'sha' for updates, not for creation.
    if (currentSha != null) {
      requestBody['sha'] = currentSha;
    }

    // 5. BUILD THE API URL AND MAKE THE PUT REQUEST MANUALLY
    // This gives you back the raw http.Response you want.
    String branch =
        githubService?.branch ?? 'main'; // Default to 'main' if not specified
    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService?.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(
        requestBody,
      ), // Encode the final body map to a JSON string
    );

    // Check the response status and throw an exception on failure.
    if (response.statusCode != 200 && response.statusCode != 201) {
      // 200 for update, 201 for create
      throw Exception("Failed to update data at $pathUrl: ${response.body}");
    }

    return response;
  }

  /// Generic function to remove data from GitHub
  Future<http.Response> removeData<T extends GitHubModel>(
    List<T> dataOriginal,
    T dataToRemove,
    String pathUrl,
    String commitMessage,
  ) async {
    // This function needs the same logic as updateData: get SHA, then update.
    // GitHub API doesn't have a "remove item from JSON" endpoint.
    // You must read the file, remove the item locally, and write the entire file back.

    githubService = await SecureInfo.getGithubKey();
    if (githubService?.token == null) {
      throw Exception("GitHub token is not available.");
    }

    var github = GitHub(auth: Authentication.withToken(githubService!.token));

    // 1. GET SHA - This is mandatory
    String? currentSha;
    try {
      RepositorySlug repositorySlug = RepositorySlug(
        organization.githubUser,
        (await SecureInfo.getGithubKey()).projectName ??
            organization.projectName,
      );
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
      );
      currentSha = contents.file?.sha;
      if (currentSha == null) throw Exception("File exists but SHA is null.");
    } on NotFound {
      // If the file doesn't exist, we can't remove anything from it.
      throw Exception(
        "Cannot remove item because file does not exist at $pathUrl.",
      );
    } catch (e) {
      throw Exception("Failed to get file for removal: $e");
    }

    // 2. REMOVE THE ITEM FROM THE LIST
    // Ensure you are removing based on a unique identifier.
    dataOriginal.removeWhere((item) => item.uid == dataToRemove.uid);

    // 3. CONVERT UPDATED LIST TO BASE64
    final dataInJsonString = json.encode(
      dataOriginal.map((item) => item.toJson()).toList(),
    );
    var base64Content = "";
    base64Content = base64.encode(utf8.encode(dataInJsonString));


    // 4. PREPARE REQUEST BODY
    final requestBody = {
      'message': commitMessage,
      'content': base64Content,
      'sha': currentSha, // SHA is required for updates
    };
    RepositorySlug repositorySlug = RepositorySlug(
      organization.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? organization.projectName,
    );
    // 5. BUILD URL AND MAKE PUT REQUEST
    String branch =
        githubService?.branch ?? 'main'; // Default to 'main' if not specified
    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService?.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to save updated data after removal at $pathUrl: ${response.body}",
      );
    }
    return response;
  }
}
