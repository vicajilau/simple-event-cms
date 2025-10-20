import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/core/utils/app_fonts.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/time_utils.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../speaker/speaker_form_screen.dart';

class AgendaFormData {
  final String? track, day, eventId;
  final Session? session;

  AgendaFormData({this.session, this.track, this.day, required this.eventId});
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
    var fechedTracks = await widget.viewmodel.getTracks() ?? [];
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

      if (data.day != null &&
          agendaDays.map((day) => day.uid).contains(data.day)) {
        _selectedDay = data.day!;
      }

      if (data.track != null &&
          tracks.map((track) => track.uid).contains(data.track!)) {
        _selectedTrackUid = data.track!;
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
    final title = widget.data?.session == null
        ? 'Crear Sesión'
        : 'Editar Sesión';
    return ValueListenableBuilder<ViewState>(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, viewState, child) {
        if (viewState == ViewState.isLoading) {
          return const FormScreenWrapper(
            pageTitle: 'Cargando...',
            widgetFormChild: Center(child: CircularProgressIndicator()),
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
                  errorMessage: 'Ha ocurrido un error inesperado.',
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
                    label: 'Título*',
                    childInput: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      decoration: AppDecorations.textFieldDecoration.copyWith(
                        hintText: 'Introduce título de la charla',
                      ),
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un título de la charla';
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
                          label: 'Día del evento*',
                          childInput: DropdownButtonFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _selectedDay.isEmpty
                                ? null
                                : _selectedDay,
                            decoration: const InputDecoration(
                              hintText: 'Selecciona un día',
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
                                return 'Por favor, selecciona un día';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SectionInputForm(
                          label: 'Sala*',
                          childInput: DropdownButtonFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _selectedTrackUid.isEmpty
                                ? null
                                : _selectedTrackUid,
                            decoration: const InputDecoration(
                              hintText: 'Selecciona una sala', // This is track
                            ),
                            items: tracks
                                .map(
                                  (track) => DropdownMenuItem(
                                    value: track.uid,
                                    child: Text(track.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (trackUid) =>
                                _selectedTrackUid = trackUid ?? '',
                            validator: (value) {
                              return value == null || value.isEmpty
                                  ? 'Por favor, selecciona una sala'
                                  : null;
                            },
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
                            label: 'Hora de inicio:\t\t',
                            currentTime: _initSessionTime,
                            onIndexChanged: (value) {
                              setState(() {
                                _initSessionTime = value;
                              });
                            },
                            isStartTime: true,
                          ),
                          _timeSelector(
                            label: 'Hora final:\t\t',
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
                          label: 'Speaker*',
                          childInput: speakers.isEmpty
                              ? Row(
                                  children: [
                                    const Text('No hay speakers. Añade uno.'),
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
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Selecciona un speaker', // Now shows Speaker's name
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
                                      return 'Por favor, selecciona un speaker';
                                    }
                                    return null;
                                  },
                                ),
                        ),
                      ),
                      Expanded(
                        child: SectionInputForm(
                          label: 'Tipo de charla*',
                          childInput: DropdownButtonFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _selectedTalkType.isEmpty
                                ? null
                                : _selectedTalkType,
                            decoration: const InputDecoration(
                              hintText: 'Selecciona el tipo de charla',
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
                                  ? 'Por favor, selecciona el tipo de charla'
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _spacing),
                  SectionInputForm(
                    label: 'Descripción',
                    childInput: TextFormField(
                      maxLines: 4,
                      decoration: AppDecorations.textFieldDecoration.copyWith(
                        hintText: 'Introduce descripción de la charla...',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
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
                    'Por favor, seleccionar ambas horas: inicio y final.';
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
              );
              var selectedTrack = tracks.firstWhere(
                    (track) => track.uid == _selectedTrackUid,
              );
              await widget.viewmodel.addSession(session, _selectedTrackUid);

              var event = await widget.viewmodel.getEventById(widget.data!.eventId!);


              selectedTrack.eventUid = event!.uid.toString();
              selectedTrack.sessionUids.add(session.uid);
              AgendaDay agendaDay = agendaDays.firstWhere(
                (day) => day.uid == _selectedDay,
              );
              agendaDay.eventUID = event.uid.toString();
              agendaDay.trackUids?.add(selectedTrack.uid);


              debugPrint('Selected track: ${selectedTrack.name}');
              debugPrint('Event uid: ${event.uid}');
              debugPrint('Selected track uid: ${selectedTrack.uid}');
              debugPrint('sessions track: ${selectedTrack.sessionUids}');

              await widget.viewmodel.updateTrack(selectedTrack,event.uid.toString());
              await widget.viewmodel.updateEvent(event);
              await widget.viewmodel.updateAgendaDay(agendaDay,event.uid.toString());
              agendaDays.removeWhere((day) => day.uid == _selectedDay);
              agendaDays.add(agendaDay);
              event.tracks.removeWhere((track) => track.uid == _selectedTrackUid);
              event.tracks.add(selectedTrack);


              setState(() => agendaFormViewModel.viewState.value = ViewState.loadFinished);
              if (mounted) {
                Navigator.pop(
                  context,
                  agendaDays.where((day) => day.trackUids != null && day.trackUids!.isNotEmpty).toList(),
                ); // Return true to indicate success
              }
            }
          },
          child: const Text('Guardar'),
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
                      : 'La hora de inicio debe ser anterior a la hora final.';
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
}
