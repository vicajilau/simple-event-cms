import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
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
  final EventCollectionViewModel _viewmodel = getIt<EventCollectionViewModel>();
  String? organizationName;
  bool _isLoading = true;
  String? _errorMessage;
  final organization = getIt<Organization>();

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      // Usar inyección de dependencias en lugar de crear instancias manualmente


      widget.viewmodel.setup();

      setState(() {
        organizationName = organization.organizationName;
        _isLoading = false;
      });
    } catch (e) {
      final location = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = '${location.errorLoadingConfig}$e';
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
    final location = AppLocalizations.of(context)!;
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
                child: Text(location.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (organizationName == null) {
      return Scaffold(
        body: Center(child: Text(location.configNotAvailable)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            _titleTapCount++;
            if (_titleTapCount >= 5) {
              _titleTapCount = 0;
              context.push(AppRouter.adminPath);
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
                  ErrorView(errorMessage: widget.viewmodel.errorMessage),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return ValueListenableBuilder<List<Event>>(
            valueListenable: _viewmodel.eventsToShow,
            builder: (context, eventsToShow, child) {
              if (eventsToShow.isEmpty) {
                return Center(
                  child: Text(location.noEventsToShow),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                itemCount: eventsToShow.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = eventsToShow[index];
                  return FutureBuilder<bool>(
                    future: widget.viewmodel.checkToken(),
                    builder: (context, snapshot) {
                      final bool canDismiss = snapshot.data ?? false;
                      return Dismissible(
                        key: Key(item.eventName),
                        direction: canDismiss
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        onDismissed: (direction) async {
                          if (canDismiss) {
                            widget.viewmodel.deleteEvent(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.eventName}${location.eventDeleted}'),
                              ),
                            );
                          }
                        },
                        confirmDismiss: (direction) async {
                          return canDismiss;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _buildEventCard(context, item, canDismiss),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FutureBuilder<bool>(
            future: widget.viewmodel.checkToken(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return FloatingActionButton(
                  heroTag: 'editOrganizationBtn', // Unique heroTag
                  onPressed: () async {
                    Organization? organizationUpdated = await context.push(AppRouter.organizationFormPath) as Organization?;

                    if(organizationUpdated != null){
                      getIt.resetLazySingleton<Organization>(instance: organizationUpdated);
                      setState(() {
                        organizationName = organizationUpdated.organizationName;
                      });
                    }
                  },
                  child: const Icon(Icons.business),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16), // Spacing between buttons
          FutureBuilder<bool>(
            future: widget.viewmodel.checkToken(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return AddFloatingActionButton(
                  onPressed: () async {
                    final Event? newConfig = await context.push(AppRouter.eventFormPath);
                    if (newConfig != null) {
                      setState(() {
                        _viewmodel.eventsToShow.value.removeWhere((event) => event.uid == newConfig.uid);
                        _viewmodel.eventsToShow.value.add(newConfig);
                      });
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEventCard(BuildContext context, Event item, bool isAdmin) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRouter.eventDetailName,
          pathParameters: {'eventId': item.uid},
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
            trailing: isAdmin
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final Event? eventEdited = await context.push(
                        AppRouter.eventFormPath,
                        extra: item.uid,
                      );
                      if (eventEdited != null) {
                        await widget.viewmodel.editEvent(eventEdited);
                      }
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
