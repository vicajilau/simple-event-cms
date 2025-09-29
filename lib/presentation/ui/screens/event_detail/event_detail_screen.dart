import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../agenda/agenda_screen.dart';
import '../speaker/speakers_screen.dart';
import '../sponsor/sponsors_screen.dart';
import 'event_detail_view_model.dart';

/// Event detail screen that uses dependency injection for data loading
class EventDetailScreen extends StatefulWidget {
  final EventDetailViewModel viewmodel = getIt<EventDetailViewModel>();
  final String eventId;

  EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    screens = [
      AgendaScreen(agendaId: widget.viewmodel.agendaId),
      SpeakersScreen(speakers: widget.viewmodel.speakersId),
      SponsorsScreen(sponsors: widget.viewmodel.sponsorsId),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.viewmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventTitle = widget.viewmodel.eventTitle();

    return Scaffold(
      appBar: AppBar(title: Text(eventTitle)),
      body: ValueListenableBuilder<ViewState>(
        valueListenable: widget.viewmodel.viewState,
        builder: (context, viewState, child) {
          if (viewState == ViewState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewState == ViewState.error) {
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.viewmodel.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.viewmodel.setup,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Agenda Tab
              AgendaScreen(agendaId: widget.viewmodel.agendaId),
              // Speakers Tab
              SpeakersScreen(speakers: widget.viewmodel.speakersId),
              // Sponsors Tab
              SponsorsScreen(sponsors: widget.viewmodel.sponsorsId),
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
      floatingActionButton: FutureBuilder<bool>(
        future: widget.viewmodel.checkToken(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return AddFloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 0) {
                  _addTrackToAgenda();
                } else if (_selectedIndex == 1) {
                  _addSpeaker(widget.eventId);
                } else if (_selectedIndex == 2) {
                  _addSponsor(widget.eventId);
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _addTrackToAgenda() async {
    final Agenda? newAgenda = await AppRouter.router.push(
      AppRouter.agendaFormPath,
    );

    if (newAgenda != null) {
      final AgendaScreen agendaScreen = (screens[0] as AgendaScreen);
      agendaScreen.viewmodel.addTrack(newAgenda);
    }
  }

  void _addSpeaker(String parentId) async {
    final Speaker? newSpeaker = await AppRouter.router.push(
      AppRouter.speakerFormPath,
    );

    if (newSpeaker != null) {
      final SpeakersScreen speakersScreen = (screens[1] as SpeakersScreen);
      speakersScreen.viewmodel.addSpeaker(newSpeaker,parentId);
    }
  }

  void _addSponsor(String parentId) async {
    final Sponsor? newSponsor = await AppRouter.router.push(
      AppRouter.sponsorFormPath,
    );

    if (newSponsor != null) {
      final SponsorsScreen sponsorsScreen = (screens[2] as SponsorsScreen);
      sponsorsScreen.viewmodel.addSponsor(newSponsor,parentId);
    }
  }
}
