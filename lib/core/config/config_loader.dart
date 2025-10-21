import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:github/github.dart' hide Organization, Event;
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../models/models.dart';

class ConfigLoader {
  // Read environment variables. If not defined, use default values.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static Future<Organization> loadOrganization() async {
    final localConfigPath = 'events/organization/organization.json';
    final String response = await rootBundle.loadString(localConfigPath);
    final data = await json.decode(response);
    var localOrganization = Organization.fromJson(data);
    final configUrl = 'events/organization/organization.json';
    var githubService = await SecureInfo.getGithubKey();
    var github = GitHub(auth: githubService.token == null ? Authentication.anonymous() : Authentication.withToken(githubService.token));
    final res = await github.repositories.getContents(
      RepositorySlug(
        localOrganization.githubUser,
        (await SecureInfo.getGithubKey()).projectName ??
            localOrganization.projectName,
      ),
      configUrl,
      ref: githubService.branch,
    );
    if (res.file == null || res.file!.content == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    } else {
      final file = utf8.decode(
        base64.decode(res.file!.content!.replaceAll("\n", "")),
      );
      final fileJsonData = json.decode(file);
      return Organization.fromJson(fileJsonData);
    }
  }

  static Future<List<Event>> loadConfig() async {
    Organization organization = getIt<Organization>();
    RepositorySlug repositorySlug = RepositorySlug(
      organization.githubUser,
      (await SecureInfo.getGithubKey()).projectName ?? organization.projectName,
    );

    final configUrl = 'events/${organization.year}/config/events.json';
    var githubService = await SecureInfo.getGithubKey();
    var github = GitHub(auth: githubService.token == null ? Authentication.anonymous() : Authentication.withToken(githubService.token));
    final res = await github.repositories.getContents(
      repositorySlug,
      configUrl,
      ref: githubService.branch,
    );

    if (res.file == null || res.file!.content == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    } else {
      final file = utf8.decode(
        base64.decode(res.file!.content!.replaceAll("\n", "")),
      );
      final fileJsonData = json.decode(file);
      final List<dynamic> eventDataList = fileJsonData;

      return eventDataList
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    }
  }
}
