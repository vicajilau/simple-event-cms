import 'package:flutter/material.dart';
import 'package:sec/ui/dialogs/delete_dialog.dart';

import '../../core/models/models.dart';
import '../../core/utils/date_utils.dart';

class ExpansionTileState {
  final bool isExpanded;
  final int tabBarIndex;

  ExpansionTileState({required this.isExpanded, required this.tabBarIndex});
}

/// Screen that displays the event agenda with sessions organized by days and tracks
/// Supports multiple days and tracks with color-coded sessions
class AgendaScreen extends StatefulWidget {
  final List<AgendaDay> agendaDays;
  final void Function(String, String, Session) editSession;
  final void Function(Session) removeSession;

  const AgendaScreen({
    super.key,
    required this.agendaDays,
    required this.editSession,
    required this.removeSession,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final Map<String, ExpansionTileState> _expansionTilesStates = {};

  @override
  void initState() {
    super.initState();

    for (var day in widget.agendaDays) {
      _updateTileState(
        key: day.date,
        value: ExpansionTileState(isExpanded: false, tabBarIndex: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.agendaDays.length,
      itemBuilder: (context, index) {
        final String date = widget.agendaDays[index].date;
        final bool isExpanded =
            _expansionTilesStates[date]?.isExpanded ?? false;
        final int tabBarIndex = _expansionTilesStates[date]?.tabBarIndex ?? 0;
        return ExpansionTile(
          initiallyExpanded: isExpanded,
          showTrailingIcon: false,
          onExpansionChanged: (value) {
            setState(() {
              final tabBarIndex = _expansionTilesStates[date]?.tabBarIndex ?? 0;
              _updateTileState(
                key: date,
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
              widget.agendaDays[index].tracks,
              tabBarIndex,
              date,
            ),
          ],
        );
      },
    );
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
    String date,
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
            date: date,
            tracks: tracks,
            currentIndex: tabBarIndex,
            onIndexChanged: (value) {
              final isExpanded =
                  _expansionTilesStates[date]?.isExpanded ?? false;
              _updateTileState(
                key: date,
                value: ExpansionTileState(
                  isExpanded: isExpanded,
                  tabBarIndex: value,
                ),
              );
            },
            editSession: widget.editSession,
            removeSession: widget.removeSession,
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
  final String date;
  final List<Track> tracks;
  int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final void Function(String, String, Session) editSession;
  final void Function(Session) removeSession;

  CustomTabBarView({
    super.key,
    required this.tracks,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.editSession,
    required this.removeSession,
    required this.date,
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
        editSession: widget.editSession,
        removeSession: widget.removeSession,
        date: widget.date,
        track: widget.tracks[index].name,
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
  final String date, track;
  final List<Session> sessions;
  final void Function(String, String, Session) editSession;
  final void Function(Session) removeSession;

  const SessionCards({
    super.key,
    required this.sessions,
    required this.editSession,
    required this.removeSession,
    required this.date,
    required this.track,
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
                  child: Center(child: const Text('No hay sesiones')),
                ),
              ]
            : List.generate(sessions.length, (index) {
                final session = sessions[index];
                return GestureDetector(
                  onTap: () {
                    editSession(date, track, sessions[index]);
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
                            title: 'Borrar sesión',
                            message:
                                '¿Estás seguro de que deseas borrar la sesión??',
                            onDeletePressed: () {
                              removeSession(sessions[index]);
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
            if (session.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                session.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: onDeleteTap,
                icon: Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
