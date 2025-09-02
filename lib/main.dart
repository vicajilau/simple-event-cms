import 'package:flutter/material.dart';

import 'core/core.dart';
import 'event_app.dart';

/// Entry point of the Flutter application for tech events
/// Initializes configuration and data loader before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
