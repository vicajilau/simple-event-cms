import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:github/github.dart' hide Organization;
import 'package:http/http.dart' as http;
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/config_dependency_helper.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/github/github_model.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';

abstract class CommonsServices {
  Future<Map<String, dynamic>> loadData(String path);
  Future<http.Response> updateData<T extends GitHubModel>(
    List<T> dataOriginal,
    T data,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> updateAllData(
    GithubJsonModel data,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> updateDataList<T extends GitHubModel>(
    List<T> dataList,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> removeData<T extends GitHubModel>(
    List<T> dataOriginal,
    T dataToRemove,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> removeDataList<T extends GitHubModel>(
    List<T> dataOriginal,
    List<T> dataToRemove,
    String pathUrl,
    String commitMessage,
  );
  Future<http.Response> updateSingleData<T extends GitHubModel>(
    T data,
    String pathUrl,
    String commitMessage,
  );
}

class CommonsServicesImp extends CommonsServices {
  late GithubData githubService;
  Config get config => getIt<Config>();

  /// Generic method to load data from a specified path
  /// Automatically determines whether to load from local assets or remote URL
  /// based on the configuration's base URL
  @override
  Future<Map<String, dynamic>> loadData(String path) async {
    String content = "";
    final url = 'events/$path';

    final githubService = await SecureInfo.getGithubKey();
    final github = GitHub(
      auth: githubService.token == null
          ? Authentication.anonymous()
          : Authentication.withToken(githubService.token),
    );
    final repositorySlug = RepositorySlug(
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );

    late final RepositoryContents res; // <- late

    try {
      res = await github.repositories.getContents(
        repositorySlug,
        url,
        ref: config.branch,
      );
    } catch (e, st) {
      if (e is GitHubError) {
        if (e.message == "Not Found") {
          return <String, dynamic>{};
        }
        if (e is RateLimitHit) {
          throw NetworkException(
            "GitHub API rate limit exceeded. Please try again later.",
            cause: e,
            stackTrace: st,
            url: url,
          );
        }
        if (e is InvalidJSON) {
          throw NetworkException(
            "Invalid JSON received from GitHub.",
            cause: e,
            stackTrace: st,
            url: url,
          );
        }
        throw NetworkException(
          "An unknown GitHub error occurred, please retry later",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }

      if (e is RepositoryNotFound) {
        throw NetworkException(
          "Repository not found.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }
      if (e is UserNotFound) {
        throw NetworkException(
          "User not found.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }
      if (e is OrganizationNotFound) {
        throw NetworkException(
          "Organization not found.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }
      if (e is TeamNotFound) {
        throw NetworkException(
          "Team not found.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }
      if (e is AccessForbidden) {
        throw NetworkException(
          "Access forbidden. Check your token and permissions.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }
      if (e is NotReady) {
        throw NetworkException(
          "The requested resource is not ready. Please try again later.",
          cause: e,
          stackTrace: st,
          url: url,
        );
      }

      throw NetworkException(
        "Error fetching data, Please retry later",
        cause: e,
        stackTrace: st,
        url: url,
      );
    }

    if (res.file == null || res.file!.content == null) {
      throw NetworkException("Error fetching data, Please retry later");
    }

    final file = utf8.decode(
      base64.decode(
        res.file!.content!.replaceAll("\n", "").replaceAll("\\n", ""),
      ),
    );
    content = file;

    try {
      final decodedContent = json.decode(content);
      return decodedContent;
    } catch (e, st) {
      if (e.toString().contains("No element")) {
        return <String, dynamic>{};
      }
      throw JsonDecodeException(
        "Error fetching data, Please retry later",
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
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );
    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    String? currentSha;

    // 2. MODIFY THE DATA LIST
    int indexElementFounded = dataOriginal.indexWhere(
      (item) => item.uid == data.uid,
    );

    if (indexElementFounded != -1) {
      dataOriginal[indexElementFounded] = data;
    } else {
      dataOriginal.add(data);
    }
    final dataInJsonString = json.encode(
      dataOriginal.map((item) => item.toJson()).toList(),
    );
    var base64Content = "";
    base64Content = base64.encode(utf8.encode(dataInJsonString));
    String branch = config.branch; // Default to 'main' if not specified
    try {
      // 1. GET THE CURRENT FILE CONTENT TO GET ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: config.branch,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it.
        final response = await github.repositories.createFile(
          repositorySlug,
          CreateFile(
            path: pathUrl,
            content: base64Content,
            message: 'feat: create file at $pathUrl',
            branch: branch,
          ),
        );
        if (response.content != null) {
          return http.Response(response.content?.content.toString() ?? "", 200);
        } else {
          // Any other error while getting the file.
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
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

    // 5. BUILD THE API URL AND MAKE THE PUT REQUEST

    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    // Check the response status and throw an exception on failure.
    if (response.statusCode != 200 && response.statusCode != 201) {
      // 200 for update, 201 for create
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );

    return response;
  }

  /// Generic function to update or create data on GitHub.
  /// Returns an http.Response for consistency.
  @override
  Future<http.Response> updateSingleData<T extends GitHubModel>(
    T data,
    String pathUrl,
    String commitMessage,
  ) async {
    final Config orgToUse = (data is Config) ? data as Config : config;
    RepositorySlug repositorySlug = RepositorySlug(
      orgToUse.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? orgToUse.projectName,
    );
    setOrganization(orgToUse);
    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    String? currentSha;

    final dataInJsonString = json.encode(data);
    var base64Content = "";
    base64Content = base64.encode(utf8.encode(dataInJsonString));
    String branch = orgToUse.branch; // Default to 'main' if not specified
    try {
      // 1. GET THE CURRENT FILE CONTENT TO GET ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: orgToUse.branch,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it.
        final response = await github.repositories.createFile(
          repositorySlug,
          CreateFile(
            path: pathUrl,
            content: base64Content,
            message: 'feat: create file at $pathUrl',
            branch: branch,
          ),
        );
        if (response.content != null) {
          return http.Response(response.content?.content.toString() ?? "", 200);
        } else {
          // Any other error while getting the file.
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
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

    // 5. BUILD THE API URL AND MAKE THE PUT REQUEST

    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    // Check the response status and throw an exception on failure.
    if (response.statusCode != 200 && response.statusCode != 201) {
      // 200 for update, 201 for create
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );

    return response;
  }

  /// Polls GitHub to verify that the file content has been updated.
  /// Retries a few times with a delay if the content is not immediately updated.
  Future<void> _waitForContentUpdate(
    GitHub github,
    RepositorySlug repositorySlug,
    String pathUrl,
    String branch,
    String expectedBase64Content,
  ) async {
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 4);

    for (int i = 0; i < maxRetries; i++) {
      try {
        // Fetch the latest content of the file from GitHub.
        final contents = await github.repositories.getContents(
          repositorySlug,
          pathUrl,
          ref: branch,
        );

        // The content from GitHub API has newlines, remove them for a reliable comparison.
        final currentContent = contents.file?.content?.replaceAll('\n', '');

        if (currentContent == expectedBase64Content) {
          // The content is updated, we can return successfully.
          return;
        }
      } catch (e) {
        debugPrint("fail to update: $pathUrl");
      }

      // Wait before the next retry.
      await Future.delayed(retryDelay);
    }
  }

  /// Generic function to remove data from GitHub
  @override
  Future<http.Response> removeData<T extends GitHubModel>(
    List<T> dataOriginal,
    T dataToRemove,
    String pathUrl,
    String commitMessage, {
    int retries = 0,
  }) async {
    // This function needs the same logic as updateData: get SHA, then update.
    // GitHub API doesn't have a "remove item from JSON" endpoint.
    // You must read the file, remove the item locally, and write the entire file back.

    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw GithubException("GitHub token is not available.");
    }

    var github = GitHub(auth: Authentication.withToken(githubService.token));

    // 1. GET SHA - This is mandatory for updates.
    String? currentSha;
    try {
      RepositorySlug repositorySlug = RepositorySlug(
        config.githubUser,
        (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
      );
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: config.branch,
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
        "Failed to get file for removal from $pathUrl: $e",
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

    String branch = config.branch; // Default to 'main' if not specified
    // 4. PREPARE THE REQUEST BODY
    final requestBody = {
      'message': commitMessage,
      'content': base64Content,
      'sha': currentSha, // SHA is required for updates
      'branch': branch,
    };
    RepositorySlug repositorySlug = RepositorySlug(
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );
    // 5. BUILD THE API URL AND MAKE THE PUT REQUEST

    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 409) {
      if (retries < 5) {
        // The content on the server is out of date. Fetch the latest version, apply the change, and try again.
        return updateDataList(
          dataOriginal,
          pathUrl,
          commitMessage,
          retries: retries + 1,
        );
      }
      throw NetworkException(
        "Failed to update data at $pathUrl after multiple retries due to conflicts: ${response.body}",
      );
    } else if (response.statusCode != 200) {
      throw NetworkException(
        "Failed to save updated data after removal at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );
    return response;
  }

  /// Generic function to update a whole list of data on GitHub.
  /// Replaces the entire file content with the provided list.
  /// Returns an http.Response for consistency.
  @override
  Future<http.Response> updateDataList<T extends GitHubModel>(
    List<T> dataList,
    String pathUrl,
    String commitMessage, {
    int retries = 0,
  }) async {
    RepositorySlug repositorySlug = RepositorySlug(
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );
    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    String? currentSha;
    String branch = config.branch;

    // 1. CONVERT THE FINAL CONTENT TO JSON AND THEN TO BASE64
    final dataInJsonString = json.encode(
      dataList.map((item) => item.toJson()).toList(),
    );
    var base64Content = base64.encode(utf8.encode(dataInJsonString));

    try {
      // 2. GET THE CURRENT FILE CONTENT TO OBTAIN ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: config.branch,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it with the provided list.
        final response = await github.repositories.createFile(
          repositorySlug,
          CreateFile(
            path: pathUrl,
            content: base64Content,
            message: 'feat: create file at $pathUrl',
            branch: branch,
          ),
        );
        if (response.content != null) {
          return http.Response(
            response.content?.content.toString() ?? "",
            201, // 201 for created
          );
        } else {
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
      } else {
        // Any other error while getting the file.
        throw GithubException(
          "Failed to get file contents from $pathUrl: $e",
          cause: e,
          stackTrace: st,
        );
      }
    }

    // 3. PREPARE THE REQUEST BODY FOR THE GITHUB API
    // The body requires the message, content, and the sha for updates.
    final requestBody = <String, String>{
      'message': commitMessage,
      'content': base64Content,
      'branch': branch,
      'sha': currentSha,
    };

    // 4. BUILD THE API URL AND MAKE THE PUT REQUEST
    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 409) {
      if (retries < 5) {
        // Retry logic for conflicts, up to 5 times.
        return updateDataList(
          dataList,
          pathUrl,
          commitMessage,
          retries: retries + 1,
        );
      }
      throw NetworkException(
        "Failed to update data at $pathUrl after multiple retries due to conflicts: ${response.body}",
      );
    } else if (response.statusCode != 200) {
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );
    return response;
  }

  /// Generic function to remove a list of data from a file on GitHub.
  /// Returns an http.Response for consistency.
  @override
  Future<http.Response> removeDataList<T extends GitHubModel>(
    List<T> dataOriginal,
    List<T> dataToRemove,
    String pathUrl,
    String commitMessage, {
    int retries = 0,
  }) async {
    RepositorySlug repositorySlug = RepositorySlug(
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );
    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    String? currentSha;
    String branch = config.branch;

    var dataToMerge = dataOriginal.toList();
    dataToMerge.removeWhere((item) => dataToRemove.contains(item));

    // 1. CONVERT THE FINAL CONTENT TO JSON AND THEN TO BASE64
    final dataInJsonString = json.encode(
      dataToMerge.map((item) => item.toJson()).toList(),
    );
    var base64Content = base64.encode(utf8.encode(dataInJsonString));

    try {
      // 2. GET THE CURRENT FILE CONTENT TO OBTAIN ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: config.branch,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it with the provided list.
        final response = await github.repositories.createFile(
          repositorySlug,
          CreateFile(
            path: pathUrl,
            content: base64Content,
            message: 'feat: create file at $pathUrl',
            branch: branch,
          ),
        );
        if (response.content != null) {
          return http.Response(
            response.content?.content.toString() ?? "",
            201, // 201 for created
          );
        } else {
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
      } else {
        // Any other error while getting the file.
        throw GithubException(
          "Failed to get file contents from $pathUrl: $e",
          cause: e,
          stackTrace: st,
        );
      }
    }

    // 3. PREPARE THE REQUEST BODY FOR THE GITHUB API
    // The body requires the message, content, and the sha for updates.
    final requestBody = <String, String>{
      'message': commitMessage,
      'content': base64Content,
      'branch': branch,
      'sha': currentSha,
    };

    // 4. BUILD THE API URL AND MAKE THE PUT REQUEST
    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 409) {
      if (retries < 5) {
        // Retry logic for conflicts, up to 5 times.
        return removeDataList(
          dataOriginal,
          dataToRemove,
          pathUrl,
          commitMessage,
          retries: retries + 1,
        );
      }
      throw NetworkException(
        "Failed to update data at $pathUrl after multiple retries due to conflicts: ${response.body}",
      );
    } else if (response.statusCode != 200) {
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );
    return response;
  }

  @override
  Future<http.Response> updateAllData(
    GithubJsonModel data,
    String pathUrl,
    String commitMessage, {
    int retries = 0,
  }) async {
    RepositorySlug repositorySlug = RepositorySlug(
      config.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? config.projectName,
    );
    githubService = await SecureInfo.getGithubKey();
    if (githubService.token == null) {
      throw Exception("GitHub token is not available.");
    }

    // Initialize GitHub client
    var github = GitHub(auth: Authentication.withToken(githubService.token));

    String? currentSha;
    String branch = config.branch;

    // 1. CONVERT THE FINAL CONTENT TO JSON AND THEN TO BASE64
    final dataInJsonString = json.encode(data.toJson());
    var base64Content = base64.encode(utf8.encode(dataInJsonString));

    try {
      // 2. GET THE CURRENT FILE CONTENT TO OBTAIN ITS SHA
      // This is mandatory for updates.
      final contents = await github.repositories.getContents(
        repositorySlug,
        pathUrl,
        ref: config.branch,
      );
      currentSha = contents.file?.sha;

      if (currentSha == null) {
        // This case is unlikely if the file exists but helps prevent errors.
        throw GithubException("Could not get the SHA of the existing file.");
      }
    } catch (e, st) {
      if (e is GitHubError && e.message == "Not Found") {
        // If the file is not found, create it with the provided list.
        final response = await github.repositories.createFile(
          repositorySlug,
          CreateFile(
            path: pathUrl,
            content: base64Content,
            message: 'feat: create file at $pathUrl',
            branch: branch,
          ),
        );
        if (response.content != null) {
          return http.Response(
            response.content?.content.toString() ?? "",
            201, // 201 for created
          );
        } else {
          throw GithubException(
            "Failed to create file contents from $pathUrl: $e",
            cause: e,
            stackTrace: st,
          );
        }
      } else {
        // Any other error while getting the file.
        throw GithubException(
          "Failed to get file contents from $pathUrl: $e",
          cause: e,
          stackTrace: st,
        );
      }
    }

    // 3. PREPARE THE REQUEST BODY FOR THE GITHUB API
    // The body requires the message, content, and the sha for updates.
    final requestBody = <String, String>{
      'message': commitMessage,
      'content': base64Content,
      'branch': branch,
      'sha': currentSha,
    };

    // 4. BUILD THE API URL AND MAKE THE PUT REQUEST
    final apiUrl =
        'https://api.github.com/repos/${repositorySlug.owner}/${repositorySlug.name}/contents/$pathUrl?ref=$branch';

    final response = await github.client.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": 'Bearer ${githubService.token}',
        "Accept": "application/vnd.github.v3+json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 409) {
      if (retries < 5) {
        // Retry logic for conflicts, up to 5 times.
        return updateAllData(
          data,
          pathUrl,
          commitMessage,
          retries: retries + 1,
        );
      }
      throw NetworkException(
        "Failed to update data at $pathUrl after multiple retries due to conflicts: ${response.body}",
      );
    } else if (response.statusCode != 200) {
      throw NetworkException(
        "Failed to update data at $pathUrl: ${response.body}",
      );
    }
    // After a successful write operation to GitHub, there can be a small delay
    // before the change is propagated and visible via the API for subsequent reads.
    // This function polls the file content until it matches the content we just wrote.
    await _waitForContentUpdate(
      github,
      repositorySlug,
      pathUrl,
      branch,
      base64Content,
    );
    return response;
  }
}
