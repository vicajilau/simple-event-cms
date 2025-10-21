import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/core/utils/app_fonts.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/organization/event_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

class EventFormScreen extends StatefulWidget {
  final EventCollectionViewModel eventCollectionViewModel =
      getIt<EventCollectionViewModel>();
  final String? eventId;
  EventFormScreen({super.key, this.eventId});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  Future<Event?>? _eventFuture;
  final _formKey = GlobalKey<FormState>();

  final eventFormViewModel = getIt<EventFormViewModel>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _primaryColorController = TextEditingController();
  final TextEditingController _secondaryColorController =
      TextEditingController();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueCityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _hasEndDate = true;
  List<Track> _tracks = [];
  Event? event;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _eventFuture = widget.eventCollectionViewModel.getEventById(
        widget.eventId!,
      );
    }
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
    final location = AppLocalizations.of(context)!;
    return FutureBuilder<Event?>(
      future: _eventFuture,
      builder: (context, snapshot) {
        if (widget.eventId != null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('${location.errorPrefix}${snapshot.error}')),
            );
          }

          event = snapshot.data;
          _nameController.text = event?.eventName ?? '';
          final startDate = event?.eventDates.startDate;
          if (startDate != null) {
            _startDateController.text = startDate;
          }
          final endDate = event?.eventDates.endDate;
          _hasEndDate = startDate != endDate;
          if (endDate != null && _hasEndDate) {
            _endDateController.text = endDate;
          }
          _tracks = event?.tracks ?? [];
          _timezoneController.text =
              event?.eventDates.timezone ?? 'Europe/Madrid';
          _primaryColorController.text = event?.primaryColor ?? '';
          _secondaryColorController.text = event?.secondaryColor ?? '';
          _venueNameController.text = event?.venue?.name ?? '';
          _venueAddressController.text = event?.venue?.address ?? '';
          _venueCityController.text = event?.venue?.city ?? '';
          _descriptionController.text = event?.description ?? '';
        }
        return FormScreenWrapper(
          pageTitle:
              widget.eventId != null ? location.editEventTitle : location.createEventTitle,
          widgetFormChild: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  widget.eventId != null ? location.editingEvent : location.creatingEvent,
                  style: AppFonts.titleHeadingForm,
                ),
                SectionInputForm(
                  label: location.eventNameLabel,
                  childInput: TextFormField(
                    controller: _nameController,
                    maxLines: 1,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.eventNameHint,
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? location.requiredField
                        : null,
                  ),
                ),
                SectionInputForm(
                  label: location.startDateLabel,
                  childInput: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateController,
                          readOnly: true,
                          decoration: AppDecorations.textFieldDecoration
                              .copyWith(hintText: location.dateHint),
                          onTap: () =>
                              _selectDate(context, _startDateController),
                          validator: (value) => (value == null || value.isEmpty)
                              ? location.requiredField
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasEndDate)
                  SectionInputForm(
                    label: location.endDateLabel,
                    childInput: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            decoration: AppDecorations.textFieldDecoration
                                .copyWith(hintText: location.dateHint),
                            onTap: () =>
                                _selectDate(context, _endDateController),
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
                        location.addEndDate,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                SectionInputForm(
                  label: location.roomsLabel,
                  childInput: SizedBox(
                    height: 200,
                    child: AddRoom(
                      rooms: _tracks.toList(),
                      editedRooms: (List<Track> currentRooms) {
                        _tracks = currentRooms;
                      },
                      eventUid: widget.eventId.toString(),
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.timezoneLabel,
                  childInput: TextFormField(
                    controller: _timezoneController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.timezoneHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.baseUrlLabel,
                  childInput: TextFormField(
                    controller: _baseUrlController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.baseUrlHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.primaryColorLabel,
                  childInput: TextFormField(
                    controller: _primaryColorController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.primaryColorHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.secondaryColorLabel,
                  childInput: TextFormField(
                    controller: _secondaryColorController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.secondaryColorHint,
                    ),
                  ),
                ),
                Text(location.venueTitle, style: AppFonts.titleHeadingForm),
                SectionInputForm(
                  label: location.venueNameLabel,
                  childInput: TextFormField(
                    controller: _venueNameController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueNameHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.venueAddressLabel,
                  childInput: TextFormField(
                    controller: _venueAddressController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueAddressHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.venueCityLabel,
                  childInput: TextFormField(
                    controller: _venueCityController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueCityHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.descriptionLabel,
                  childInput: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.eventDescriptionHint,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: _onSubmit,
                      child: Text(location.saveButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      uid: 'EventDate_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
    );

    final eventId =
        event?.uid ??
        'Event_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
    final eventModified = Event(
      uid: eventId,
      eventName: _nameController.text,
      tracks: _tracks.map((track) {
        track.eventUid = eventId;
        return track;
      }).toList(),
      year: eventDates.startDate.split('-').first,
      primaryColor: _primaryColorController.text,
      secondaryColor: _secondaryColorController.text,
      eventDates: eventDates,
      venue: Venue(
        name: _venueNameController.text,
        address: _venueAddressController.text,
        city: _venueCityController.text,
      ),
      description: _descriptionController.text,
    );
    await eventFormViewModel.onSubmit(eventModified);
    if (mounted) {
      Navigator.pop(context, eventModified);
    }
  }
}
