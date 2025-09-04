import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/core.dart';

import '../widgets/widgets.dart';

class EventFormScreen extends StatefulWidget {
  final List<String> rooms;
  final List<String> days;
  final List<String> speakers;
  final List<String> talkTypes;

  const EventFormScreen({
    super.key,
    required this.days,
    required this.rooms,
    required this.speakers,
    required this.talkTypes,
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FormScreenWrapper(
      pageTitle: 'Creación evento',
      widgetFormChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              _buildTitle(),
              SectionInputForm(
                label: 'Título',
                childInput: TextFormField(
                  maxLines: 1,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
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
              SectionInputForm(
                label: 'Dia del evento',
                childInput: DropdownButton<String>(
                  value: _selectedDay.isEmpty ? null : _selectedDay,
                  hint: Text('Selecciona un día'),
                  items: widget.days
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
              Row(
                spacing: 12,
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
                ],
              ),
              SectionInputForm(
                label: 'Spekaer',
                childInput: DropdownButton<String>(
                  value: _selectedSpeaker.isEmpty ? null : _selectedSpeaker,
                  hint: Text('Selecciona un speaker'),
                  items: widget.speakers
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
                label: 'Tipo de charla',
                childInput: TextFormField(
                  maxLines: 4,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: 'Selecciona el tipo de charla',
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
              SectionInputForm(
                label: 'Tipo de charla',
                childInput: DropdownButton<String>(
                  value: _selectedTalkType.isEmpty ? null : _selectedTalkType,
                  hint: Text('Selecciona el tipo de charla'),
                  items: widget.talkTypes
                      .map(
                        (String talkType) => DropdownMenuItem<String>(
                          value: talkType,
                          child: Text(talkType),
                        ),
                      )
                      .toList(),
                  onChanged: (String? talkType) {
                    setState(() {
                      _selectedTalkType = talkType ?? '';
                    });
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
            Session session = Session(
              title: _title,
              time: '08:30 - 09:00',
              speaker: _selectedSpeaker,
              description: _description,
              type: _selectedTalkType,
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
  }) {
    return Row(
      spacing: 12,
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
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null && pickedTime != _initSessionTime) {
              onIndexChanged(pickedTime);
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
}
