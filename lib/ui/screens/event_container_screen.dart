import 'package:flutter/material.dart';
import 'package:sec/ui/screens/event_form_screen.dart';
import 'package:sec/ui/screens/speaker_form_screen.dart';
import 'package:sec/ui/widgets/add_sponsor_screen.dart';

import '../../core/models/agenda.dart';
import '../../core/models/site_config.dart';
import '../../core/models/speaker.dart';
import '../../core/models/sponsor.dart';
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
  List<Widget> get _screens => [
    AgendaScreen(key: UniqueKey(), agendaDays: _agendaDays),
    SpeakersScreen(key: UniqueKey(), speakers: _speakers),
    SponsorsScreen(key: UniqueKey(), sponsors: _sponsors),
  ];

  @override
  void initState() {
    super.initState();
    _agendaDays = [...widget.agendaDays];
    _speakers = [...widget.speakers];
    _sponsors = [...widget.sponsors];
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
          onPressed: () {
            if (_selectedIndex == 0) {
              navigateTo(
                EventFormScreen(
                  speakers: ['Fran', 'Ting Mei'],
                  rooms: [],
                  days: ['3 de Septiembre', '4 de Septiembre'],
                  talkTypes: [],
                ),
              );
            } else if (_selectedIndex == 1) {
              _addSpeaker();
            } else if (_selectedIndex == 2) {
              navigateTo(AddSponsorScreen());
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

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
}
