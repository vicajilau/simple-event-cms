import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/ui/widgets/organization_form_screen.dart';

import '../../core/core.dart';
import '../../core/models/organization.dart';
import 'screens.dart';

/// Main home screen widget that displays the event information and navigation
/// Features a bottom navigation bar with tabs for Agenda, Speakers, and Sponsors
class EventCollectionScreen extends StatefulWidget {
  /// Site configuration containing event details
  final List<SiteConfig> config;

  /// Data loader for fetching content from various sources
  final DataLoader dataLoader;

  /// Currently selected locale for the application
  final Locale locale;

  /// Callback function to be called when the locale changes
  final ValueChanged<Locale> localeChanged;

  final int crossAxisCount;

  final Organization organization;

  const EventCollectionScreen({
    super.key,
    required this.config,
    required this.dataLoader,
    required this.locale,
    required this.localeChanged,
    this.crossAxisCount = 4,
    required this.organization,
  });

  @override
  State<EventCollectionScreen> createState() => _EventCollectionScreenState();
}

/// State class for HomeScreen that manages navigation between tabs
class _EventCollectionScreenState extends State<EventCollectionScreen> {
  List<SiteConfig> events = [];

  /// Initializes the screens list with data loader
  @override
  void initState() {
    super.initState();

    loadEventsData();
  }

  Future<void> loadEventsData() async {
    events = widget.dataLoader.config;
    var agenda = await widget.dataLoader.loadAgenda();
    var speakers = await widget.dataLoader.loadSpeakers();
    var sponsors = await widget.dataLoader.loadSponsors();

    for (var event in events) {
      event.agenda = agenda.firstWhere(
        (element) => element.uid == event.agendaUID,
      );

      event.speakers = event.speakersUID
          .map((uid) => speakers.firstWhere((s) => s.uid == uid))
          .whereType<Speaker>()
          .toList();

      event.sponsors = event.sponsorsUID
          .map((uid) => sponsors.firstWhere((s) => s.uid == uid))
          .whereType<Sponsor>()
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text("No hay organizaciones para mostrar."));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.organizationName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            onPressed: () {
              // Acción para el filtro
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          var item = events[index];
          return Dismissible(
            key: Key(item.eventName),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              setState(() {
                events.removeAt(index);
                widget.dataLoader.config.remove(item);
              });
              await _saveConfigToJson(widget.dataLoader.config);
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text("${item.eventName} eliminado")),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventContainerScreen(
                      config: widget.config,
                      dataLoader: widget.dataLoader,
                      locale: widget.locale,
                      localeChanged: widget.localeChanged,
                      agendaDays: item.agenda?.days ?? [],
                      speakers: item.speakers ?? [],
                      sponsors: item.sponsors ?? [],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.event,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    title: Text(
                      item.eventName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "${item.eventDates?.startDate.toString()}/${item.eventDates?.endDate}",
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // code to edit the event
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final SiteConfig? newConfig = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrganizationFormScreen(),
            ),
          );

          if (newConfig != null) {
            setState(() {
              events.add(newConfig);
            });
            await _saveConfigToJson(widget.dataLoader.config);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _saveConfigToJson(List<SiteConfig> config) async {
    try {
      final directory = Directory.current.path;
      final file = File('$directory/events/2025/config/site.json');
      final jsonString = jsonEncode(
        config.map((siteConfig) => siteConfig.toJson(siteConfig)).toList(),
      );
      await file.writeAsString(jsonString);
      if (kDebugMode) {
        print('Configuración guardada en ${file.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al guardar la configuración: $e');
      }
    }
  }

  /*void _addDay() {}

  /// Shows a dialog with event information including dates, venue, and description
  void _showEventInfo(BuildContext context,SiteConfig siteConfig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(siteConfig.eventName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (siteConfig.eventDates != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${siteConfig.eventDates!.startDate} - ${siteConfig.eventDates!.endDate}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (siteConfig.venue != null) ...[
              GestureDetector(
                onTap: () => _openGoogleMaps(siteConfig.venue!),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siteConfig.venue!.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                          ),
                          Text(
                            siteConfig.venue!.address,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.openUrl,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (siteConfig.description != null &&
                siteConfig.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                siteConfig.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.description),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }*/

  /// Opens Google Maps with the venue location
  /*Future<void> _openGoogleMaps(Venue venue) async {
    final query = Uri.encodeComponent('${venue.name}, ${venue.address}');
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';

    // Use the extension to open URL from context
    await context.openUrl(googleMapsUrl);
  }*/
}

class AgendaCard extends StatelessWidget {
  /// Site configuration containing event details
  final List<SiteConfig> config;

  /// Data loader for fetching content from various sources
  final DataLoader dataLoader;

  /// Currently selected locale for the application
  final Locale locale;

  /// Callback function to be called when the locale changes
  final ValueChanged<Locale> localeChanged;

  const AgendaCard({
    super.key,
    required this.config,
    required this.dataLoader,
    required this.locale,
    required this.localeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // ....
            },
          ),
          title: Text('DevFest Spain 2025'),
          subtitle: Text('12/10/25 - 15/10/25'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // ....
            },
          ),
          onTap: () async {
            /* final agendaDays = await _getAgendaDays();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventContainerScreen(
                  config: config,
                  dataLoader: dataLoader,
                  locale: locale,
                  localeChanged: localeChanged,
                  agendaDays: agendaDays,
                ),
              ),
            );*/
          },
        ),
      ),
    );
  }

  /*Future<List<AgendaDay>> _getAgendaDays() async {
    return await dataLoader.loadAgenda();
  }*/
}
