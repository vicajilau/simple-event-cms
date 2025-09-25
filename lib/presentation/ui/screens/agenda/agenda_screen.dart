import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/date_utils.dart';
import 'package:sec/presentation/ui/dialogs/dialogs.dart';
import 'package:sec/presentation/view_model_common.dart';

import 'agenda_view_model.dart';

class ExpansionTileState {
  final bool isExpanded;
  final int tabBarIndex;

  ExpansionTileState({required this.isExpanded, required this.tabBarIndex});
}

/// Screen that displays the event_collection agenda with sessions organized by days and tracks
/// Supports multiple days and tracks with color-coded sessions
class AgendaScreen extends StatefulWidget {
  final String? agendaId;
  final AgendaViewModel viewmodel = getIt<AgendaViewModel>();

  AgendaScreen({super.key, this.agendaId});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final Map<String, ExpansionTileState> _expansionTilesStates = {};

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.agendaId);

    for (var day in widget.viewmodel.agendaDays.value) {
      _updateTileState(
        key: day.date,
        value: ExpansionTileState(isExpanded: false, tabBarIndex: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.viewmodel.viewState,
        builder: (context, value, child) {
          if (value == ViewState.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (value == ViewState.error) {
            return Center(child: Text(widget.viewmodel.errorMessage));
          }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.viewmodel.agendaDays.value.length,
      itemBuilder: (context, index) {
        final String agendaDayId = widget.viewmodel.agendaDays.value[index].uid;
        final String date = widget.viewmodel.agendaDays.value[index].date;
        final bool isExpanded =
            _expansionTilesStates[agendaDayId]?.isExpanded ?? false;
        final int tabBarIndex = _expansionTilesStates[agendaDayId]?.tabBarIndex ?? 0;
        return ExpansionTile(
          shape: const Border(),
          initiallyExpanded: isExpanded,
          showTrailingIcon: false,
          onExpansionChanged: (value) {
            setState(() {
              final tabBarIndex = _expansionTilesStates[agendaDayId]?.tabBarIndex ?? 0;
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
              widget.viewmodel.agendaDays.value[index].tracks,
              tabBarIndex,
              agendaDayId,
              widget.agendaId.toString()
            ),
          ],
        );
      },
    );
  });
      }
      }


  Widget _buildTitleExpansionTile(bool isExpanded, String dayDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
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
    String agendaId,
  ) {
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
            agendaId: agendaId,
            agendaDayId: agendaDayId,
            tracks: tracks,
            currentIndex: tabBarIndex,
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
  final String agendaId, agendaDayId;

  CustomTabBarView({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.agendaId,
    required this.agendaDayId,
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
        sessions: widget.tracks[index].sessions,
        trackId: widget.tracks[index].uid,
        agendaId: widget.agendaId,
        agendaDayId: widget.agendaDayId,
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
    return sessionCards[widget.currentIndex];
  }
}

class SessionCards extends StatelessWidget {
  final AgendaViewModel _viewModel = getIt<AgendaViewModel>();
  final String agendaId, agendaDayId, trackId;
  final List<Session> sessions;

  SessionCards({
    super.key,
    required this.sessions,
    required this.agendaId,
    required this.agendaDayId,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sessions.isEmpty
            ? [
                SizedBox(
                  height: 150,
                  child: Center(child: const Text('No sessions')),
                ),
              ]
            : List.generate(sessions.length, (index) {
                final session = sessions[index];
                return GestureDetector(
                  onTap: () {
                    _viewModel.editSession(agendaId, agendaDayId, trackId, session);
                  },
                  child: _buildSessionCard(
                    context,
                    Session(
                      title: session.title,
                      time: session.time,
                      speaker: session.speaker,
                      description: session.description,
                      type: session.type,
                      uid: session.uid,
                    ),
                    onDeleteTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteDialog(
                            title: 'Delete session',
                            message:
                                'Are you sure you want to delete the session?',
                            onDeletePressed: () {
                              _viewModel.removeSession(agendaId, agendaDayId, trackId, session);
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
    Session session, {
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
            if (session.speaker.isNotEmpty && session.type != 'break') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.speaker,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
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
              future: _viewModel.checkToken(),
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
          ],
        ),
      ),
    );
  }
}
