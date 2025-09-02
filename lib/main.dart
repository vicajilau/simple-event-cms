import 'dart:io';

import 'package:flutter/material.dart';

import 'core/core.dart';
import 'event_app.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Entry point of the Flutter application for tech events
/// Initializes configuration and data loader before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final config = await ConfigLoader.loadConfig();
  final organization = await ConfigLoader.loadOrganization();
  final dataLoader = DataLoader(config, organization);

  runApp(
    EventApp(
      config: config,
      dataLoader: dataLoader,
      organization: organization,
    ),
  );
}
