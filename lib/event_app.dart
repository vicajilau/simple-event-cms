import 'package:flutter/material.dart';
import 'package:sec/ui/screens/event/event_collection/event_collection_screen.dart';
import 'core/models/organization.dart';
import 'core/services/load/data_loader.dart';
import 'l10n/app_localizations.dart';

/// Main application widget that sets up the Material Design theme and localization
/// Supports multiple languages and environments (dev, pre, pro)
class EventApp extends StatefulWidget {
  /// Site configuration containing event details and styling
  final dynamic config;

  /// Data loader for fetching speakers, agenda, and sponsors
  final DataLoader dataLoader;

  final Organization organization;

  const EventApp({
    super.key,
    required this.config,
    required this.dataLoader,
    required this.organization,
  });

  @override
  State<EventApp> createState() => _EventAppState();
}

class _EventAppState extends State<EventApp> {
  /// Currently selected locale for the application
  Locale? _locale;

  /// Changes the application locale
  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final dataLoader = widget.dataLoader;
    final organization = widget.organization;
    final primaryColor = Color(
      int.parse(
        organization.primaryColorOrganization.replaceFirst('#', '0xff'),
      ),
    );
    final secondaryColor = Color(
      int.parse(
        organization.secondaryColorOrganization.replaceFirst('#', '0xff'),
      ),
    );

    return MaterialApp(
      title: organization.organizationName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          secondary: secondaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: EventCollectionScreen(
        config: config,
        dataLoader: dataLoader,
        locale: _locale ?? AppLocalizations.supportedLocales.first,
        localeChanged: _changeLocale,
        organization: widget.organization,
      ),
    );
  }
}
