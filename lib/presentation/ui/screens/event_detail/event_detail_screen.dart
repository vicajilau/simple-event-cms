import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/view_model_common.dart';

/// Event detail screen that uses dependency injection for data loading
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  EventDetailViewModel? viewmodel;
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final useCase = getIt<EventUseCase>();
    viewmodel = EventDetailViewModelImp(useCase, widget.eventId);
    viewmodel!.setup();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    viewmodel!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventTitle = viewmodel?.eventTitle() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(eventTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<ViewState>(
        valueListenable: viewmodel!.viewState,
        builder: (context, viewState, child) {
          if (viewState == ViewState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewState == ViewState.error) {
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewmodel!.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewmodel!.setup,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final agendaDays = viewmodel?.getAgenda().days ?? [];
          final speakers = viewmodel?.getSpeakers() ?? [];
          final sponsors = viewmodel?.getSponsors() ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              // Agenda Tab
              agendaDays.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)?.noEventsScheduled ??
                            'No hay eventos programados',
                      ),
                    )
                  : AgendaScreen(
                      agendaDays: agendaDays,
                      editSession: (day, track, session) {
                        // TODO: Implementar edición de sesión
                      },
                      removeSession: (session) {
                        // TODO: Implementar eliminación de sesión
                      },
                    ),
              // Speakers Tab
              speakers.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)?.noSpeakersRegistered ??
                            'No hay ponentes registrados',
                      ),
                    )
                  : SpeakersScreen(speakers: speakers),
              // Sponsors Tab
              sponsors.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)?.noSponsorsRegistered ??
                            'No hay patrocinadores registrados',
                      ),
                    )
                  : SponsorsScreen(sponsors: sponsors),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: AppLocalizations.of(context)?.agenda ?? 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: AppLocalizations.of(context)?.speakers ?? 'Ponentes',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business),
            label: AppLocalizations.of(context)?.sponsors ?? 'Patrocinadores',
          ),
        ],
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
