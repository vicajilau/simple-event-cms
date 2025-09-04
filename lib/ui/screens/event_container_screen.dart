import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/services/data_loader.dart';
import '../../l10n/app_localizations.dart';
import 'screens.dart';

class EventContainerScreen extends StatefulWidget {
  /// Site configuration containing event details
  final List<SiteConfig> config;

  /// Data loader for fetching content from various sources
  final DataLoader dataLoader;

  /// Currently selected locale for the application
  final Locale locale;

  /// Callback function to be called when the locale changes
  final ValueChanged<Locale> localeChanged;

  final List<AgendaDay> agendaDays;
  final List<Speaker> speakers;
  final List<Sponsor> sponsors;

  const EventContainerScreen({
    super.key,
    required this.config,
    required this.dataLoader,
    required this.locale,
    required this.localeChanged,
    required this.agendaDays,
    required this.speakers,
    required this.sponsors,
  });

  @override
  State<EventContainerScreen> createState() => _EventContainerScreenState();
}

class _EventContainerScreenState extends State<EventContainerScreen> {
  /// Currently selected tab index
  int _selectedIndex = 0;
  List<AgendaDay> _agendaDays = [];
  List<Speaker> _speakers = [];
  List<Sponsor> _sponsors = [];

  /// List of screens to display in the IndexedStack
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _agendaDays = [...widget.agendaDays];
    _speakers = [...widget.speakers];
    _sponsors = [...widget.sponsors];
    _screens = [
      AgendaScreen(
        agendaDays: _agendaDays,
        key: UniqueKey(),
        editSession: _onAgendaCardTapped,
        removeSession: _onAgendaCardDeleted,
      ),
      SpeakersScreen(dataLoader: widget.dataLoader, speakers: widget.speakers),
      SponsorsScreen(dataLoader: widget.dataLoader, sponsors: widget.sponsors),
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
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () async {
            if (_selectedIndex == 0) {
              AgendaDay? newAgendaDay = await _navigateTo<AgendaDay>(
                _eventFormScreen(),
              );
              _addAgendaData(newAgendaDay: newAgendaDay);
            }
          },
          elevation: 16,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  EventFormScreen _eventFormScreen({Session? session}) {
    return EventFormScreen(
      speakers: _getSpeakers(),
      rooms: _getRoomNames(),
      days: _getAgendaDays(),
      sessionTypes: SessionTypes.allLabels(context),
      data: session,
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

  void _onAgendaCardTapped(Session sessionToEdit) async {
    AgendaDay editedSession = await _navigateTo(
      _eventFormScreen(session: sessionToEdit),
    );

    _refreshAgendaState();
  }

  void _onAgendaCardDeleted(Session sessionToDelete) {
    for (var agendaDay in _agendaDays) {
      for (var track in agendaDay.tracks) {
        track.sessions.removeWhere(
          (session) => session.uid == sessionToDelete.uid,
        );
      }
    }
    _refreshAgendaState();
  }

  void _addAgendaData({AgendaDay? newAgendaDay}) {
    if (newAgendaDay != null) {
      return;
    }

    final dateForNewSession = newAgendaDay!.date;
    final trackNameForNewSession = newAgendaDay.tracks.first.name;
    final newSession = newAgendaDay.tracks.first.sessions.first;

    _agendaDays = _agendaDays.map((agendaDay) {
      if (agendaDay.date == dateForNewSession) {
        final updatedTracks = agendaDay.tracks.map((track) {
          if (track.name == trackNameForNewSession) {
            return Track(
              name: track.name,
              color: '',
              sessions: [...track.sessions, newSession],
            );
          }
          return track;
        }).toList();
        return AgendaDay(date: agendaDay.date, tracks: updatedTracks);
      }
      return agendaDay;
    }).toList();

    setState(() {
      _refreshAgendaState();
    });
  }

  void _refreshAgendaState() {
    setState(() {
      _screens[0] = AgendaScreen(
        agendaDays: _agendaDays,
        key: UniqueKey(),
        editSession: _onAgendaCardTapped,
        removeSession: _onAgendaCardDeleted,
      );
    });
  }
}
