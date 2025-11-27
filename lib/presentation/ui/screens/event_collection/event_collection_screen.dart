import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sec/core/di/config_dependency_helper.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/no_events/no_events_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../../core/config/secure_info.dart';
import '../../../view_model_common.dart';
import '../login/admin_login_screen.dart';
import '../on_live/on_live_screen.dart';
import 'event_collection_view_model.dart';

/// Main home screen widget that displays the event_collection information and navigation
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
  final EventCollectionViewModel viewmodel = getIt<EventCollectionViewModel>();
  String? configName;
  bool _isLoading = true;
  String? _errorMessage;
  final health = getIt<CheckOrg>();

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      await viewmodel.setup();
      if (mounted) {
        final org = getIt<Config>();
        final health = getIt<CheckOrg>();
        setState(() {
          configName = health.hasError ? '' : org.configName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final location = AppLocalizations.of(context)!;
        debugPrint('${location.errorLoadingConfig}$e');
        setState(() {
          _errorMessage = location.errorLoadingConfig;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    final bool hasOrgError =
        getIt<CheckOrg>().hasError ||
        (configName == null || configName!.isEmpty);

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

              final location = AppLocalizations.of(context)!;
              final bool hasOrgError =
                  getIt<CheckOrg>().hasError ||
                  (configName == null || configName!.isEmpty);

              if (hasOrgError) {
                // in case of error, always go through AdminLoginScreen
                if (context.mounted) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Dialog(
                      child: AdminLoginScreen(() async {
                        // will run only if login is successful
                        if (context.mounted) {
                          await AppRouter.router.push(
                            AppRouter.configFormPath,
                            extra: {'forceFix': true},
                          );

                          // after
                          getIt<CheckOrg>().setError(false);

                          await viewmodel.setup();
                          await _loadConfiguration();

                          // will do setup again to refresh configName
                          await viewmodel.setup();
                          await _loadConfiguration(); // esto leerá getIt<Organization>() fresco
                        }
                      }),
                    ),
                  );
                }
              } else {
                var githubService = await SecureInfo.getGithubKey();
                if (githubService.token == null) {
                  if (context.mounted) {
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => Dialog(
                        child: AdminLoginScreen(() async {
                          await _loadConfiguration();
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
                      (viewmodel as EventCollectionViewModelImp)
                              .lastEventsFetchTime =
                          null;
                      await SecureInfo.removeGithubKey();
                      await viewmodel.loadEvents();
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
            }
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
                Flexible(
                  child: Text(
                    hasOrgError ? '' : (configName ?? ''),
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
                    viewmodel.onEventFilterChanged(EventFilter.all);
                  } else {
                    viewmodel.onEventFilterChanged(filter);
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
                  onPressed: () async {
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
                      viewmodel.viewState.value = ViewState.isLoading;
                      await SecureInfo.removeGithubKey();
                      await _loadConfiguration();
                      viewmodel.viewState.value = ViewState.loadFinished;
                      if (mounted) setState(() {}); // si hace falta redibujar
                    }
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
        valueListenable: viewmodel.viewState,
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
                    errorMessage: viewmodel.errorMessage,
                    onCancel: () => {
                      viewmodel.setErrorKey(null),
                      viewmodel.viewState.value = ViewState.loadFinished,
                      Navigator.of(context).pop(),
                    },
                    buttonText: location.closeButton,
                  ),
                );
              }
            });
          }
          if (hasOrgError) {
            //we show only the message in the BODY,
            //but we keep the AppBar and the 5 taps to enter OrganizationScreen
            return Center(child: Text(location.configNotAvailable));
          }
          return ValueListenableBuilder<List<Event>>(
            valueListenable: viewmodel.eventsToShow,
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

              // Find the closest upcoming event
              Event? upcomingEvent;
              final now = DateTime.now();
              final futureEvents = eventsToShow
                  .where(
                    (e) => DateTime.parse(e.eventDates.startDate).isAfter(now),
                  )
                  .toList();
              if (futureEvents.isNotEmpty) {
                futureEvents.sort(
                  (a, b) =>
                      a.eventDates.startDate.compareTo(b.eventDates.startDate),
                );
                upcomingEvent = futureEvents.first;
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: _buildAddEventButtonRow(),
                    ),
                    GridView.builder(
                      shrinkWrap: true, // Important for nesting in a Column
                      physics:
                          const NeverScrollableScrollPhysics(), // Important to avoid nested scrolling conflicts
                      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                      itemCount: eventsToShow.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 460.0,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio:
                            (MediaQuery.of(context).size.width < 600)
                            ? (3 / 2.2)
                            : (3 / 2),
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final item = eventsToShow[index];
                        final bool isUpcoming = item.uid == upcomingEvent?.uid;
                        return FutureBuilder<bool>(
                          future: viewmodel.checkToken(),
                          // Optimization: consider moving this FutureBuilder outside the GridView if checkToken doesn't depend on the item
                          builder: (context, snapshot) {
                            final bool canDismiss = snapshot.data ?? false;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    isUpcoming ? location.nextEvent : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: _buildEventCard(
                                    context,
                                    item,
                                    canDismiss,
                                    isUpcoming,
                                  ),
                                ),
                              ],
                            );
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
            future: viewmodel.checkToken(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return FloatingActionButton(
                  heroTag: 'editOrganizationBtn', // Unique heroTag
                  onPressed: () async {
                    Config? configUpdated =
                        await AppRouter.router.push(AppRouter.configFormPath)
                            as Config?;

                    if (configUpdated != null) {
                      setOrganization(configUpdated);

                      setState(() {
                        configName = configUpdated.configName;
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
    // This view is for mobile screens
    return FutureBuilder<bool>(
      future: viewmodel.checkToken(),
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
                        onPressed: () => _onAddEventPressed(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Text(location.addEvent),
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

  Widget _buildAddEventButtonRow() {
    var location = AppLocalizations.of(context)!;
    return FutureBuilder<bool>(
      future: viewmodel.checkToken(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Container(
            color: const Color(0xFFe5f5f9),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.availablesEventsTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        location.availablesEventsText,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () => _onAddEventPressed(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(location.addEvent),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onAddEventPressed() async {
    final Event? newEvent = await AppRouter.router.push(
      AppRouter.eventFormPath,
    );
    if (newEvent != null) {
      setState(() {
        // This logic is to update an existing event if it was edited
        // or add a new one if it's completely new.
        final index = viewmodel.eventsToShow.value.indexWhere(
          (event) => event.uid == newEvent.uid,
        );
        if (index != -1) {
          // Replace existing event
          final updatedList = List<Event>.from(viewmodel.eventsToShow.value);
          updatedList[index] = newEvent;
          viewmodel.eventsToShow.value = updatedList;
        } else {
          // Add new event
          viewmodel.eventsToShow.value = [
            ...viewmodel.eventsToShow.value,
            newEvent,
          ];
        }
        // This should probably be handled inside the viewmodel
        viewmodel.addEvent(newEvent);
      });
    }
  }

  Widget _buildEventCard(
    BuildContext context,
    Event item,
    bool isAdmin,
    bool isUpcoming,
  ) {
    final cardContent = Card(
      shape: isUpcoming
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blueAccent, width: 2.5),
              borderRadius: BorderRadius.circular(
                12.0,
              ), // The default radius for Card is 12.0
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isAdmin)
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Show confirmation dialog
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            final location = AppLocalizations.of(context)!;
                            return AlertDialog(
                              title: Text(location.changeVisibilityTitle),
                              content: Text(
                                item.isVisible
                                    ? location.changeVisibilityToHidden
                                    : location.changeVisibilityToVisible,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(location.cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(location.changeVisibilityTitle),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await viewmodel.editEvent(
                            item..isVisible = !item.isVisible,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(
                          8.0,
                        ), // Add padding to increase tap area
                        child: Icon(
                          item.isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                          color: item.isVisible ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: isAdmin ? 0.0 : 20.0,
                        bottom: 8.0,
                      ),
                      child: Center(
                        child: Text(
                          configName.toString(),
                          style: Theme.of(context).textTheme.headlineSmall
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
                          ],
                        ),
                      ),
                    ),
                    if (item.youtubeUrl != null &&
                        item.youtubeUrl?.isNotEmpty == true)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              AppRouter.router.pushNamed(AppRouter.onLiveName,extra: OnLiveData(youtubeUrl: item.youtubeUrl.toString()));
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.squareYoutube,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text('Online Now'),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isAdmin)
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final Event? eventEdited = await AppRouter.router.push(
                          AppRouter.eventFormPath,
                          extra: item.uid,
                        );
                        if (eventEdited != null) {
                          await viewmodel.editEvent(eventEdited);
                        }
                      },
                    ),
                    if (isAdmin)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              final location = AppLocalizations.of(context)!;
                              return AlertDialog(
                                title: Text(location.deleteEventTitle),
                                content: Text(location.deleteEventMessage),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(location.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(location.deleteEventTitle),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            await viewmodel.deleteEvent(item);
                          }
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        AppRouter.router.pushNamed(
          AppRouter.eventDetailName,
          pathParameters: {
            'eventId': item.uid,
            'location': item.location ?? "",
            'onlyOneEvent': "false",
          },
        );
      },
      child: cardContent,
    );
  }
}
