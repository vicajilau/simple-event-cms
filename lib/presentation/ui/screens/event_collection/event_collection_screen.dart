import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/no_events/no_events_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/secure_info.dart';
import '../../../view_model_common.dart';
import '../login/admin_login_screen.dart';
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
      // Use dependency injection instead of creating instances manually

      await widget.viewmodel.setup();

      if (mounted) {
        setState(() {
          organizationName = organization.organizationName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final location = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = '${location.errorLoadingConfig}$e';
          _isLoading = false;
        });
      }
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
      return Scaffold(body: Center(child: Text(location.configNotAvailable)));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
        centerTitle: false,
        title: GestureDetector(
          onTap: () async {
            _titleTapCount++;

            if (_titleTapCount >= 5) {
              _titleTapCount = 0;
              var githubService = await SecureInfo.getGithubKey();
              if (githubService.token == null) {
                if (context.mounted) {
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      child: AdminLoginScreen(() {
                        setState(() {
                          _loadConfiguration();
                        });
                      }),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(location.confirmLogout),
                        content: Text(location.confirmLogoutMessage),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(location.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(location.logout),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    setState(() async {
                      await SecureInfo.removeGithubKey();
                    });
                  }
                }
              }
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
          child: Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                ), // Your desired icon
                const SizedBox(width: 8), // Spacing between icon and title
                Text(
                  organizationName.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: null,
              hint: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Event', // This is now the default text
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.arrow_drop_down, color: Colors.blue),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final filter = EventFilter.values
                      .where((e) => e.label == newValue)
                      .firstOrNull;
                  if (filter == null) {
                    widget.viewmodel.onEventFilterChanged(EventFilter.all);
                  } else {
                    widget.viewmodel.onEventFilterChanged(filter);
                  }
                }
              },
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: EventFilter.all.label,
                  child: Text(EventFilter.all.label),
                ),
                DropdownMenuItem(
                  value: EventFilter.current.label,
                  child: Text(EventFilter.current.label),
                ),
                DropdownMenuItem(
                  value: EventFilter.past.label,
                  child: Text(EventFilter.past.label),
                ),
              ], // No items in the dropdown
            ),
          ),
          const SizedBox(width: 8),
          FutureBuilder(
            future: SecureInfo.getGithubKey(),
            builder: (context, snapshot) {
              if (snapshot.data?.token != null) {
                return IconButton(
                  onPressed: () => {
                    setState(() async {
                      widget.viewmodel.viewState.value = ViewState.isLoading;
                      await SecureInfo.removeGithubKey();
                      await _loadConfiguration();
                      widget.viewmodel.viewState.value = ViewState.loadFinished;
                    }),
                  },
                  icon: Icon(Icons.logout),
                  color: Colors.blue,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ViewState>(
        valueListenable: widget.viewmodel.viewState,
        builder: (context, viewState, child) {
          if (viewState == ViewState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewState == ViewState.error) {
            // Using WidgetsBinding.instance.addPostFrameCallback to show a dialog
            // after the build phase is complete, preventing build-time state changes.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => CustomErrorDialog(
                    errorMessage: widget.viewmodel.errorMessage,
                    onCancel: () => {
                      widget.viewmodel.setErrorKey(null),
                      widget.viewmodel.viewState.value = ViewState.loadFinished,
                      Navigator.of(context).pop(),
                    },
                    buttonText: location.closeButton,
                  ),
                );
              }
            });
          }

          return ValueListenableBuilder<List<Event>>(
            valueListenable: _viewmodel.eventsToShow,
            builder: (context, eventsToShow, child) {
              if (eventsToShow.isEmpty) {
                return Column(
                  // Use Column to layout the button and the screen vertically.
                  children: [
                    _buildAddEventButton(),
                    Expanded(
                      // Use Expanded to make MaintenanceScreen fill the remaining space.
                      child: MaintenanceScreen(),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAddEventButton(),
                    GridView.builder(
                      shrinkWrap: true, // Important for nesting in a Column
                      physics:
                          const NeverScrollableScrollPhysics(), // Important to avoid nested scrolling conflicts
                      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                      itemCount: eventsToShow.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                400.0, // Adjust this value as needed
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio:
                                3 /
                                2, // Adjust aspect ratio for better appearance
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        final item = eventsToShow[index];
                        return FutureBuilder<bool>(
                          future: widget.viewmodel.checkToken(),
                          builder: (context, snapshot) {
                            final bool canDismiss = snapshot.data ?? false;
                            return _buildEventCard(context, item, canDismiss);
                          },
                        );
                      },
                    ),
                  ],
                ),
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
                    Organization? organizationUpdated =
                        await AppRouter.router.push(
                              AppRouter.organizationFormPath,
                            )
                            as Organization?;

                    if (organizationUpdated != null) {
                      getIt.resetLazySingleton<Organization>(
                        instance: organizationUpdated,
                      );
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAddEventButton() {
    var location = AppLocalizations.of(context)!;
    return FutureBuilder<bool>(
      future: widget.viewmodel.checkToken(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: const Color(0xFFe5f5f9),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                location.availablesEventsTitle,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                location.availablesEventsText,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final Event? newEvent = await AppRouter.router.push(
                            AppRouter.eventFormPath,
                          );
                          if (newEvent != null) {
                            setState(() {
                              _viewmodel.eventsToShow.value.removeWhere(
                                (event) => event.uid == newEvent.uid,
                              );
                              _viewmodel.eventsToShow.value.add(newEvent);
                              _viewmodel.addEvent(newEvent);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Text('Add Event'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Event item, bool isAdmin) {
    return GestureDetector(
      onTap: () {
        AppRouter.router.pushNamed(
          AppRouter.eventDetailName,
          pathParameters: {'eventId': item.uid},
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isAdmin)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final Event? eventEdited = await AppRouter.router.push(
                      AppRouter.eventFormPath,
                      extra: item.uid,
                    );
                    if (eventEdited != null) {
                      await widget.viewmodel.editEvent(eventEdited);
                    }
                  },
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: isAdmin ? 0.0 : 20.0,
                      bottom: 8.0,
                    ),
                    child: Center(
                      child: Text(
                        organizationName.toString(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.eventName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "${item.eventDates.startDate.toString()}/${item.eventDates.endDate}",
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.location != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: InkWell(
                                  onTap: () async {
                                    final location = item.location.toString();
                                    final uri = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.blue,
                                        size: 36,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () async {
                    await widget.viewmodel.deleteEvent(item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
