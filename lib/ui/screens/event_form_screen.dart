import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/core.dart';

import '../../core/utils/time_utils.dart';
import '../widgets/widgets.dart';

class EventFormData {
  final List<String> rooms;
  final List<String> days;
  final List<String> speakers;
  final List<String> sessionTypes;
  final String track, day;
  final Session? session;

  EventFormData({
    required this.rooms,
    required this.days,
    required this.speakers,
    required this.sessionTypes,
    required this.session,
    required this.track,
    required this.day,
  });
}

class EventFormScreen extends StatefulWidget {
  final EventFormData data;

  const EventFormScreen({super.key, required this.data});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  TimeOfDay? _initSessionTime, _endSessionTime;
  String _selectedDay = '',
      _selectedRoom = '',
      _selectedSpeaker = '',
      _selectedSessionType = '';
  final double spacingForRowDropdown = 60, spacingForRowTime = 20;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

      _description = '',
      _selectedTalkType = '';
  final double spacingForRowDropdown = 40, spacingForRowTime = 40;
  final _formKey = GlobalKey<FormState>();
  String? _timeErrorMessage;

  @override
  void initState() {
    super.initState();
    final session = widget.data.session;
    if (session != null) {
      _titleController.text = session.title;

      if (widget.data.days.contains(widget.data.day)) {
        _selectedDay = widget.data.day;
      }

      if (widget.data.track.contains(widget.data.track)) {
        _selectedRoom = widget.data.track;
      }

      if (widget.data.speakers.contains(session.speaker)) {
        _selectedSpeaker = session.speaker;
      }

      if (widget.data.sessionTypes.contains(session.type.toUpperCase())) {
        _selectedSessionType = session.type;
      }

      _descriptionController.text = session.description;

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
                  onChanged: (value) => _title = value,
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
                        items: widget.days
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text(day),
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
                        initialValue: _selectedRoom.isEmpty
                            ? null
                            : _selectedRoom,
                        decoration: InputDecoration(
                          hintText: 'Selecciona una sala',
                        ),
                        items: widget.rooms
                            .map(
                              (room) => DropdownMenuItem(
                                value: room,
                                child: Text(room),
                              ),
                            )
                            .toList(),
                        onChanged: (room) => _selectedRoom = room ?? '',
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
      widgetFormChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildTitle(),
            SectionInputForm(
              label: 'Título*',
              childInput: TextFormField(
                maxLines: 1,
                controller: _titleController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce título de la charla',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre';
                  }
                  return null;
                },
              ),
            ),
            Row(
              spacing: spacingForRowDropdown,
              children: [
                SectionInputForm(
                  label: 'Dia del evento*',
                  childInput: DropdownButton<String>(
                    value: _selectedDay.isEmpty ? null : _selectedDay,
                    hint: Text('Selecciona un día'),
                    items: widget.data.days
                        .map(
                          (String day) => DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          ),
                        )
                        .toList(),
                    onChanged: (String? day) {
                      setState(() {
                        _selectedDay = day ?? '';
                      });
                    },
                  ),
                ),
                SectionInputForm(
                  label: 'Sala*',
                  childInput: DropdownButton<String>(
                    value: _selectedRoom.isEmpty ? null : _selectedRoom,
                    hint: Text('Selecciona una sala'),
                    items: widget.data.rooms
                        .map(
                          (String room) => DropdownMenuItem<String>(
                            value: room,
                            child: Text(room),
                          ),
                        )
                        .toList(),
                    onChanged: (String? room) {
                      setState(() {
                        _selectedRoom = room ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            SectionInputForm(
              label: 'Hora*',
              childInput: Row(
                spacing: spacingForRowTime,
                children: [
                  _timeSelector(
                    label: 'Hora de inicio:',
                    currentTime: _initSessionTime,
                    onIndexChanged: (value) {
                      setState(() {
                        _initSessionTime = value;
                      });
                    },
                  ),
                  _timeSelector(
                    label: 'Hora final:',
                    currentTime: _endSessionTime,
                    onIndexChanged: (value) {
                      setState(() {
                        _endSessionTime = value;
                      });
                    },
                  ),
                  if (_timeErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _timeErrorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              spacing: spacingForRowDropdown,
              children: [
                SectionInputForm(
                  label: 'Spekaer*',
                  childInput: DropdownButton<String>(
                    value: _selectedSpeaker.isEmpty ? null : _selectedSpeaker,
                    hint: Text('Selecciona un speaker'),
                    items: widget.data.speakers
                        .map(
                          (String speaker) => DropdownMenuItem<String>(
                            value: speaker,
                            child: Text(speaker),
                          ),
                        )
                        .toList(),
                    onChanged: (String? speaker) {
                      setState(() {
                        _selectedSpeaker = speaker ?? '';
                      });
                    },
                  ),
                ),
                SectionInputForm(
                  label: 'Tipo de charla*',
                  childInput: DropdownButton<String>(
                    value: _selectedSessionType.isEmpty
                        ? null
                        : _selectedSessionType,
                    hint: Text('Selecciona el tipo de charla'),
                    items: widget.data.sessionTypes
                        .map(
                          (String talkType) => DropdownMenuItem<String>(
                            value: talkType,
                            child: Text(talkType),
                          ),
                        )
                        .toList(),
                    onChanged: (String? talkType) {
                      setState(() {
                        _selectedSessionType = talkType ?? '';
                      });
                    },
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
                onChanged: (value) {
                  _descriptionController.text = value;
                },
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre';
                  }
                  return null;
                },
              ),
            ),
            _buildFooter(),
          ],
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
                        items: widget.speakers
                            .map(
                              (speaker) => DropdownMenuItem(
                                value: speaker,
                                child: Text(speaker),
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
                        items: widget.sessionTypes
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
                  onChanged: (value) {
                    _description = value;
                  },
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (!isTimeRangeValid(_initSessionTime, _endSessionTime)) {
                return;
              }
            final initTime = _initSessionTime?.format(context) ?? '00:00';
            final finalTime = _endSessionTime?.format(context) ?? '00:00';
            Session session = Session(
              title: _titleController.text,
              time: '$initTime - $finalTime',
              speaker: _selectedSpeaker,
              description: _descriptionController.text,
              type: _selectedSessionType,
              uid: widget.data.session?.uid ?? DateTime.now().toString(),
            );
            Track track = Track(
              name: _selectedRoom,
              color: '',
              sessions: [session],
            );
            AgendaDay agendaDay = AgendaDay(
              date: _selectedDay,
              tracks: [track],
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
      spacing: 12,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
}
