import 'package:flutter/material.dart';

class EventFormDialog extends StatefulWidget {
  final List<String> rooms;
  final List<String> days;
  final List<String> speakers;
  final List<String> talkTypes;

  const EventFormDialog({
    super.key,
    required this.days,
    required this.rooms,
    required this.speakers,
    required this.talkTypes,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  TimeOfDay? _initSessionTime, _endSessionTime;
  String _selectedDay = '',
      _selectedRoom = '',
      _selectedSpeaker = '',
      _description = '',
      _selectedTalkType = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectTime(BuildContext context, {required bool isInit}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _initSessionTime) {
      setState(() {
        if (isInit == true) {
          _initSessionTime = pickedTime;
        } else {
          _endSessionTime = pickedTime;
        }
      });
    }
  }

  InputDecoration commonInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _timeWidget(
    String labelText, {
    required ValueChanged<TimeOfDay> onSelectedTime,
  }) {
    return Row(
      children: [
        Text(
          labelText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            _selectTime(context, isInit: true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_initSessionTime?.format(context) ?? '00:00'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _buildTitle(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Título'),
              TextFormField(
                maxLines: 1,
                decoration: commonInputDecoration(
                  'Introduce título de la charla',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre';
                  }
                  return null;
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dia del evento'),
              DropdownButton<String>(
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
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Text(
                'Hora de inicio:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  _selectTime(context, isInit: true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_initSessionTime?.format(context) ?? '00:00'),
                ),
              ),
              Text('Hora final:'),
              GestureDetector(
                onTap: () {
                  _selectTime(context, isInit: false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_endSessionTime?.format(context) ?? '00:00'),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Spekaer'),
              DropdownButton<String>(
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
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description'),
              TextFormField(
                maxLines: 4,
                decoration: commonInputDecoration(
                  'Introduce una descripción de la charla...',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre';
                  }
                  return null;
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de charla'),
              DropdownButton<String>(
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
            ],
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Creando evento',
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [FilledButton(onPressed: () {}, child: const Text('Guardar'))],
    );
  }
}
