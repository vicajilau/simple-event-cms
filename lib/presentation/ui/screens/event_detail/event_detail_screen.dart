import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../agenda/agenda_screen.dart';
import '../agenda/form/agenda_form_screen.dart';
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
    _tabController.addListener(() async {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    screens = [
      AgendaScreen(eventId: widget.eventId, tabController: _tabController),
      SpeakersScreen(eventId: widget.eventId),
      SponsorsScreen(eventId: widget.eventId),
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
    final location = AppLocalizations.of(context)!;

    return ValueListenableBuilder<String>(
      valueListenable: widget.viewmodel.eventTitle,
      builder: (context, viewState, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: AppBar(
              backgroundColor: Colors.white,
              titleSpacing: 0.0,
              centerTitle: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      widget.viewmodel.eventTitle.value,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          child: Text(
                            location.agenda,
                          ),
                        ),
                        Tab(
                            child: Text(
                          location.speakers,
                        )),
                        Tab(
                            child: Text(
                          location.sponsors,
                        )),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 4,
                    color: Colors.black,
                  ),

                ],
              ),
            ),
          ),
          body: ValueListenableBuilder<ViewState>(
            valueListenable: widget.viewmodel.viewState,
            builder: (context, viewState, child) {
              if (viewState == ViewState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (viewState == ViewState.error) {
                // Using WidgetsBinding.instance.addPostFrameCallback to show a dialog
                // after the build phase is complete, preventing build-time state changes.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => CustomErrorDialog(
                        errorMessage: widget.viewmodel.errorMessage,
                        onCancel: () => {
                          widget.viewmodel.setErrorKey(null),
                          widget.viewmodel.viewState.value =
                              ViewState.loadFinished,
                          Navigator.of(context).pop(),
                        },
                        buttonText: location.closeButton,
                      ),
                    );
                  }
                });
              }

              return TabBarView(controller: _tabController, children: screens);
            },
          ),
          floatingActionButton: FutureBuilder<bool>(
            future: widget.viewmodel.checkToken(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return AddFloatingActionButton(
                  onPressed: () async {
                    if (_selectedIndex == 0) {
                      _addSession(widget.eventId);
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
      },
    );
  }

  void _addSession(String eventId) async {
    List<AgendaDay>? agendaDays = await AppRouter.router.push(
      AppRouter.agendaFormPath,
      extra: AgendaFormData(eventId: eventId),
    );

    if (agendaDays != null) {
      final AgendaScreen agendaScreen = (screens[0] as AgendaScreen);
      agendaScreen.viewmodel.loadAgendaDays(widget.eventId);
    }
  }

//todo monta: borrar esto? ya esta en speakers screen
  void _addSpeaker(String parentId) async {
    final Speaker? newSpeaker = await AppRouter.router.push(
      AppRouter.speakerFormPath,
      extra: {'eventId': parentId},
    );

    if (newSpeaker != null) {
      final SpeakersScreen speakersScreen = (screens[1] as SpeakersScreen);
      speakersScreen.viewmodel.addSpeaker(newSpeaker, parentId);
    }
  }

//todo monta: borrar esto? ya esta en sponsor screen
  void _addSponsor(String parentId) async {
    final Sponsor? newSponsor = await AppRouter.router.push(
      AppRouter.sponsorFormPath,
      extra: {'eventId': parentId},
    );

    if (newSponsor != null) {
      final SponsorsScreen sponsorsScreen = (screens[2] as SponsorsScreen);
      await sponsorsScreen.viewmodel.addSponsor(newSponsor, parentId);
    }
  }
}
