import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/config/secure_info.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_fonts.dart';
import '../agenda/agenda_screen.dart';
import '../login/admin_login_screen.dart';
import '../speaker/speakers_screen.dart';
import '../sponsor/sponsors_screen.dart';
import 'event_detail_view_model.dart';

/// Event detail screen that uses dependency injection for data loading
class EventDetailScreen extends StatefulWidget {
  final EventDetailViewModel viewmodel = getIt<EventDetailViewModel>();
  final String eventId, location;
  final bool onlyOneEvent;

  EventDetailScreen({
    super.key,
    required this.eventId,
    required this.location,
    this.onlyOneEvent = false,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  int _titleTapCount = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    screens = [
      AgendaScreen(
        eventId: widget.eventId,
        tabController: _tabController,
        location: widget.location,
      ),
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

    return FutureBuilder(
      future: widget.viewmodel.setup(widget.eventId),
      builder: (context, asyncSnapshot) {
        return ValueListenableBuilder(
          valueListenable: widget.viewmodel.notShowReturnArrow,
          builder: (context, value, child) {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 150, // Increased height for responsive layout
                backgroundColor: Colors.white,
                titleSpacing: 0.0,
                centerTitle: false,
                iconTheme: const IconThemeData(
                  color: Colors.blue,
                ), // Applied to leading icon if any
                automaticallyImplyLeading:
                    false, // We handle the back button manually
                elevation: 0,
                title: GestureDetector(
                  onTap: () async {
                    _titleTapCount++;

                    if (_titleTapCount >= 5) {
                      _titleTapCount = 0;
                      var githubService = await SecureInfo.getGithubKey();
                      if (githubService.token == null) {
                        if (context.mounted) {
                          await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              child: AdminLoginScreen(() async {
                                await widget.viewmodel.loadEventData(
                                  widget.eventId,
                                );
                              }),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(location.confirmLogout),
                                content: Text(location.confirmLogoutMessage),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(location.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(location.logout),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            setState(() async {
                              await SecureInfo.removeGithubKey();
                              await widget.viewmodel.loadEventData(
                                widget.eventId,
                              );
                            });
                          }
                        }
                      }
                    }
                    // Reset counter after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _titleTapCount = 0;
                        });
                      }
                    });
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 600;
                      final titleWidget = Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!value)
                            const BackButton()
                          else
                            const SizedBox(
                              width: 16,
                            ), // Maintain alignment when no back button
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 0,
                            ), // Adjusted from 8.0
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
                      );
                      final tabBarWidget = TabBar(
                        controller: _tabController,
                        isScrollable: isWideScreen,
                        tabAlignment: isWideScreen
                            ? TabAlignment.center
                            : TabAlignment.fill,
                        labelColor: Colors.blue,
                        padding: isWideScreen
                            ? const EdgeInsets.symmetric(horizontal: 16.0)
                            : EdgeInsets.zero,
                        unselectedLabelColor: Colors.grey,
                        dividerHeight: 0,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        indicatorColor: Colors.transparent,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(child: Text(location.agenda)),
                          Tab(child: Text(location.speakers)),
                          Tab(child: Text(location.sponsors)),
                        ],
                      );

                      if (isWideScreen) {
                        return SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(flex: 1, child: titleWidget),
                              Expanded(flex: 3, child: tabBarWidget),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ), // Pushes the TabBar to the center
                            ],
                          ),
                        );
                      } else {
                        // Narrow screen layout
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: titleWidget,
                            ),
                            tabBarWidget,
                          ],
                        );
                      }
                    },
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
                              style: AppFonts.titleHeadingForm.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          FutureBuilder(
                            future: widget.viewmodel.checkToken(),
                            builder: (context, asyncSnapshot) {
                              if (asyncSnapshot.data == true) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 52.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // The index of the currently selected tab can be obtained from the TabController.
                                      int selectedIndex = _tabController.index;
                                      // Now you can perform an action based on the selected index.
                                      switch (selectedIndex) {
                                        case 0:
                                          List<AgendaDay>? agendaDays =
                                              await AppRouter.router.push(
                                                AppRouter.agendaFormPath,
                                                extra: AgendaFormData(
                                                  eventId: widget.eventId,
                                                ),
                                              );

                                          if (agendaDays != null) {
                                            final AgendaScreen agendaScreen =
                                                (screens[0] as AgendaScreen);
                                            agendaScreen.viewmodel
                                                .loadAgendaDays(widget.eventId);
                                          }
                                          break;
                                        case 1:
                                          final Speaker? newSpeaker =
                                              await AppRouter.router.push(
                                                AppRouter.speakerFormPath,
                                                extra: {
                                                  'eventId': widget.eventId,
                                                },
                                              );

                                          if (newSpeaker != null) {
                                            final SpeakersScreen
                                            speakersScreen =
                                                (screens[1] as SpeakersScreen);
                                            speakersScreen.viewmodel.addSpeaker(
                                              newSpeaker,
                                              widget.eventId,
                                            );
                                          }
                                          break;
                                        case 2:
                                          final Sponsor? newSponsor =
                                              await AppRouter.router.push(
                                                AppRouter.sponsorFormPath,
                                                extra: {
                                                  'eventId': widget.eventId,
                                                },
                                              );

                                          if (newSponsor != null) {
                                            final SponsorsScreen
                                            sponsorsScreen =
                                                (screens[2] as SponsorsScreen);
                                            await sponsorsScreen.viewmodel
                                                .addSponsor(
                                                  newSponsor,
                                                  widget.eventId,
                                                );
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
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
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
          },
        );
      },
    );
  }
}
