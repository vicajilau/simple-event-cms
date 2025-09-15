import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:github/github.dart' hide Organization, Event;
import 'package:sec/core/config/secure_info.dart';

import '../models/models.dart';

class ConfigLoader {
  static var year = '2025';

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
    final baseUrl = await loadBaseUrl();

    final configUrl = '$baseUrl/events/$year/config/organization.json';
    var accessToken = (await SecureInfo.getGithubKey())?.token;
    var github = GitHub(auth: Authentication.withToken(accessToken));
    final res = await github.getJSON(configUrl,
      headers: {
        "Authorization": "$accessToken",
        "Accept": "application/vnd.github.v3+json",
        "Access-Control-Allow-Origin": "*"
      },);
    if (res == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    }
    return Organization.fromJson(res);
  }

  static Future<List<Event>> loadConfig() async {
    final baseUrl = await loadBaseUrl();

    final configUrl = '$baseUrl/events/$year/config/site.json';
    var accessToken = (await SecureInfo.getGithubKey())?.token;
    var github = GitHub(auth: Authentication.withToken(accessToken));
    final res = await github.getJSON(configUrl,
      headers: {
        "Authorization": "$accessToken",
        "Accept": "application/vnd.github.v3+json",
        "Access-Control-Allow-Origin": "*"
      },);

    if (res == null) {
      throw Exception(
        "Error cargando configuración de producción desde $configUrl",
      );
    }

    final List<dynamic> eventDataList = res["events"];

    return eventDataList
        .map((eventData) => Event.fromJson(eventData))
        .toList();
  }
}
