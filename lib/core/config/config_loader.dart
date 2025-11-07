import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:github/github.dart' hide Organization, Event;
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/di/organization_dependency_helper.dart';
import 'package:sec/core/routing/check_org.dart';

import '../models/models.dart';

class ConfigLoader {
  // Read environment variables. If not defined, use default values.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static Future<Organization> getLocalOrganization() async {
    final localConfigPath = 'events/organization/config.json';
    final String response = await rootBundle.loadString(localConfigPath);
    final data = await json.decode(response);
    return Organization.fromJson(data);
  }

  static Future<Organization> loadOrganization() async {
    final health = getIt<CheckOrg>();
    try {
      var localOrganization = await getLocalOrganization();

      final hasLocalFieldErrors =
          (localOrganization.githubUser.isEmpty ||
          localOrganization.branch.isEmpty);

      if (hasLocalFieldErrors) {
        health.setError(true);
        _updateOrgSingletonIfNeeded(localOrganization);
        return localOrganization;
      }

      //  try GitHub
      const configUrl = 'events/organization/config.json';
      final githubService = await SecureInfo.getGithubKey();
      final github = GitHub(
        auth: githubService.token == null
            ? Authentication.anonymous()
            : Authentication.withToken(githubService.token),
      );

      final res = await github.repositories.getContents(
        RepositorySlug(
          localOrganization.githubUser,
          (await SecureInfo.getGithubKey()).projectName ??
              localOrganization.projectName,
        ),
        configUrl,
        ref: localOrganization.branch,
      );

      if (res.file == null || res.file!.content == null) {
        // Error
        health.setError(true);
        _updateOrgSingletonIfNeeded(localOrganization);
        return localOrganization;
      }

      final file = utf8.decode(
        base64.decode(res.file!.content!.replaceAll("\n", "")),
      );
      final fileJsonData = json.decode(file);
      final orgFromRemote = Organization.fromJson(fileJsonData);

      // its ok
      health.setError(false);
      _updateOrgSingletonIfNeeded(orgFromRemote);
      return orgFromRemote;
    } catch (_) {
      // error
      final localFallback = await getLocalOrganization();
      getIt<CheckOrg>().setError(true);
      _updateOrgSingletonIfNeeded(localFallback);
      return localFallback;
    }
    
  }

  // update getIt<Organization> if registered
  static void _updateOrgSingletonIfNeeded(Organization orgToUse) {
    setOrganization(orgToUse);
  }
}
