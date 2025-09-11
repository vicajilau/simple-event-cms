import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

/// Event detail screen that uses dependency injection for data loading
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  List<AgendaDay> _agendaDays = [];
  List<Speaker> _speakers = [];
  List<Sponsor> _sponsors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final useCase = getIt<EventUseCase>();
      final events = await useCase.getComposedEvents();

      // Buscar el evento específico por ID
      final event = events.firstWhere(
        (e) => e.uid == widget.eventId,
        orElse: () => events.first, // Fallback al primer evento
      );

      setState(() {
        _event = event;
        _agendaDays = event.agenda?.days ?? [];
        _speakers = event.speakers ?? [];
        _sponsors = event.sponsors ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando evento: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEventData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Evento no encontrado')));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_event!.eventName),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.schedule),
                text: AppLocalizations.of(context)?.agenda ?? 'Agenda',
              ),
              Tab(
                icon: const Icon(Icons.people),
                text: AppLocalizations.of(context)?.speakers ?? 'Ponentes',
              ),
              Tab(
                icon: const Icon(Icons.business),
                text:
                    AppLocalizations.of(context)?.sponsors ?? 'Patrocinadores',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () => _showLanguageSelector(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Agenda Tab
            _agendaDays.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)?.noEventsScheduled ??
                          'No hay eventos programados',
                    ),
                  )
                : AgendaScreen(
                    agendaDays: _agendaDays,
                    editSession: (day, track, session) {
                      // TODO: Implementar edición de sesión
                    },
                    removeSession: (session) {
                      // TODO: Implementar eliminación de sesión
                    },
                  ),
            // Speakers Tab
            _speakers.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)?.noSpeakersRegistered ??
                          'No hay ponentes registrados',
                    ),
                  )
                : SpeakersScreen(speakers: _speakers),
            // Sponsors Tab
            _sponsors.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)?.noSponsorsRegistered ??
                          'No hay patrocinadores registrados',
                    ),
                  )
                : SponsorsScreen(sponsors: _sponsors),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.changeLanguage ?? 'Cambiar Idioma',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Español'),
              leading: const Text('🇪🇸'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Français'),
              leading: const Text('🇫🇷'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Italiano'),
              leading: const Text('🇮🇹'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Português'),
              leading: const Text('🇵🇹'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Català'),
              leading: const Text('🏴'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Galego'),
              leading: const Text('🏴'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
            ListTile(
              title: const Text('Euskera'),
              leading: const Text('🏴'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar cambio de idioma global
              },
            ),
          ],
        ),
      ),
    );
  }
}
