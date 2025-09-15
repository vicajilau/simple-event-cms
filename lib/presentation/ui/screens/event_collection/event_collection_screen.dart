import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../view_model_common.dart';
import 'event_collection_view_model.dart';

/// Main home screen widget that displays the event_collection information and navigation
/// Features a bottom navigation bar with tabs for Agenda, Speakers, and Sponsors
/// Now uses dependency injection for better testability and architecture
class EventCollectionScreen extends StatefulWidget {
  final EventCollectionViewModel viewmodel = getIt<EventCollectionViewModel>();
  final int crossAxisCount;

  EventCollectionScreen({super.key, this.crossAxisCount = 4});

  @override
  State<EventCollectionScreen> createState() => _EventCollectionScreenState();
}

/// State class for HomeScreen that manages navigation between tabs
class _EventCollectionScreenState extends State<EventCollectionScreen> {
  int _titleTapCount = 0;
  EventCollectionViewModel _viewmodel = getIt<EventCollectionViewModel>();
  String? organizationName;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      // Usar inyección de dependencias en lugar de crear instancias manualmente
      final organization = getIt<Organization>();

      widget.viewmodel.setup();

      setState(() {
        organizationName = organization.organizationName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando configuración: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    widget.viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadConfiguration();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (organizationName == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Configuración no disponible')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _titleTapCount++;
            if (_titleTapCount >= 5) {
              _titleTapCount = 0;
              context.go('/admin');
            }
            // Reset counter after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _titleTapCount = 0;
                });
              }
            });
          },
          child: Text(organizationName.toString()),
        ),
        actions: <Widget>[
          EventFilterButton(
            selectedFilter: widget.viewmodel.currentFilter,
            onFilterChanged: (EventFilter filter) {
              widget.viewmodel.onEventFilterChanged(filter);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ViewState>(
        valueListenable: widget.viewmodel.viewState,
        builder: (context, viewState, child) {
          if (viewState == ViewState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewState == ViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.viewmodel.errorMessage),
                  const SizedBox(height: 16),
                  /*ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadConfiguration();
                    },
                    child: const Text('Reintentar'),
                  ),*/
                ],
              ),
            );
          }

          return ValueListenableBuilder<List<Event>>(
            valueListenable: _viewmodel.eventsToShow,
            builder: (context, eventsToShow, child) {
              if (eventsToShow.isEmpty) {
                return const Center(
                  child: Text("No hay eventos para mostrar."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                itemCount: eventsToShow.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = eventsToShow[index];
                  return Dismissible(
                    key: Key(item.eventName),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      widget.viewmodel.deleteEvent(item);
                      ScaffoldMessenger.of(context).showSnackBar(
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
                        context.go('/event/${item.uid}');
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
                                "${item.eventDates.startDate.toString()}/${item.eventDates.endDate}",
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final Event? eventEdited =
                                    await Navigator.push<Event>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EventFormScreen(eventId: item.uid),
                                      ),
                                    );
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
          final Event? newConfig = await AppRouter.router.push(AppRouter.adminCreateEventPath);
          if (newConfig != null) {
            widget.viewmodel.addEvent(newConfig);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
