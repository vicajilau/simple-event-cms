import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../models/organization.dart';

class ConfigLoader {
  // Lee las variables de entorno. Si no se definen, usa valores por defecto.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const String _githubUser = String.fromEnvironment(
    'GITHUB_USER',
    defaultValue: 'vicajilau',
  );
  static const String _githubRepo = String.fromEnvironment(
    'GITHUB_REPO',
    defaultValue: 'event_flutter_template',
  );
  static const String _githubBranch = String.fromEnvironment(
    'GITHUB_BRANCH',
    defaultValue: 'main',
  );

  static Future<Organization> loadOrganization() async {
    String configContent;
    String baseUrl;

    // Obtiene el año de la URL si está en web, si no, usa el año actual.
    // final queryYear = kIsWeb ? uri.queryParameters['year'] : null;
    // Para este ejemplo, usaremos el año 2025 fijo como en tu estructura.
    const year = '2025';

    switch (appEnv) {
      case 'pro':
      // Entorno de producción: Carga desde GitHub Pages.
        baseUrl = 'https://$_githubUser.github.io/$_githubRepo';
        final configUrl = '$baseUrl/events/$year/config/organization.json';
        final res = await http.get(Uri.parse(configUrl));
        if (res.statusCode != 200) {
          throw Exception(
            "Error cargando configuración de producción desde $configUrl",
          );
        }
        configContent = res.body;
        break;
      case 'pre':
      // Entorno de preproducción: Carga desde el raw de GitHub (rama específica).
        baseUrl =
        'https://raw.githubusercontent.com/$_githubUser/$_githubRepo/$_githubBranch';
        final configUrl = '$baseUrl/events/$year/config/organization.json';
        final res = await http.get(Uri.parse(configUrl));
        if (res.statusCode != 200) {
          throw Exception(
            "Error cargando configuración de pre-producción desde $configUrl",
          );
        }
        configContent = res.body;
        break;
      case 'dev':
      default:
      // Entorno de desarrollo: Carga desde los assets locales.
        final configPath = 'events/2025/config/organization.json';
        try {
          configContent = await rootBundle.loadString(configPath);
          // En dev, la baseUrl es la ruta base de los assets.
          baseUrl = 'events/2025';
        } catch (e) {
          throw Exception(
            "Error cargando config local: $configPath. Asegúrate de que esté en pubspec.yaml",
          );
        }
        break;
    }

    final jsonData = json.decode(configContent);

    return Organization.fromJson(jsonData);
  }

  static Future<List<SiteConfig>> loadConfig() async {
    String configContent;
    String baseUrl;

    // Obtiene el año de la URL si está en web, si no, usa el año actual.
    // final queryYear = kIsWeb ? uri.queryParameters['year'] : null;
    // Para este ejemplo, usaremos el año 2025 fijo como en tu estructura.
    const year = '2025';

    switch (appEnv) {
      case 'pro':
        // Entorno de producción: Carga desde GitHub Pages.
        baseUrl = 'https://$_githubUser.github.io/$_githubRepo';
        final configUrl = '$baseUrl/events/$year/config/site.json';
        final res = await http.get(Uri.parse(configUrl));
        if (res.statusCode != 200) {
          throw Exception(
            "Error cargando configuración de producción desde $configUrl",
          );
        }
        configContent = res.body;
        break;
      case 'pre':
        // Entorno de preproducción: Carga desde el raw de GitHub (rama específica).
        baseUrl =
            'https://raw.githubusercontent.com/$_githubUser/$_githubRepo/$_githubBranch';
        final configUrl = '$baseUrl/events/$year/config/site.json';
        final res = await http.get(Uri.parse(configUrl));
        if (res.statusCode != 200) {
          throw Exception(
            "Error cargando configuración de pre-producción desde $configUrl",
          );
        }
        configContent = res.body;
        break;
      case 'dev':
      default:
        // Entorno de desarrollo: Carga desde los assets locales.
        final configPath = 'events/2025/config/site.json';
        try {
          configContent = await rootBundle.loadString(configPath);
          // En dev, la baseUrl es la ruta base de los assets.
          baseUrl = 'events/2025';
        } catch (e) {
          throw Exception(
            "Error cargando config local: $configPath. Asegúrate de que esté en pubspec.yaml",
          );
        }
        break;
    }

    final jsonData = json.decode(configContent);
    List<SiteConfig> listEventsItems = [];
    var listEvents = jsonData['events'];
    listEvents.forEach((event) {
      listEventsItems.add(SiteConfig.fromJson(event, baseUrl: baseUrl, year: year));
    });

    // Pasamos la baseUrl construida para que el modelo la tenga.
    return listEventsItems;
  }
}
