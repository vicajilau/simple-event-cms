import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/time_utils.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

class AgendaFormData {
  final String eventId;
  final String? track, day;
  final Session? session;

  AgendaFormData({required this.eventId, this.session, this.track, this.day});
}

class AgendaFormScreen extends StatefulWidget {
  final AgendaFormData data;

  const AgendaFormScreen({super.key, required this.data});

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  TimeOfDay? _initSessionTime, _endSessionTime;
  String _selectedDay = '',
      _selectedTrack = '',
      _selectedSpeaker = '',
      _selectedTalkType = '';
  final double spacingForRowDropdown = 40, spacingForRowTime = 40;
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
    var event = await agendaFormViewModel.loadEvent(widget.data.eventId);
    var agenda = await agendaFormViewModel.getAgenda(event!.agendaUID.toString());
    setState(() {
      agendaDays = agenda?.resolvedDays ?? [];
      tracks = ((agenda?.resolvedDays?..expand((day) => day.resolvedTracks ?? [])) ?? []).cast<Track>();
      speakers = tracks.expand((track) => track.resolvedSessions ?? []).toList().cast<Speaker>();
    });

    final session = widget.data.session;
    if (session != null) {
      _titleController.text = session.title;

      if (widget.data.day != null &&
          agendaDays.map((day) => day.uid).contains(widget.data.day)) {
        _selectedDay = widget.data.day!;
      }

      if (widget.data.track != null &&
          tracks.map((track) => track.uid).contains(widget.data.track!)) {
        _selectedTrack = widget.data.track!;
      }

      if (speakers.map((speaker) => speaker.uid).contains(session.speaker)) {
        _selectedSpeaker = session.speaker.toString();
      }

      if (sessionTypes.contains(session.type.toUpperCase())) {
        _selectedTalkType = session.type;
      }

      _descriptionController.text = session.description ?? '';

      final parts = session.time.split(' - ');
      _initSessionTime = TimeUtils.parseTime(parts.first);
      _endSessionTime = TimeUtils.parseTime(parts.last);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _loadInitialData(), builder: (BuildContext context, AsyncSnapshot snapshot) {
      return FormScreenWrapper(
        pageTitle: 'Creación evento',
        widgetFormChild: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
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
                Row(
                  spacing: spacingForRowDropdown,
                  children: [
                    Expanded(
                      child: SectionInputForm(
                        label: 'Día del evento*',
                        childInput: DropdownButtonFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _selectedDay.isEmpty
                              ? null
                              : _selectedDay,
                          decoration: InputDecoration(
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _selectedTrack.isEmpty
                              ? null
                              : _selectedTrack,
                          decoration: InputDecoration(
                            hintText: 'Selecciona una sala',
                          ),
                          items: tracks
                              .map(
                                (track) => DropdownMenuItem(
                              value: track.uid,
                              child: Text(track.name),
                            ),
                          )
                              .toList(),
                          onChanged: (room) => _selectedTrack = room ?? '',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: spacingForRowTime,
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
                Row(
                  spacing: spacingForRowDropdown,
                  children: [
                    Expanded(
                      child: SectionInputForm(
                        label: 'Speaker*',
                        childInput: DropdownButtonFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _selectedSpeaker.isEmpty
                              ? null
                              : _selectedSpeaker,
                          decoration: InputDecoration(
                            hintText: 'Selecciona un speaker',
                          ),
                          items: speakers
                              .map(
                                (speaker) => DropdownMenuItem(
                              value: speaker.uid,
                              child: Text(speaker.name),
                            ),
                          )
                              .toList(),
                          onChanged: (speaker) =>
                          _selectedSpeaker = speaker ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _selectedTalkType.isEmpty
                              ? null
                              : _selectedTalkType,
                          decoration: InputDecoration(
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
                SectionInputForm(
                  label: 'Descripción',
                  childInput: TextFormField(
                    maxLines: 4,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: 'Introduce la descripción...',
                    ),
                    controller: _descriptionController,
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      );
    }
    );
    /*);
 );*/
  }

  Widget _buildTitle() {
    return Text('Creando evento', style: AppFonts.titleHeadingForm);
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton(
          onPressed: () async {
            if (!isTimeSelected(_initSessionTime) ||
                !isTimeSelected(_endSessionTime)) {
              setState(() {
                _timeErrorMessage =
                    'Por favor, seleccionar ambas horas: inicio y final.';
              });
            }
            if (_formKey.currentState!.validate()) {
              if (!isTimeRangeValid(_initSessionTime, _endSessionTime)) {
                return;
              }
              Session session = Session(
                title: _titleController.text,
                time:
                    '${_initSessionTime!.format(context)} - ${_endSessionTime!.format(context)}',
                speaker: _selectedSpeaker,
                description: _descriptionController.text,
                type: _selectedTalkType,
                uid:
                    'Session_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
              );
              Track track = Track(
                uid:
                    'Track_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
                name: _selectedTrack,
                color: '',
                resolvedSessions: [session],
                sessionUids: [session.uid],
              );
              AgendaDay agendaDay = AgendaDay(
                uid:
                    'AgendaDay_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
                date: _selectedDay,
                resolvedTracks: [track],
                trackUids: [track.uid],
              );
              Navigator.pop(context, agendaDay);
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
                  _timeErrorMessage = isValid
                      ? null
                      : (isStartTime
                            ? 'La hora de inicio debe ser antes que la hora final.'
                            : 'La hora final debe ser después de la hora de inicio.');
                });
              } else {
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
    return time != null && !(time.hour == 0 && time.minute == 0);
  }
}
