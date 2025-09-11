import 'package:flutter/material.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/event_container/event_container_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import 'event_collection_view_model.dart';

/// Main home screen widget that displays the event_collection information and navigation
/// Features a bottom navigation bar with tabs for Agenda, Speakers, and Sponsors
class EventCollectionScreen extends StatefulWidget {
  final EventCollectionViewModel viewmodel;

  /// Currently selected locale for the application
  final Locale locale;

  /// Callback function to be called when the locale changes
  final ValueChanged<Locale> localeChanged;

  final int crossAxisCount;

  final Organization organization;

  const EventCollectionScreen({
    super.key,
    required this.locale,
    required this.localeChanged,
    this.crossAxisCount = 4,
    required this.organization,
    required this.viewmodel,
  });

  @override
  State<EventCollectionScreen> createState() => _EventCollectionScreenState();
}

/// State class for HomeScreen that manages navigation between tabs
class _EventCollectionScreenState extends State<EventCollectionScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup();
  }

  @override
  void dispose() {
    widget.viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.organizationName),
        actions: <Widget>[
          EventFilterButton(
            selectedFilter: widget.viewmodel.currentFilter,
            onFilterChanged: (EventFilter filter) {
              widget.viewmodel.onEventFilterChanged(filter);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.viewmodel.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<Event>>(
            valueListenable: widget.viewmodel.eventsToShow,
            builder: (context, events, child) {
              if (events.isEmpty) {
                return const Center(
                  child: Text("No hay eventos para mostrar."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                itemCount: events.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = events[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      widget.viewmodel.deleteEvent(item);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
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
                              locale: widget.locale,
                              localeChanged: widget.localeChanged,
                              viewModel: EventContainerViewModelImp(
                                event: item,
                              ),
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
                                final Event? eventEdited =
                                    await _navigateToForm(item);
                                if (eventEdited != null) {
                                  widget.viewmodel.editEvent(eventEdited);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () async {
          final Event? newConfig = await _navigateToForm();
          if (newConfig != null) {
            widget.viewmodel.addEvent(newConfig);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<Event?> _navigateToForm([Event? siteConfig]) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizationFormScreen(siteConfig: siteConfig),
      ),
    );
  }
}
