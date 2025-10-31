import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_fonts.dart';
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

        return ValueListenableBuilder(
          valueListenable: widget.viewmodel.eventTitle,
          builder: (context, value, child) {
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
                            if (Navigator.of(context).canPop())
                              const SizedBox(width: 8.0),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                location.eventManager,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
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
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 42.0),
                          child: Text(
                            widget.viewmodel.eventTitle.value,
                            style: AppFonts.titleHeadingForm.copyWith(color: Colors.black,
                          ),
                        ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 52.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // The index of the currently selected tab can be obtained from the TabController.
                              int selectedIndex = _tabController.index;
                              // Now you can perform an action based on the selected index.
                              switch (selectedIndex) {
                                case 0:
                                  List<AgendaDay>? agendaDays = await AppRouter.router.push(
                                    AppRouter.agendaFormPath,
                                    extra: AgendaFormData(eventId: widget.eventId),
                                  );

                                  if (agendaDays != null) {
                                    final AgendaScreen agendaScreen = (screens[0] as AgendaScreen);
                                    agendaScreen.viewmodel.loadAgendaDays(widget.eventId);
                                  }
                                  break;
                                case 1:
                                  final Speaker? newSpeaker = await AppRouter.router.push(
                                    AppRouter.speakerFormPath,
                                    extra: {'eventId': widget.eventId},
                                  );

                                  if (newSpeaker != null) {
                                    final SpeakersScreen speakersScreen = (screens[1] as SpeakersScreen);
                                    speakersScreen.viewmodel.addSpeaker(newSpeaker, widget.eventId);
                                  }
                                  break;
                                case 2:
                                  final Sponsor? newSponsor = await AppRouter.router.push(
                                    AppRouter.sponsorFormPath,
                                    extra: {'eventId': widget.eventId},
                                  );

                                  if (newSponsor != null) {
                                    final SponsorsScreen sponsorsScreen = (screens[2] as SponsorsScreen);
                                    await sponsorsScreen.viewmodel.addSponsor(newSponsor, widget.eventId);
                                  }
                                  break;
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedIndex == 0
                                      ? location.addSession
                                      : _selectedIndex == 1
                                          ? location.addSpeaker
                                          : location.addSponsor,
                                ),
                              ],
                            )
                            ,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                  ValueListenableBuilder<ViewState>(
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
            
                      return Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: screens,
                        ),
                      );
                    },
                  ),
                ],
              ),
                );
          }
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
