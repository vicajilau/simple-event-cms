import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/core/utils/app_fonts.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../view_model_common.dart';

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
  final ScrollController _scrollController = ScrollController();

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
  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _startDateFocus = FocusNode();
  final FocusNode _endDateFocus = FocusNode();
  final FocusNode _timezoneFocus = FocusNode();
  final FocusNode _baseUrlFocus = FocusNode();
  final FocusNode _primaryColorFocus = FocusNode();
  final FocusNode _secondaryColorFocus = FocusNode();
  final FocusNode _venueNameFocus = FocusNode();
  final FocusNode _venueAddressFocus = FocusNode();
  final FocusNode _venueCityFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  // Form field keys
  final GlobalKey<FormFieldState> _nameFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _startDateFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _endDateFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _timezoneFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _baseUrlFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _primaryColorFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _secondaryColorFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _venueNameFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _venueAddressFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _venueCityFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _descriptionFieldKey =
      GlobalKey<FormFieldState>();

  bool _hasEndDate = true;
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      widget.eventCollectionViewModel.viewState.value = ViewState.isLoading;
      _eventFuture = widget.eventCollectionViewModel.getEventById(
        widget.eventId!,
      );
      _eventFuture?.catchError((error) {
        return null;
      });
      _eventFuture?.then((event) {
        if (event == null) {
          widget.eventCollectionViewModel.viewState.value = ViewState.error;
        } else {
          _nameController.text = event.eventName;
          final startDate = event.eventDates.startDate;
          _startDateController.text = startDate;
          final endDate = event.eventDates.endDate;
          _hasEndDate = startDate != endDate;
          if (_hasEndDate) {
            _endDateController.text = endDate;
          }
          _tracks = event.tracks;
          _timezoneController.text = event.eventDates.timezone;
          _primaryColorController.text = event.primaryColor;
          _secondaryColorController.text = event.secondaryColor;
          _venueNameController.text = event.venue?.name ?? '';
          _venueAddressController.text = event.venue?.address ?? '';
          _venueCityController.text = event.venue?.city ?? '';
          _descriptionController.text = event.description ?? '';
          widget.eventCollectionViewModel.viewState.value =
              ViewState.loadFinished;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _timezoneController.dispose();
    _baseUrlController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _venueCityController.dispose();
    _descriptionController.dispose();

    // dispose focus nodes
    _nameFocus.dispose();
    _startDateFocus.dispose();
    _endDateFocus.dispose();
    _timezoneFocus.dispose();
    _baseUrlFocus.dispose();
    _primaryColorFocus.dispose();
    _secondaryColorFocus.dispose();
    _venueNameFocus.dispose();
    _venueAddressFocus.dispose();
    _venueCityFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
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
        if (controller == _endDateController) {
          _endDateController.text = pickedDate
              .toIso8601String()
              .split("T")
              .first;
        } else {
          _startDateController.text = pickedDate
              .toIso8601String()
              .split("T")
              .first;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: widget.eventCollectionViewModel.viewState,
      builder: (context, snapshot, child) {
        if (snapshot == ViewState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot == ViewState.error) {
          return Scaffold(
            body: Center(
              child: Text(
                '${location.errorPrefix} Error with event, please, retry later',
              ),
            ),
          );
        }
        return FormScreenWrapper(
          pageTitle: widget.eventId != null
              ? location.editEventTitle
              : location.createEventTitle,
          widgetFormChild: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  widget.eventId != null
                      ? location.editingEvent
                      : location.creatingEvent,
                  style: AppFonts.titleHeadingForm,
                ),
                SectionInputForm(
                  label: location.eventNameLabel,
                  childInput: TextFormField(
                    key: _nameFieldKey,
                    focusNode: _nameFocus,
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
                          key: _startDateFieldKey,
                          focusNode: _startDateFocus,
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
                            key: _endDateFieldKey,
                            focusNode: _endDateFocus,
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
                      editedRooms: (List<Track> currentRooms) async {
                        _tracks = currentRooms;
                      },
                      removeRoom: (Track track) async {
                        await eventFormViewModel.removeTrack(
                          track.uid,
                          track.eventUid,
                        );
                      },
                      eventUid: widget.eventId.toString(),
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.timezoneLabel,
                  childInput: TextFormField(
                    key: _timezoneFieldKey,
                    focusNode: _timezoneFocus,
                    controller: _timezoneController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.timezoneHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.baseUrlLabel,
                  childInput: TextFormField(
                    key: _baseUrlFieldKey,
                    focusNode: _baseUrlFocus,
                    controller: _baseUrlController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.baseUrlHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.primaryColorLabel,
                  childInput: TextFormField(
                    key: _primaryColorFieldKey,
                    focusNode: _primaryColorFocus,
                    controller: _primaryColorController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.primaryColorHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.secondaryColorLabel,
                  childInput: TextFormField(
                    key: _secondaryColorFieldKey,
                    focusNode: _secondaryColorFocus,
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
                    key: _venueNameFieldKey,
                    focusNode: _venueNameFocus,
                    controller: _venueNameController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueNameHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.venueAddressLabel,
                  childInput: TextFormField(
                    key: _venueAddressFieldKey,
                    focusNode: _venueAddressFocus,
                    controller: _venueAddressController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueAddressHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.venueCityLabel,
                  childInput: TextFormField(
                    key: _venueCityFieldKey,
                    focusNode: _venueCityFocus,
                    controller: _venueCityController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.venueCityHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: location.descriptionLabel,
                  childInput: TextFormField(
                    key: _descriptionFieldKey,
                    focusNode: _descriptionFocus,
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
    final location = AppLocalizations.of(context)!;

    // Primero forzamos la validación para que los errores aparezcan
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      // Lista ordenada de pares (key, focusNode) en el mismo orden visual del formulario.
      final fields = <MapEntry<GlobalKey<FormFieldState>, FocusNode>>[
        MapEntry(_nameFieldKey, _nameFocus),
        MapEntry(_startDateFieldKey, _startDateFocus),
        MapEntry(_endDateFieldKey, _endDateFocus),
        MapEntry(_timezoneFieldKey, _timezoneFocus),
        MapEntry(_baseUrlFieldKey, _baseUrlFocus),
        MapEntry(_primaryColorFieldKey, _primaryColorFocus),
        MapEntry(_secondaryColorFieldKey, _secondaryColorFocus),
        MapEntry(_venueNameFieldKey, _venueNameFocus),
        MapEntry(_venueAddressFieldKey, _venueAddressFocus),
        MapEntry(_venueCityFieldKey, _venueCityFocus),
        MapEntry(_descriptionFieldKey, _descriptionFocus),
      ];

      // Encontrar los que tienen error
      final invalid = fields.where((f) {
        final state = f.key.currentState;
        return state != null && state.hasError;
      }).toList();

      final lastInvalid = invalid.last;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CustomErrorDialog(
          errorMessage: location.formError,
          onCancel: () => Navigator.of(context).pop(),
          buttonText: location.closeButton,
        ),
      );

      if (!mounted) return;

      lastInvalid.value.requestFocus();

      // Hacemos scroll automatico para que sea visible el error
      await Scrollable.ensureVisible(
        lastInvalid.value.context!,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );

      return;
    }

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
        widget.eventId ??
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
