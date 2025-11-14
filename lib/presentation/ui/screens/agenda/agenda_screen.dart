import 'package:flutter/material.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/core/utils/date_utils.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/dialogs/dialogs.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/screens/no_data/no_data_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:url_launcher/url_launcher.dart';

import 'agenda_view_model.dart';

class ExpansionTileState {
  final bool isExpanded;
  final int tabBarIndex;

  ExpansionTileState({required this.isExpanded, required this.tabBarIndex});
}

/// Screen that displays the event_collection agenda with sessions organized by days and tracks
/// Supports multiple days and tracks with color-coded sessions
class AgendaScreen extends StatefulWidget {
  final AgendaViewModel viewmodel = getIt<AgendaViewModel>();
  final String eventId;
  final TabController? tabController;
  final String? location;

  AgendaScreen({
    super.key,
    required this.eventId,
    required this.location,
    this.tabController,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with WidgetsBindingObserver {
  final Map<String, ExpansionTileState> _expansionTilesStates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAgenda();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadAgenda() {
    widget.viewmodel.loadAgendaDays(widget.eventId).then((value) {
      for (var day in widget.viewmodel.agendaDays.value) {
        _updateTileState(
          key: day.date,
          value: ExpansionTileState(isExpanded: true, tabBarIndex: 0),
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAgenda();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, value, child) {
        if (value == ViewState.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (value == ViewState.error) {
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

        if (widget.viewmodel.agendaDays.value.isEmpty) {
          return NoDataScreen(message: location.noSessionsFound);
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 28.0, left: 28.0),
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.viewmodel.agendaDays.value.length,
                  itemBuilder: (context, index) {
                    final String agendaDayId =
                        widget.viewmodel.agendaDays.value[index].uid;
                    final String date =
                        widget.viewmodel.agendaDays.value[index].date;
                    final bool isExpanded =
                        _expansionTilesStates[agendaDayId]?.isExpanded ?? false;
                    final int tabBarIndex =
                        _expansionTilesStates[agendaDayId]?.tabBarIndex ?? 0;
                    return ExpansionTile(
                      shape: const Border(),
                      initiallyExpanded: isExpanded,
                      showTrailingIcon: false,
                      onExpansionChanged: (value) {
                        setState(() {
                          final tabBarIndex =
                              _expansionTilesStates[agendaDayId]?.tabBarIndex ??
                              0;
                          _updateTileState(
                            key: agendaDayId,
                            value: ExpansionTileState(
                              isExpanded: value,
                              tabBarIndex: tabBarIndex,
                            ),
                          );
                        });
                      },
                      title: _buildTitleExpansionTile(isExpanded, date),
                      children: <Widget>[
                        _buildExpansionTileBody(
                          widget
                                  .viewmodel
                                  .agendaDays
                                  .value[index]
                                  .resolvedTracks
                                  ?.where(
                                    (track) => track.sessionUids.isNotEmpty,
                                  )
                                  .toList() ??
                              [],
                          tabBarIndex,
                          agendaDayId,
                          widget.eventId.toString(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleExpansionTile(bool isExpanded, String dayDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xddd1f0f4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${EventDateUtils.getDayName(dayDate, context)} - ${EventDateUtils.getFormattedDate(dayDate, context)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Icon(Icons.expand_more),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTileBody(
    List<Track> tracks,
    int tabBarIndex,
    String agendaDayId,
    String eventId,
  ) {
    if (tabBarIndex >= tracks.length) {
      tabBarIndex = 0;
      if (tracks.isEmpty) {
        return const SizedBox.shrink();
      }
    }
    return DefaultTabController(
      initialIndex: tabBarIndex,
      length: tracks.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: List.generate(tracks.length, (index) {
              return Tab(text: tracks[index].name);
            }),
          ),
          CustomTabBarView(
            tabController: widget.tabController,
            agendaDayId: agendaDayId,
            tracks: tracks,
            currentIndex: tabBarIndex,
            eventId: eventId,
            onIndexChanged: (value) {
              final isExpanded =
                  _expansionTilesStates[agendaDayId]?.isExpanded ?? false;
              _updateTileState(
                key: agendaDayId,
                value: ExpansionTileState(
                  isExpanded: isExpanded,
                  tabBarIndex: value,
                ),
              );
            },
            location: widget.location.toString(),
          ),
        ],
      ),
    );
  }

  void _updateTileState({
    required String key,
    required ExpansionTileState value,
  }) {
    _expansionTilesStates[key] = value;
  }
}

// ignore: must_be_immutable
class CustomTabBarView extends StatefulWidget {
  final List<Track> tracks;
  int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final String agendaDayId, eventId, location;
  final TabController? tabController;

  CustomTabBarView({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.agendaDayId,
    required this.eventId,
    required this.location,
    this.tabController,
  });

  @override
  State<CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView> {
  List<SessionCards> sessionCards = [];

  @override
  void initState() {
    super.initState();
    sessionCards = List.generate(widget.tracks.length, (index) {
      return SessionCards(
        tabController: widget.tabController,
        sessions: widget.tracks[index].resolvedSessions
            .where(
              (session) =>
                  session.eventUID == widget.eventId &&
                  session.agendaDayUID == widget.agendaDayId,
            )
            .toList(),
        trackId: widget.tracks[index].uid,
        agendaDayId: widget.agendaDayId,
        eventId: widget.eventId,
        location: widget.location,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabBarController = DefaultTabController.of(context);
    tabBarController.addListener(() {
      setState(() {
        widget.onIndexChanged(tabBarController.index);
        widget.currentIndex = tabBarController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sessionCards.isEmpty) return const SizedBox.shrink();
    return sessionCards[widget.currentIndex];
  }
}

class SessionCards extends StatefulWidget {
  final AgendaViewModel viewModel = getIt<AgendaViewModel>();
  final String agendaDayId, trackId, eventId, location;
  final List<Session> sessions;
  final TabController? tabController;

  SessionCards({
    super.key,
    required this.sessions,
    required this.agendaDayId,
    required this.trackId,
    required this.eventId,
    required this.location,
    this.tabController,
  });

  @override
  State<SessionCards> createState() => _SessionCardsState();
}

class _SessionCardsState extends State<SessionCards> {
  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.sessions.isEmpty
            ? [
                SizedBox(
                  height: 150,
                  child: Center(child: Text(location.noSessionsFound)),
                ),
              ]
            : List.generate(widget.sessions.length, (index) {
                final session = widget.sessions[index];

                return InkWell(
                  onTap: () async {
                    var githubService = await SecureInfo.getGithubKey();
                    if (githubService.token != null &&
                        githubService.token?.isNotEmpty == true) {
                      List<AgendaDay>? agendaDays = await AppRouter.router.push(
                        AppRouter.agendaFormPath,
                        extra: AgendaFormData(
                          eventId: widget.eventId,
                          session: session,
                          agendaDayId: widget.agendaDayId,
                          trackId: widget.trackId,
                        ),
                      );
                      if (agendaDays != null) {
                        widget.viewModel.loadAgendaDays(widget.eventId);
                      }
                    }
                  },
                  child: _buildSessionCard(
                    context,
                    Session(
                      title: session.title,
                      time: session.time,
                      speakerUID: session.speakerUID,
                      description: session.description,
                      type: session.type,
                      uid: session.uid,
                      eventUID: session.eventUID,
                      agendaDayUID: session.agendaDayUID,
                    ),
                    widget.viewModel.speakers.value
                            .where(
                              (element) => element.uid == session.speakerUID,
                            )
                            .firstOrNull
                            ?.name ??
                        "",
                    onDeleteTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteDialog(
                            title: location.deleteSessionTitle,
                            message: location.deleteSessionMessage,
                            onDeletePressed: () async {
                              await widget.viewModel
                                  .removeSessionAndReloadAgenda(
                                    session.uid,
                                    widget.eventId,
                                    agendaDayUID: session.agendaDayUID,
                                  );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              }),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    Session session,
    String speakerName, {
    required Function() onDeleteTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: SessionTypes.getSessionTypeColor(
                      context,
                      session.type,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    session.time,
                    style: TextStyle(
                      color: SessionTypes.getSessionTypeTextColor(
                        context,
                        session.type,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (session.type != 'break')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      SessionTypes.getSessionTypeLabel(context, session.type),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (speakerName.isNotEmpty && session.type != 'break') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      widget.tabController?.animateTo(1);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          speakerName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (session.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                session.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            FutureBuilder<bool>(
              future: widget.viewModel.checkToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: onDeleteTap,
                      icon: const Icon(Icons.delete),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (widget.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      final location = widget.location.toString();
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
    );
  }
}
