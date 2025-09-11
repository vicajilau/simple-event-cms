import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_models/event_collection_view_model.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';

/// Main home screen widget that displays the event information and navigation
/// Features a bottom navigation bar with tabs for Agenda, Speakers, and Sponsors
/// Now uses dependency injection for better testability and architecture
class EventCollectionScreen extends StatefulWidget {
  final int crossAxisCount;

  const EventCollectionScreen({super.key, this.crossAxisCount = 4});

  @override
  State<EventCollectionScreen> createState() => _EventCollectionScreenState();
}

/// State class for HomeScreen that manages navigation between tabs
class _EventCollectionScreenState extends State<EventCollectionScreen> {
  int _titleTapCount = 0;
  EventCollectionViewModel? _viewmodel;
  Organization? _organization;
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
      final useCase = getIt<EventUseCase>();
      final organization = getIt<Organization>();

      final viewmodel = EventCollectionViewModelImp(useCase: useCase);
      await viewmodel.setup();

      setState(() {
        _viewmodel = viewmodel;
        _organization = organization;
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
    _viewmodel?.dispose();
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

    if (_viewmodel == null || _organization == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Configuración no disponible')),
      );
    }

    final currentLocale = Localizations.localeOf(context);

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
          child: Text(_organization!.organizationName),
        ),
        actions: <Widget>[
          EventFilterButton(
            selectedFilter: _viewmodel!.currentFilter,
            onFilterChanged: (EventFilter filter) {
              _viewmodel!.onEventFilterChanged(filter);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _viewmodel!.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<Event>>(
            valueListenable: _viewmodel!.eventsToShow,
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
                      _viewmodel!.deleteEvent(item);
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
                        context.go(
                          '/event/${item.uid}',
                          extra: {
                            'locale': currentLocale,
                            'agendaDays': item.agenda?.days ?? [],
                            'speakers': item.speakers ?? [],
                            'sponsors': item.sponsors ?? [],
                          },
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
                                    await Navigator.push<Event>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrganizationFormScreen(
                                              siteConfig: item,
                                            ),
                                      ),
                                    );
                                if (eventEdited != null) {
                                  _viewmodel!.editEvent(eventEdited);
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
          final Event? newConfig = await Navigator.push<Event>(
            context,
            MaterialPageRoute(
              builder: (context) => const OrganizationFormScreen(),
            ),
          );
          if (newConfig != null) {
            _viewmodel!.addEvent(newConfig);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
