import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/core.dart';

import '../widgets/widgets.dart';

class EventFormScreen extends StatefulWidget {
  final List<String> rooms;
  final List<String> days;
  final List<String> speakers;
  final List<String> sessionTypes;
  final Session? data;

  const EventFormScreen({
    super.key,
    required this.days,
    required this.rooms,
    required this.speakers,
    required this.sessionTypes,
    required this.data,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  TimeOfDay? _initSessionTime, _endSessionTime;
  String _selectedDay = '',
      _selectedRoom = '',
      _title = '',
      _selectedSpeaker = '',
      _description = '',
      _selectedTalkType = '';
  final double spacingForRowDropdown = 40, spacingForRowTime = 40;
  final _formKey = GlobalKey<FormState>();
  String? _timeErrorMessage;

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
                label: '*Título',
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
                children: [
                  Expanded(
                    child: SectionInputForm(
                      label: '*Día del evento',
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
                        onChanged: (day) =>
                            setState(() => _selectedDay = day ?? ''),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecciona un día';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: spacingForRowDropdown),
                  Expanded(
                    child: SectionInputForm(
                      label: '*Sala',
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
                        onChanged: (room) =>
                            setState(() => _selectedRoom = room ?? ''),
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
                        label: '*Hora de inicio:\t\t',
                        currentTime: _initSessionTime,
                        onIndexChanged: (value) {
                          setState(() {
                            _initSessionTime = value;
                          });
                        },
                        isStartTime: true,
                      ),
                      _timeSelector(
                        label: '*Hora final:\t\t',
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
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SectionInputForm(
                      label: '*Speaker',
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
                            setState(() => _selectedSpeaker = speaker ?? ''),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecciona un speaker';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: spacingForRowDropdown),
                  Expanded(
                    child: SectionInputForm(
                      label: '*Tipo de charla',
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
                        onChanged: (type) =>
                            setState(() => _selectedTalkType = type ?? ''),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'La hora de inicio debe ser anterior a la hora final',
                    ),
                  ),
                );
                return;
              }
              Session session = Session(
                title: _title,
                time:
                    '${_initSessionTime!.format(context)} - ${_endSessionTime!.format(context)}',
                speaker: _selectedSpeaker,
                description: _description,
                type: _selectedTalkType,
                uid: DateTime.now().toString(),
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
}
