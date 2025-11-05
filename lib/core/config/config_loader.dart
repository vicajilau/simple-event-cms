import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  static Future<Organization> getLocalOrganization() async {
    final localConfigPath = 'events/organization/organization.json';
    final String response = await rootBundle.loadString(localConfigPath);
    final data = await json.decode(response);
    return Organization.fromJson(data);
  }
  static Future<Organization> loadOrganization() async {
    try{
    var localOrganization = await getLocalOrganization();
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
      ref: localOrganization.branch,
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

      final directory = await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/events/organization/organization.json');
      await localFile.create(recursive: true);
      await localFile.writeAsString(json.encode(fileJsonData));

      var orgToUse = Organization.fromJson(fileJsonData);
      if(getIt.isRegistered<Organization>()){
        getIt.resetLazySingleton<Organization>(instance: orgToUse);
      }
      return orgToUse;
    }
    } catch (e) {
      // Return local organization if there is an error
      return await getLocalOrganization();
    }
  }
}
