import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:github/github.dart' hide Organization, Event;

import '../models/models.dart';

class ConfigLoader {
  static var year = '2025';
  static var user = 'vicajilau';
  static var project = 'simple-event-cms';

  // Lee las variables de entorno. Si no se definen, usa valores por defecto.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static Future<String> loadBaseUrl() async {
    final organizationConfigPath = 'events/$year/config/organization.json';
    final organizationConfigContent = await rootBundle.loadString(
      organizationConfigPath,
    );
    final organizationJsonData = json.decode(organizationConfigContent);
    return Organization.fromJson(organizationJsonData).baseUrl;
  }

  static Future<Organization> loadOrganization() async {
    final configUrl = 'events/$year/config/organization.json';
    var github = GitHub();
    var repositorySlug = RepositorySlug(user, project);
    final res = await github.repositories.getContents(
        repositorySlug, configUrl);
    if (res.file == null || res.file!.content == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    } else {
      final file = utf8.decode(
          base64.decode(res.file!.content!.replaceAll("\n", "")));
      final fileJsonData = json.decode(file);
      return Organization.fromJson(fileJsonData);
    }
  }

  static Future<List<Event>> loadConfig() async {

    final configUrl = 'events/$year/config/site.json';
    var github = GitHub();
    var repositorySlug = RepositorySlug(user, project);
    final res = await github.repositories.getContents(repositorySlug, configUrl);

    if (res.file == null || res.file!.content == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    }else{
      final file = utf8.decode(base64.decode(res.file!.content!.replaceAll("\n", "")));
      final fileJsonData = json.decode(file);
      final List<dynamic> eventDataList = fileJsonData["events"];

      return eventDataList
          .map((eventData) => Event.fromJson(eventData))
          .toList();
    }


  }
}
