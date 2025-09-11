import 'package:flutter/material.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/time_utils.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import 'event_container_view_model.dart';

class EventContainerScreen extends StatefulWidget {
  final EventContainerViewModel viewModel;

  /// Currently selected locale for the application
  final Locale locale;

  /// Callback function to be called when the locale changes
  final ValueChanged<Locale> localeChanged;

  const EventContainerScreen({
    super.key,
    required this.locale,
    required this.localeChanged,
    required this.viewModel,
  });

  @override
  State<EventContainerScreen> createState() => _EventContainerScreenState();
}

class _EventContainerScreenState extends State<EventContainerScreen> {
  /// Currently selected tab index
  int _selectedIndex = 0;
  List<AgendaDay> _agendaDays = [];
  List<Speaker> _speakers = [];

  /// List of screens to display in the IndexedStack
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _agendaDays = [...widget.viewModel.getAgenda().days];
    _sortAgendaDaysByDate();
    for (var agendaDay in _agendaDays) {
      for (var track in agendaDay.tracks) {
        _sortSessionsByStartTime(track);
      }
    }
    _speakers = [...widget.viewModel.getSpeakers()];
    _screens = [
      AgendaScreen(
        agendaDays: _agendaDays,
        key: UniqueKey(),
        editSession: _editSession,
        removeSession: _deleteSession,
      ),
      SpeakersScreen(speakers: widget.viewModel.getSpeakers()),
      SponsorsScreen(sponsors: widget.viewModel.getSponsors()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editando evento'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.save))],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.schedule),
            selectedIcon: const Icon(Icons.schedule),
            label: AppLocalizations.of(context)!.agenda,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: AppLocalizations.of(context)!.speakers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business),
            label: AppLocalizations.of(context)!.sponsors,
          ),
        ],
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () async {
          if (_selectedIndex == 0) {
            AgendaDay? newAgendaDay = await _navigateTo<AgendaDay>(
              _agendaFormScreen(),
            );
            _addNewSession(newAgendaDay: newAgendaDay);
          } else if (_selectedIndex == 1) {
            _addSpeaker();
          } else if (_selectedIndex == 2) {
            final sponsor = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSponsorScreen()),
            );
            if (sponsor != null) {
              widget.viewModel.addSponsor(sponsor);
            }
          }
        },
      ),
    );
  }

  AgendaFormScreen _agendaFormScreen({
    String? day,
    String? track,
    Session? session,
  }) {
    return AgendaFormScreen(
      data: EventFormData(
        speakers: _getSpeakers(),
        rooms: _getRoomNames(),
        days: _getAgendaDays(),
        sessionTypes: SessionTypes.allLabels(context),
        session: session,
        track: track ?? '',
        day: day ?? '',
      ),
    );
  }

  Future<T?> _navigateTo<T>(Widget screen) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  List<String> _getAgendaDays() {
    return _agendaDays.map((agendaDay) {
      return agendaDay.date;
    }).toList();
  }

  List<String> _getRoomNames() {
    return _agendaDays
        .expand((agendaDay) => agendaDay.tracks.map((track) => track.name))
        .toSet()
        .toList();
  }

  List<String> _getSpeakers() {
    return _speakers.map((speaker) {
      return speaker.name;
    }).toList();
  }

  /// Handles tab selection changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addSpeaker() async {
    final newSpeaker = await Navigator.push<Speaker>(
      context,
      MaterialPageRoute(builder: (context) => const SpeakerFormScreen()),
    );

    if (newSpeaker != null) {
      setState(() {
        _speakers.add(newSpeaker);
        _screens[1] = SpeakersScreen(key: UniqueKey(), speakers: _speakers);
      });
    }
  }

  void _editSession(
    String date,
    String trackName,
    Session sessionToEdit,
  ) async {
    AgendaDay agendaDayEdited = await _navigateTo(
      _agendaFormScreen(day: date, track: trackName, session: sessionToEdit),
    );

    _removeSessionFromAgenda(agendaDayEdited.tracks.first.sessions.first);
    _insertSessionToAgenda(agendaDayEdited);

    _refreshAgendaState();
  }

  void _insertSessionToAgenda(AgendaDay agendaDay) {
    final Session editedSession = agendaDay.tracks.first.sessions.first;

    AgendaDay? targetDay = _agendaDays.firstWhere(
      (d) => d.date == agendaDay.date,
      orElse: () => AgendaDay(date: agendaDay.date, tracks: []),
    );

    Track? targetTrack = targetDay.tracks.firstWhere(
      (t) => t.name == agendaDay.tracks.first.name,
      orElse: () {
        final newTrack = Track(
          color: '',
          name: agendaDay.tracks.first.name,
          sessions: [],
        );
        targetDay.tracks.add(newTrack);
        return newTrack;
      },
    );

    targetTrack.sessions.add(editedSession);
    _sortSessionsByStartTime(targetTrack);

    if (!_agendaDays.any((d) => d.date == targetDay.date)) {
      _agendaDays.add(targetDay);
    }
    _sortAgendaDaysByDate();
  }

  void _sortSessionsByStartTime(Track track) {
    track.sessions.sort((a, b) {
      final aMinutes = TimeUtils.parseStartTimeToMinutes(a.time);
      final bMinutes = TimeUtils.parseStartTimeToMinutes(b.time);
      return aMinutes.compareTo(bMinutes);
    });
  }

  void _sortAgendaDaysByDate() {
    _agendaDays.sort((a, b) {
      final aDate = DateTime.parse(a.date);
      final bDate = DateTime.parse(b.date);
      return aDate.compareTo(bDate);
    });
  }

  void _removeSessionFromAgenda(Session sessionToRemove) {
    for (var agendaDay in _agendaDays) {
      for (var track in agendaDay.tracks) {
        track.sessions.removeWhere((s) => s.uid == sessionToRemove.uid);
      }
    }
  }

  void _deleteSession(Session sessionToDelete) {
    _removeSessionFromAgenda(sessionToDelete);
    _refreshAgendaState();
  }

  void _addNewSession({AgendaDay? newAgendaDay}) {
    if (newAgendaDay == null) {
      return;
    }

    _insertSessionToAgenda(newAgendaDay);

    setState(() {
      _refreshAgendaState();
    });
  }

  void _refreshAgendaState() {
    setState(() {
      _screens[0] = AgendaScreen(
        agendaDays: _agendaDays,
        key: UniqueKey(),
        editSession: _editSession,
        removeSession: _deleteSession,
      );
    });
  }
}
