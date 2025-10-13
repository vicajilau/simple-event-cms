import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:github/github.dart' hide Organization;
import 'package:http/http.dart' as http;
import 'package:sec/core/config/config_loader.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';

abstract class CommonsServices {
  Future<List<dynamic>> loadData(String path);
  Future<http.Response> updateData<T extends GitHubModel>(
    List<T> dataOriginal,
    T data,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> removeData<T extends GitHubModel>(
    List<T> dataOriginal,
    T dataToRemove,
    String pathUrl,
    String commitMessage,
  );
}

class CommonsServicesImp extends CommonsServices {
  GithubData? githubService;
  Organization organization = getIt<Organization>();

  /// Generic method to load data from a specified path
  /// Automatically determines whether to load from local assets or remote URL
  /// based on the configuration's base URL
  @override
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
      try {
        res = await github.repositories.getContents(
          repositorySlug,
          url,
          ref: "feature/refactor_agenda_form",
        );
      } catch (e, st) {
        if (e is GitHubError && e.message == "Not Found") {
          return [].toList();
        } else {
          // Handle other potential network or API errors during fetch.
          throw NetworkException(
            "Error fetching data from GitHub: $e",
            cause: e,
            stackTrace: st,
            url: url,
          );
        }
      }
      if (res.file == null || res.file!.content == null) {
        throw NetworkException("El contenido de la respuesta es null");
      }
      final file = utf8.decode(
        base64.decode(
          res.file!.content!.replaceAll("\n", "").replaceAll("\\n", ""),
        ),
      );
      content = file;
    } else if (ConfigLoader.appEnv == 'dev') {
      final localPath = 'events/${organization.year}/$path';
      content = await rootBundle.loadString(localPath);
    }
    try {
      // Handle cases where content might be a list or a map containing a list
      final decodedContent = json.decode(content);
      if (decodedContent is List) {
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
      throw JsonDecodeException(
        "Decoded JSON for path $path is not a List as expected by loadData's return type, nor the handled eventPath map structure.",
      );
    } catch (e, st) {
      throw JsonDecodeException(
        "Error loading configuration from $path",
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Generic function to update or create data on GitHub.
  /// Returns an http.Response for consistency.
  @override
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
    String branch =
        githubService?.branch ?? 'main'; // Default to 'main' if not specified
    try {
      // 1. GET THE CURRENT FILE CONTENT TO OBTAIN ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: "feature/refactor_agenda_form",
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it with an empty list.
        final response = await github.repositories.createFile(
            repositorySlug,
            CreateFile(
              path: pathUrl,
              content: base64Content,
              message: 'feat: create file at $pathUrl',
              branch: branch,
            ));
        if (response.content != null) {
          return http.Response(
            response.content?.content.toString() ?? "",
            200,
          );
        }else{
          // Any other error while getting the file.
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
        // Return an empty list since the file was just created empty.

      } else {
        // Any other error while getting the file.
        throw GithubException(
          "Failed to get file contents from $pathUrl: $e",
          cause: e,
          stackTrace: st,
        );
      }
    }

    // 4. PREPARE THE REQUEST BODY FOR THE GITHUB API
    // The body requires the message, content, and the sha (for updates).
    final requestBody = <String, String>{
      'message': commitMessage,
      'content': base64Content,
      'branch': branch,
    };

    // Only add the 'sha' for updates, not for creation.
    requestBody['sha'] = currentSha;

    // 5. BUILD THE API URL AND MAKE THE PUT REQUEST MANUALLY
    // This gives you back the raw http.Response you want.

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
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }

    return response;
  }

  /// Generic function to remove data from GitHub
  @override
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
      throw GithubException("GitHub token is not available.");
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
        ref: "feature/refactor_agenda_form",
      );
      currentSha = contents.file?.sha;
      if (currentSha == null) throw Exception("File exists but SHA is null.");
    } on NotFound catch (e, st) {
      // If the file doesn't exist, we can't remove anything from it.
      throw GithubException(
        "Cannot remove item because file does not exist at $pathUrl.",
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw GithubException(
        "Failed to get file for removal: $e",
        cause: e,
        stackTrace: st,
      );
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

    String branch =
        githubService?.branch ?? 'main'; // Default to 'main' if not specified
    // 4. PREPARE REQUEST BODY
    final requestBody = {
      'message': commitMessage,
      'content': base64Content,
      'sha': currentSha, // SHA is required for updates
      'branch': branch,
    };
    RepositorySlug repositorySlug = RepositorySlug(
      organization.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? organization.projectName,
    );
    // 5. BUILD URL AND MAKE PUT REQUEST

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
      throw NetworkException(
        "Failed to save updated data after removal at $pathUrl: ${response.body}",
      );
    }
    return response;
  }
}
