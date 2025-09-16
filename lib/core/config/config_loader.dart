import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:github/github.dart' hide Organization, Event;
import 'package:sec/core/di/dependency_injection.dart';

import '../models/models.dart';

class ConfigLoader {
  // Lee las variables de entorno. Si no se definen, usa valores por defecto.
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
    var github = GitHub();
    final res = await github.repositories.getContents(
      RepositorySlug(
        localOrganization.github_user,
        localOrganization.project_name,
      ),
      configUrl,
      ref: "feature/refactor_code",
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
      organization.github_user,
      organization.project_name,
    );

    final configUrl = 'events/${organization.year}/config/site.json';
    var github = GitHub();
    final res = await github.repositories.getContents(
      repositorySlug,
      configUrl,
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
      final List<dynamic> eventDataList = fileJsonData["events"];

      return eventDataList
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    }
  }
}
