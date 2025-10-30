import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
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
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
    _tabController = TabController(length: 3, vsync: this);
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
              iconTheme: const IconThemeData(color: Colors.blue),
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop()) const SizedBox(width: 8.0),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            widget.viewmodel.eventTitle.value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true, // `true` for variable tab widths
                    labelPadding: const EdgeInsets.symmetric(horizontal: 58.0),
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    dividerHeight: 0,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicatorColor: Colors.transparent,
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(child: Text(location.agenda)),
                      Tab(child: Text(location.speakers)),
                      Tab(child: Text(location.sponsors)),
                    ],
                  ),
                  const Spacer(), // Pushes the TabBar to the center
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
                          widget.viewmodel.viewState.value = ViewState.loadFinished,
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
        );
      },
    );
  }

  /*void _addSession(String eventId) async {
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

  void _addSponsor(String parentId) async {
    final Sponsor? newSponsor = await AppRouter.router.push(
      AppRouter.sponsorFormPath,
      extra: {'eventId': parentId},
    );

    if (newSponsor != null) {
      final SponsorsScreen sponsorsScreen = (screens[2] as SponsorsScreen);
      await sponsorsScreen.viewmodel.addSponsor(newSponsor, parentId);
    }
  }*/
}
