import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/core.dart';
import 'package:sec/ui/widgets/add_room.dart';

import '../widgets/widgets.dart';

class OrganizationFormScreen extends StatefulWidget {
  final SiteConfig? siteConfig;
  const OrganizationFormScreen({super.key, this.siteConfig});

  @override
  State<OrganizationFormScreen> createState() => _OrganizationFormScreenState();
}

class _OrganizationFormScreenState extends State<OrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _hasEndDate = true;
  List<String> _rooms = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.siteConfig?.eventName ?? '';

    final startDate = widget.siteConfig?.eventDates?.startDate;
    if (startDate != null) {
      _startDateController.text = startDate;
    }

    final endtDate = widget.siteConfig?.eventDates?.endDate;
    _hasEndDate = startDate != endtDate;
    if (endtDate != null && _hasEndDate) {
      _endDateController.text = endtDate;
    }

    _rooms = widget.siteConfig?.rooms ?? [];
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
      pageTitle: 'Creación organización',
      widgetFormChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text('Creando organización', style: AppFonts.titleHeadingForm),

            SectionInputForm(
              label: 'Nombre del evento',
              childInput: TextFormField(
                controller: _nameController,
                maxLines: 1,
                decoration: AppDecorations.textfieldDecoration.copyWith(
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
                      decoration: AppDecorations.textfieldDecoration.copyWith(
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
                        decoration: AppDecorations.textfieldDecoration.copyWith(
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final eventDates = EventDates(
      startDate: _startDateController.text,
      endDate: _hasEndDate && _endDateController.text.isNotEmpty
          ? _endDateController.text
          : _startDateController.text,
      timezone: 'Europe/Madrid',
    );

    final siteConfig = SiteConfig(
      uid: widget.siteConfig?.uid ?? DateTime.now().toString(),
      eventName: _nameController.text,
      rooms: _rooms.isEmpty ? ['Sala Principal'] : _rooms,
      year: eventDates.startDate.split('-').first,
      baseUrl: "https://hardcode.base.url",
      primaryColor: "#4285F4",
      secondaryColor: "#34A853",
      eventDates: eventDates,
      venue: Venue(
        name: "Hardcode Venue",
        address: "Dirección hardcodeada",
        city: 'ciudad hardcodeada',
      ),
      description: "Descripción hardcodeada",
      agendaUID: "agenda123",
      speakersUID: ["speaker123"],
      sponsorsUID: ["sponsor123"],
    );

    Navigator.pop(context, siteConfig);
  }
}
