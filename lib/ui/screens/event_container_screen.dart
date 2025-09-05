import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/services/data_loader.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/add_sponsor_screen.dart';
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
        editSession: _editSession,
        removeSession: _deleteSession,
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
              _addNewSession(newAgendaDay: newAgendaDay);
            } else if (_selectedIndex == 2) {
              _navigateTo(AddSponsorScreen());
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

  EventFormScreen _eventFormScreen({
    String? day,
    String? track,
    Session? session,
  }) {
    return EventFormScreen(
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

  void _editSession(
    String date,
    String trackName,
    Session sessionToEdit,
  ) async {
    // Navegar al formulario de edición
    AgendaDay agendaDayEdited = await _navigateTo(
      _eventFormScreen(day: date, track: trackName, session: sessionToEdit),
    );

    Session editedSession = agendaDayEdited.tracks.first.sessions.first;

    _removeSessionFromAgenda(editedSession);

    // Buscar el día editado en la agenda
    _insertSessionToAgenda(agendaDayEdited, editedSession);

    _refreshAgendaState();
  }

  void _insertSessionToAgenda(
    AgendaDay agendaDayEdited,
    Session editedSession,
  ) {
    // Buscar el día editado en la agenda
    AgendaDay? targetDay = _agendaDays.firstWhere(
      (d) => d.date == agendaDayEdited.date,
      orElse: () => AgendaDay(date: agendaDayEdited.date, tracks: []),
    );

    // Buscar el track editado en ese día
    Track? targetTrack = targetDay.tracks.firstWhere(
      (t) => t.name == agendaDayEdited.tracks.first.name,
      orElse: () {
        final newTrack = Track(
          color: '',
          name: agendaDayEdited.tracks.first.name,
          sessions: [],
        );
        targetDay.tracks.add(newTrack);
        return newTrack;
      },
    );

    // Agregar la sesión editada
    targetTrack.sessions.add(editedSession);

    // Si el día no existía, lo agregamos a la agenda
    if (!_agendaDays.any((d) => d.date == targetDay.date)) {
      _agendaDays.add(targetDay);
    }
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
        editSession: _editSession,
        removeSession: _deleteSession,
      );
    });
  }
}
