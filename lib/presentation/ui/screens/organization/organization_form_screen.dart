import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

class OrganizationFormScreen extends StatefulWidget {
  final Event? event;
  const OrganizationFormScreen({super.key, this.event});

  @override
  State<OrganizationFormScreen> createState() => _OrganizationFormScreenState();
}

class _OrganizationFormScreenState extends State<OrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _primaryColorController = TextEditingController();
  final TextEditingController _secondaryColorController = TextEditingController();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueCityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _agendaUIDController = TextEditingController();
  final TextEditingController _speakersUIDController = TextEditingController();
  final TextEditingController _sponsorsUIDController = TextEditingController();

  bool _hasEndDate = true;
  List<String> _rooms = [];
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.event?.eventName ?? '';

    final startDate = widget.event?.eventDates?.startDate;
    if (startDate != null) {
      _startDateController.text = startDate;
    }

    final endtDate = widget.event?.eventDates?.endDate;
    _hasEndDate = startDate != endtDate;
    if (endtDate != null && _hasEndDate) {
      _endDateController.text = endtDate;
    }

    _rooms = widget.event?.rooms ?? [];
    _timezoneController.text = widget.event?.eventDates?.timezone ?? 'Europe/Madrid';
    _baseUrlController.text = widget.event?.baseUrl ?? '';
    _primaryColorController.text = widget.event?.primaryColor ?? '';
    _secondaryColorController.text = widget.event?.secondaryColor ?? '';
    _venueNameController.text = widget.event?.venue?.name ?? '';
    _venueAddressController.text = widget.event?.venue?.address ?? '';
    _venueCityController.text = widget.event?.venue?.city ?? '';
    _descriptionController.text = widget.event?.description ?? '';
    _agendaUIDController.text = widget.event?.agendaUID ?? '';
    _speakersUIDController.text =
        widget.event?.speakersUID.join(', ') ?? '';
    _sponsorsUIDController.text =
        widget.event?.sponsorsUID.join(', ') ?? '';
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toIso8601String().split("T").first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenWrapper(
      pageTitle: 'Creación evento',
      widgetFormChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text('Creando evento', style: AppFonts.titleHeadingForm),

            SectionInputForm(
              label: 'Nombre del evento',
              childInput: TextFormField(
                controller: _nameController,
                maxLines: 1,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce el nombre del evento',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Campo requerido' : null,
              ),
            ),

            SectionInputForm(
              label: 'Fecha inicio',
              childInput: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: AppDecorations.textFieldDecoration.copyWith(
                        hintText: 'YYYY-MM-DD',
                      ),
                      onTap: () => _selectDate(context, _startDateController),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo requerido'
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            if (_hasEndDate)
              SectionInputForm(
                label: 'Fecha fin',
                childInput: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: AppDecorations.textFieldDecoration.copyWith(
                          hintText: 'YYYY-MM-DD',
                        ),
                        onTap: () => _selectDate(context, _endDateController),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _hasEndDate = false;
                          _endDateController.clear();
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasEndDate = true;
                    });
                  },
                  child: Text(
                    'Añadir fecha de fin',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            SectionInputForm(
              label: 'Salas',
              childInput: SizedBox(
                height: 200,
                child: AddRoom(
                  rooms: _rooms,
                  editedRooms: (List<String> currentRooms) {
                    _rooms = currentRooms;
                  },
                ),
              ),
            ),

            SectionInputForm(
              label: 'Timezone',
              childInput: TextFormField(
                controller: _timezoneController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce el timezone',
                ),
              ),
            ),

            SectionInputForm(
              label: 'Base URL',
              childInput: TextFormField(
                controller: _baseUrlController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce la Base URL',
                ),
              ),
            ),

            SectionInputForm(
              label: 'Color Primario',
              childInput: TextFormField(
                controller: _primaryColorController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce el color primario (ej. #FFFFFF)',
                ),
              ),
            ),

            SectionInputForm(
              label: 'Color Secundario',
              childInput: TextFormField(
                controller: _secondaryColorController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce el color secundario (ej. #000000)',
                ),
              ),
            ),

            Text('Venue', style: AppFonts.titleHeadingForm),
            SectionInputForm(
              label: 'Nombre del Venue',
              childInput: TextFormField(
                controller: _venueNameController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce el nombre del venue',
                ),
              ),
            ),
            SectionInputForm(
              label: 'Dirección del Venue',
              childInput: TextFormField(
                controller: _venueAddressController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce la dirección del venue',
                ),
              ),
            ),
            SectionInputForm(
              label: 'Ciudad del Venue',
              childInput: TextFormField(
                controller: _venueCityController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce la ciudad del venue',
                ),
              ),
            ),

            SectionInputForm(
              label: 'Descripción',
              childInput: TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: 'Introduce la descripción del evento',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: _onSubmit,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final eventDates = EventDates(
      startDate: _startDateController.text,
      endDate: _hasEndDate && _endDateController.text.isNotEmpty
          ? _endDateController.text
          : _startDateController.text,
      timezone: _timezoneController.text.isNotEmpty
          ? _timezoneController.text
          : 'Europe/Madrid',
    );

    final event = Event(
      uid: widget.event?.uid ?? DateTime.now().toString(),
      eventName: _nameController.text,
      rooms: _rooms.isEmpty ? ['Sala Principal'] : _rooms,
      year: eventDates.startDate.split('-').first,
      baseUrl: _baseUrlController.text,
      primaryColor: _primaryColorController.text,
      secondaryColor: _secondaryColorController.text,
      eventDates: eventDates,
      venue: Venue(
        name: _venueNameController.text,
        address: _venueAddressController.text,
        city: _venueCityController.text,
      ),
      description: _descriptionController.text,
      agendaUID: "agenda123",
      speakersUID: ["speaker123"],
      sponsorsUID: ["sponsor123"],
    );
    Navigator.pop(context, event);
  }
}
