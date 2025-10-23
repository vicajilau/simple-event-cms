import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/core/utils/app_fonts.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/time_utils.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../speaker/speaker_form_screen.dart';

class AgendaFormData {
  final String? trackId, agendaDayId, eventId;
  final Session? session;

  AgendaFormData({this.session, this.trackId,this.agendaDayId, required this.eventId});
}

class AgendaFormScreen extends StatefulWidget {
  final AgendaFormData? data;
  final AgendaFormViewModel viewmodel = getIt<AgendaFormViewModel>();

  AgendaFormScreen({super.key, this.data});

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  Event? event;
  TimeOfDay? _initSessionTime, _endSessionTime;
  String _selectedDay = '';
  String _selectedTrackUid = '';
  Speaker? _selectedSpeaker;
  String _selectedTalkType = '';
  final double _spacing = 24;
  final double _spacingForRowDropdown = 40, _spacingForRowTime = 40;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _timeErrorMessage;

  List<Track> tracks = [];
  List<AgendaDay> agendaDays = [];
  List<Speaker> speakers = [];
  final List<String> sessionTypes = SessionType.values
      .map((e) => e.name)
      .toList();

  final AgendaFormViewModel agendaFormViewModel = getIt<AgendaFormViewModel>();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final data = widget.data;
    if (data == null) {
      // Handling creation of a new session from scratch if needed.
      // For now, let's assume `data` is always provided.
      setState(() => agendaFormViewModel.viewState.value = ViewState.isLoading);
      return;
    }

    var fetchedSpeakers = await widget.viewmodel.getSpeakersForEventId(
      data.eventId!,
    );
    var fechedTracks = await widget.viewmodel.getTracksByEventId(widget.data!.eventId.toString()) ?? [];
    var fetchedAgendaDays =
        await widget.viewmodel.getAgendaDayByEventId(data.eventId!) ?? [];
    event = await widget.viewmodel.getEventById(data.eventId!);

    setState(() {
      speakers = fetchedSpeakers;
      tracks = fechedTracks;
      agendaDays = fetchedAgendaDays;
    });

    final session = data.session;
    if (session != null) {
      // Editing existing session
      _titleController.text = session.title;

      if (data.agendaDayId != null &&
          agendaDays.map((day) => day.uid).contains(data.agendaDayId)) {
        _selectedDay = data.agendaDayId!;
      }

      if (data.trackId != null &&
          tracks.map((track) => track.uid).contains(data.trackId!)) {
        _selectedTrackUid = data.trackId!;
      }

      final initialSpeaker = speakers.cast<Speaker?>().firstWhere(
        (s) => s?.uid == session.speakerUID,
        orElse: () => null,
      );
      if (initialSpeaker != null) {
        _selectedSpeaker = initialSpeaker;
      }

      if (sessionTypes.contains(session.type)) {
        _selectedTalkType = session.type;
      }

      _descriptionController.text = session.description ?? '';

      if (session.time.isNotEmpty) {
        final parts = session.time.split(' - ');
        if (parts.length == 2) {
          _initSessionTime = TimeUtils.parseTime(parts.first);
          _endSessionTime = TimeUtils.parseTime(parts.last);
        }
      }
    } else {
      // Creating a new session
    }

    setState(() => agendaFormViewModel.viewState.value = ViewState.loadFinished);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    final title = widget.data?.session == null
        ? location.createSession
        : location.editSession;
    return ValueListenableBuilder<ViewState>(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, viewState, child) {
        if (viewState == ViewState.isLoading) {
          return FormScreenWrapper(
            pageTitle: location.loadingTitle,
            widgetFormChild: const Center(child: CircularProgressIndicator()),
          );
        }

        if (viewState == ViewState.error) {
          // Using WidgetsBinding.instance.addPostFrameCallback to show a dialog
          // after the build phase is complete, preventing build-time state changes.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomErrorDialog(
                  errorMessage: location.unexpectedError,
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onRetry: () async {
                    await _loadInitialData();
                  },
                );
              },
            );
          });
        }
        return FormScreenWrapper(
          pageTitle: title,
          widgetFormChild: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.titleHeadingForm),
                  SizedBox(height: _spacing),
                  _buildTitle(),
                  SectionInputForm(
                    label: location.titleLabel,
                    childInput: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      decoration: AppDecorations.textFieldDecoration.copyWith(
                        hintText: location.talkTitleHint,
                      ),
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return location.talkTitleError;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: _spacing),
                  Row(
                    spacing: _spacingForRowDropdown,
                    children: [
                      Expanded(
                        child: SectionInputForm(
                          label: location.eventDayLabel,
                          childInput: DropdownButtonFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _selectedDay.isEmpty
                                ? widget.data?.agendaDayId
                                : _selectedDay,
                            decoration: InputDecoration(
                              hintText: location.selectDayHint,
                            ),
                            items: agendaDays
                                .map(
                                  (day) => DropdownMenuItem(
                                    value: day.uid,
                                    child: Text(day.date),
                                  ),
                                )
                                .toList(),
                            onChanged: (day) => _selectedDay = day ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return location.selectDayError;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SectionInputForm(
                          label: location.roomLabel,
                          childInput: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  initialValue: _selectedTrackUid.isEmpty
                                      ? null
                                      : _selectedTrackUid,
                                  decoration: InputDecoration(
                                    hintText:
                                        location.selectRoomHint, // This is track
                                  ),
                                  items: tracks
                                      .map(
                                        (track) => DropdownMenuItem(
                                          value: track.uid,
                                          child: Text(track.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (trackUid) => setState(
                                      () => _selectedTrackUid = trackUid ?? ''),
                                  validator: (value) {
                                    return value == null || value.isEmpty
                                        ? location.selectRoomError
                                        : null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add,
                                    color: Theme.of(context).primaryColor),
                                onPressed: () => _showAddTrackDialog(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _spacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: _spacingForRowTime,
                        children: [
                          _timeSelector(
                            label: '${location.startTimeLabel}\t\t',
                            currentTime: _initSessionTime,
                            onIndexChanged: (value) {
                              setState(() {
                                _initSessionTime = value;
                              });
                            },
                            isStartTime: true,
                          ),
                          _timeSelector(
                            label: '${location.endTimeLabel}\t\t',
                            currentTime: _endSessionTime,
                            onIndexChanged: (value) {
                              setState(() {
                                _endSessionTime = value;
                              });
                            },
                            isStartTime: false,
                          ),
                        ],
                      ),
                      if (_timeErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _timeErrorMessage!,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 194, 67, 58),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _spacing),
                  Row(
                    spacing: _spacingForRowDropdown,
                    children: [
                      Expanded(
                        child: SectionInputForm(
                          label: location.speakerLabel,
                          childInput: speakers.isEmpty
                              ? Row(
                                  children: [
                                    Text(location.noSpeakersMessage),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () async {
                                        // Allow adding a new speaker
                                        final newSpeaker =
                                            await Navigator.push<Speaker>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SpeakerFormScreen(
                                                      eventUID: widget
                                                          .data!
                                                          .eventId
                                                          .toString(),
                                                    ),
                                              ),
                                            );
                                        if (newSpeaker != null) {
                                          await widget.viewmodel.addSpeaker(
                                            widget.data!.eventId.toString(),
                                            newSpeaker,
                                          );
                                          setState(() {
                                            speakers.add(newSpeaker);
                                            _selectedSpeaker = newSpeaker;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : DropdownButtonFormField<Speaker>(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  initialValue: _selectedSpeaker,
                                  decoration: InputDecoration(
                                    hintText: location.selectSpeakerHint, // Now shows Speaker's name
                                  ),
                                  items: speakers
                                      .map(
                                        (speaker) => DropdownMenuItem<Speaker>(
                                          value:
                                              speaker, // The value is the Speaker object
                                          child: Text(speaker.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (speaker) => setState(() {
                                    _selectedSpeaker = speaker;
                                  }),
                                  validator: (value) {
                                    if (value == null) {
                                      // value is a Speaker object or null
                                      return location.selectSpeakerError;
                                    }
                                    return null;
                                  },
                                ),
                        ),
                      ),
                      Expanded(
                        child: SectionInputForm(
                          label: location.talkTypeLabel,
                          childInput: DropdownButtonFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _selectedTalkType.isEmpty
                                ? null
                                : _selectedTalkType,
                            decoration: InputDecoration(
                              hintText: location.selectTalkTypeHint,
                            ),
                            items: sessionTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (type) => _selectedTalkType = type ?? '',
                            validator: (value) {
                              return value == null || value.isEmpty
                                  ? location.selectTalkTypeError
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _spacing),
                  SectionInputForm(
                    label: location.descriptionLabel,
                    childInput: TextFormField(
                      maxLines: 4,
                      decoration: AppDecorations.textFieldDecoration.copyWith(
                        hintText: location.talkDescriptionHint,
                      ),
                      controller: _descriptionController,
                    ),
                  ),
                  SizedBox(height: _spacing + 10),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    // Title is now at the top of the form
    return const SizedBox.shrink();
  }

  Widget _buildFooter() {
    final location = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(location.cancelButton),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: () async {
            setState(() => _timeErrorMessage = null);
            setState(() => agendaFormViewModel.viewState.value = ViewState.isLoading);
            bool isTimeValid = true;
            if (_initSessionTime == null || _endSessionTime == null) {
              setState(() => agendaFormViewModel.viewState.value = ViewState.error);
              setState(() {
                _timeErrorMessage =
                    location.timeSelectionError;
              });
              isTimeValid = false;
            } else if (!isTimeRangeValid(_initSessionTime, _endSessionTime)) {
              setState(() => agendaFormViewModel.viewState.value = ViewState.error);
              isTimeValid =
                  false; // Error message is already set by the time picker logic
            }

            if (_formKey.currentState!.validate() && isTimeValid) {
              Session session = Session(
                uid:
                    widget.data?.session?.uid ??
                    'Session_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
                title: _titleController.text,
                time:
                    '${_initSessionTime!.format(context)} - ${_endSessionTime!.format(context)}',
                speakerUID: _selectedSpeaker!.uid.toString(),
                description: _descriptionController.text,
                type: _selectedTalkType,
                eventUID: widget.data!.eventId.toString(),
                agendaDayUID: _selectedDay
              );
              var selectedTrack = tracks.firstWhere(
                    (track) => track.uid == _selectedTrackUid,
              );

              await widget.viewmodel.addSession(session, _selectedTrackUid);

              var event = await widget.viewmodel.getEventById(widget.data!.eventId!);


              selectedTrack.eventUid = event!.uid.toString();
              selectedTrack.sessionUids.add(session.uid);
              selectedTrack.resolvedSessions.toList().add(session);
              AgendaDay agendaDay = agendaDays.firstWhere(
                (day) => day.uid == _selectedDay,
              );
              agendaDay.eventUID = event.uid.toString();
              agendaDay.trackUids?.add(selectedTrack.uid);
              agendaDay.resolvedTracks?.toList().add(selectedTrack);
              agendaDays.removeWhere((day) => day.uid == _selectedDay);
              agendaDays.add(agendaDay);
              event.tracks.removeWhere((track) => track.uid == _selectedTrackUid);
              event.tracks.add(selectedTrack);


              debugPrint('Selected track: ${selectedTrack.name}');
              debugPrint('Event uid: ${event.uid}');
              debugPrint('Selected track uid: ${selectedTrack.uid}');
              debugPrint('sessions track: ${selectedTrack.sessionUids}');

              await widget.viewmodel.updateTrack(selectedTrack,agendaDay.uid);
              await widget.viewmodel.updateEvent(event);
              await widget.viewmodel.updateAgendaDay(agendaDay,event.uid.toString());



              setState(() => agendaFormViewModel.viewState.value = ViewState.loadFinished);
              if (mounted) {
                Navigator.pop(
                  context,
                  agendaDays.where((day) => day.trackUids != null && day.trackUids!.isNotEmpty).toList(),
                ); // Return true to indicate success
              }
            }
          },
          child: Text(location.saveButton),
        ),
      ],
    );
  }

  Widget _timeSelector({
    required String label,
    required TimeOfDay? currentTime,
    required ValueChanged<TimeOfDay> onIndexChanged,
    required bool isStartTime,
  }) {
    final location = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: currentTime ?? TimeOfDay.now(),
            );

            if (pickedTime != null) {
              onIndexChanged(pickedTime);

              final newStartTime = isStartTime ? pickedTime : _initSessionTime;
              final newEndTime = isStartTime ? _endSessionTime : pickedTime;

              if (newStartTime != null && newEndTime != null) {
                bool isValid = isTimeRangeValid(newStartTime, newEndTime);

                setState(() {
                  // Set error message for time range validation
                  _timeErrorMessage = isValid
                      ? null
                      : location.timeValidationError;
                });
              } else {
                // Clear message if one of the times is not set yet
                setState(() {
                  _timeErrorMessage = null;
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(currentTime?.format(context) ?? '00:00'),
          ),
        ),
      ],
    );
  }

  bool isTimeRangeValid(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return false;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return startMinutes < endMinutes;
  }

  bool isTimeSelected(TimeOfDay? time) {
    return time != null; // Simpler check
  }

  void _showAddTrackDialog() {
    final location = AppLocalizations.of(context)!;
    final TextEditingController trackNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location.addRoomTitle),
          content: TextFormField(
            controller: trackNameController,
            autofocus: true,
            decoration: InputDecoration(hintText: location.roomNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(location.cancelButton),
            ),
            FilledButton(
              onPressed: () async {
                if (trackNameController.text.isNotEmpty) {
                  final String newTrackName = trackNameController.text;
                  final String newTrackUid = 'Track_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

                  final newTrack = Track(
                    uid: newTrackUid,
                    name: newTrackName,
                    sessionUids: [],
                    eventUid: widget.data!.eventId!,
                    resolvedSessions: [],
                    color: '',
                  );

                  setState(() {
                    tracks.add(newTrack);
                    _selectedTrackUid = newTrack.uid;
                  });
                  await widget.viewmodel.addTrack(newTrack,_selectedDay);
                  if(context.mounted){
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(location.addButton),
            ),
          ],
        );
      },
    );
  }
}
