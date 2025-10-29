import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sec/core/models/github/github_data.dart';

/// Defines a class named `SecureInfo` to interact with `FlutterSecureStorage`.
///
/// This class provides methods to securely save and retrieve keys.
abstract class SecureInfo {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Constructor that initializes an instance of `FlutterSecureStorage`.
  // SecureInfo() : _storage = const FlutterSecureStorage();

  /// Saves a value associated with a key in secure storage.
  ///
  /// [githubService]: The GithubService object to save.
  ///
  /// Throws an exception if an error occurs during writing.
  static Future<void> saveGithubKey(GithubData githubService) async {
    try {
      var githubDataSaving = await getGithubKey();
      var githubDataUpdated = GithubData(
        token: githubService.token ?? githubDataSaving.token,
        projectName: githubService.projectName ?? githubDataSaving.projectName,
      );
      // Convert the GithubService object to a JSON string
      String githubServiceJson = jsonEncode(githubDataUpdated.toJson());
      // Save the JSON string in secure storage
      await _storage.write(key: 'github_service', value: githubServiceJson);
    } catch (e) {
      // Consider handling the error more specifically or logging it.
      debugPrint('Error saving GithubService: $e');
      rethrow; // Rethrow the exception so the caller can handle it.
    }
  }

  /// Removes the GitHub token from secure storage.
  ///
  /// This is achieved by retrieving the current data, setting the token to null,
  /// and then saving the updated data back to secure storage.
  /// Throws an exception if an error occurs during the process.
  static Future<void> removeGithubKey() async {
    try {
      var githubDataSaving = await getGithubKey();
      var githubDataUpdated = GithubData(
        token: null,
        projectName: githubDataSaving.projectName,
      );
      // Convert the GithubService object to a JSON string
      String githubServiceJson = jsonEncode(githubDataUpdated.toJson());
      // Save the JSON string in secure storage
      await _storage.write(key: 'github_service', value: githubServiceJson);
    } catch (e) {
      // Consider handling the error more specifically or logging it.
      debugPrint('Error saving GithubService: $e');
      rethrow; // Rethrow the exception so the caller can handle it.
    }
  }

  /// Retrieves the value associated with a key from secure storage.
  ///
  /// Returns the value as a `String?` (can be null if the key does not exist).
  /// Throws an exception if an error occurs during reading.
  static Future<GithubData> getGithubKey() async {
    String? githubServiceJson = await _storage.read(key: 'github_service');
    if (githubServiceJson != null) {
      // Convert the JSON string back to a GithubService object
      return GithubData.fromJson(jsonDecode(githubServiceJson));
    }
    return GithubData();
  }
}
