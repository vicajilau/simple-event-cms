import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

/// Event detail screen that uses dependency injection for data loading
class EventDetailScreen extends StatefulWidget {
  final EventDetailViewModel viewmodel = getIt<EventDetailViewModel>();
  final SpeakerViewModel viewmodelSpeaker = getIt<SpeakerViewModel>();
  final SponsorViewModel viewmodelSponsor = getIt<SponsorViewModel>();
  final String eventId;

  EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

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

          final agendaDays = widget.viewmodel.getAgenda().days;

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
                  : AgendaScreen(agendaDays: agendaDays),
              // Speakers Tab
              SpeakersScreen(),
              // Sponsors Tab
              SponsorsScreen(),
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
            AddFloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 0) {
                  _addTrackToAgenda();
                } else if (_selectedIndex == 1) {
                  _addSpeaker();
                } else if (_selectedIndex == 2) {
                  _addSponsor();
                }
              },
            );
          }
          ;
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _addTrackToAgenda() async {
    /*AgendaFormScreen agenda = AgendaFormScreen(
      data: EventFormData(
        rooms: [],
        days: [],
        speakers: [],
        sessionTypes: [],
        session: null,
        track: '[]',
        day: 'day',
      ),
      /* speakers: _getSpeakers(),
          rooms: _getRoomNames(),
          days: _getAgendaDays(),
          sessionTypes: SessionTypes.allLabels(context),
          session: session,
          track: track ?? '',
          day: day ?? '',*/
    );

    final newAgendaDay = await Navigator.push<Speaker>(
      context,
      MaterialPageRoute(builder: (context) => agenda),
    );
    _addNewSession(newAgendaDay: newAgendaDay);*/
  }

  void _addSpeaker() async {
    final Speaker? newSpeaker = await AppRouter.router.push(
      AppRouter.speakerFormPath,
    );

    if (newSpeaker != null) {
      widget.viewmodelSpeaker.addSpeaker(newSpeaker);
    }
  }

  Future<void> _addSponsor() async {
    final newSponsor = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddSponsorScreen()),
    );

    if (newSponsor != null && newSponsor is Sponsor) {
      widget.viewmodelSponsor.addSponsor(newSponsor);
    }
  }
}
