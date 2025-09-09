import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/ui/widgets/organization_form_screen.dart';

import '../../core/core.dart';
import '../../core/models/organization.dart';
import '../widgets/widgets.dart';
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
  List<SiteConfig> events = [], eventsToShow = [];
  bool showEndedEvents = false, showNextsEvents = true;

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
    sortEvents();
    applyFilters();
  }

  void applyFilters() {
    final now = DateTime.now();
    List<SiteConfig> eventsFiltered = [...events];
    if (showEndedEvents && showNextsEvents) {
    } else if (showEndedEvents) {
      eventsFiltered = events.where((event) {
        final startDate = DateTime.parse(event.eventDates!.startDate);
        return startDate.isBefore(now);
      }).toList();
    } else if (showNextsEvents) {
      eventsFiltered = events.where((event) {
        final startDate = DateTime.parse(event.eventDates!.startDate);
        return startDate.isAfter(now);
      }).toList();
    }
    setState(() {
      eventsToShow = [...eventsFiltered];
    });
  }

  void sortEvents() {
    events.sort((a, b) {
      final aDate = DateTime.parse(a.eventDates!.startDate);
      final bDate = DateTime.parse(b.eventDates!.startDate);
      return aDate.compareTo(bDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.organizationName),
        actions: <Widget>[
          FilterCheckbox(
            label: "Eventos pasados",
            isChecked: showEndedEvents,
            onChanged: (value) {
              showEndedEvents = value;
              applyFilters();
            },
          ),
          FilterCheckbox(
            label: "Eventos actuales",
            isChecked: showNextsEvents,
            onChanged: (value) {
              showNextsEvents = value;
              applyFilters();
            },
          ),
        ],
      ),
      body: eventsToShow.isEmpty
          ? Center(child: Text("No hay organizaciones para mostrar."))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
              itemCount: eventsToShow.length,
              itemBuilder: (BuildContext context, int index) {
                var item = eventsToShow[index];
                return Dismissible(
                  key: Key(item.eventName),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final indexToRemove = events.indexWhere(
                      (element) => element.uid == item.uid,
                    );
                    events.removeAt(indexToRemove);
                    setState(() {
                      eventsToShow = [...events];
                    });
                    widget.dataLoader.config.remove(item);

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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                            onPressed: () async {
                              final SiteConfig? newConfig =
                                  await _navigateToForm(item);

                              if (newConfig != null) {
                                int index = events.indexWhere(
                                  (element) => element.uid == newConfig.uid,
                                );
                                if (index != -1) {
                                  events[index] = newConfig;
                                  setState(() {
                                    eventsToShow = [...events];
                                  });
                                }
                                await _saveConfigToJson(events);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () async {
          final SiteConfig? newConfig = await _navigateToForm();

          if (newConfig != null) {
            events.add(newConfig);
            setState(() {
              eventsToShow = [...events];
            });
            await _saveConfigToJson(events);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<SiteConfig?> _navigateToForm([SiteConfig? siteConfig]) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizationFormScreen(siteConfig: siteConfig),
      ),
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

  /// Opens Google Maps with the venue location
  /*Future<void> _openGoogleMaps(Venue venue) async {
    final query = Uri.encodeComponent('${venue.name}, ${venue.address}');
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';

    // Use the extension to open URL from context
    await context.openUrl(googleMapsUrl);
  }*/
}
