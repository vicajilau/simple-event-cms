import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
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
  final nominatim = Nominatim(userAgent: 'Dart osm_nominatim');
  EventFormScreen({super.key, this.eventId});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final eventFormViewModel = getIt<EventFormViewModel>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _primaryColorController = TextEditingController();
  final TextEditingController _secondaryColorController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();

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
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _youtubeUrlFocus = FocusNode();

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
  final GlobalKey<FormFieldState> _locationFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _youtubeUrlFieldKey =
      GlobalKey<FormFieldState>();

  var config = getIt<Config>();
  bool _hasEndDate = true;
  bool _isVisible = true;
  bool _isOpenByDefault = false;
  List<Track> _tracks = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize Nominatim for web to avoid isolate errors.
    // This should be called before any other Nominatim method.
    // It's safe to call this on all platforms.
    // Configure Nominatim with enhanced settings

    if (widget.eventId != null) {
      _isOpenByDefault = config.eventForcedToViewUID == widget.eventId;
      eventFormViewModel.viewState.value = ViewState.isLoading;
      widget.eventCollectionViewModel.getEventById(widget.eventId!).then((
        event,
      ) {
        if (event == null) {
          eventFormViewModel.viewState.value = ViewState.error;
          eventFormViewModel.errorMessage = 'Failed to load event.';
        } else {
          _nameController.text = event.eventName;
          final startDate = event.eventDates.startDate;
          _startDateController.text = startDate;
          final endDate = event.eventDates.endDate;
          _hasEndDate = startDate != endDate;
          if (_hasEndDate) {
            _endDateController.text = endDate;
          }
          if (event.location != null) {
            _locationController.text = event.location!;
          }
          _tracks = event.tracks;
          _timezoneController.text = event.eventDates.timezone;
          _primaryColorController.text = event.primaryColor;
          _secondaryColorController.text = event.secondaryColor;
          _isVisible = event.isVisible;
          _youtubeUrlController.text = event.youtubeUrl ?? '';
          eventFormViewModel.viewState.value = ViewState.loadFinished;
        }
      });
    } else {
      eventFormViewModel.viewState.value = ViewState.loadFinished;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _timezoneController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _locationController.dispose();
    _youtubeUrlController.dispose();

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
    _locationFocus.dispose();
    _youtubeUrlFocus.dispose();
    _debounce?.cancel();

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

  /// Placeholder for your suggestions API.
  /// You should replace this with a real implementation using an API like Google Places.
  Future<Iterable<String>> _getSuggestions(
    TextEditingValue textEditingValue,
  ) async {
    // Cancel any existing timer
    _debounce?.cancel();

    // If the user has cleared the text, don't fetch suggestions.
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }

    // Start a new timer
    final completer = Completer<Iterable<String>>();
    _debounce = Timer(const Duration(seconds: 1), () async {
      try {
        final searchResult = await widget.nominatim.searchByName(
          query: textEditingValue.text,
          limit: 3,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        );

        // Before returning, check if the text has changed. If it has, this result is stale,
        // and we should return an empty list to avoid showing outdated suggestions.
        // This prevents race conditions when typing quickly.
        if (textEditingValue.text != _locationController.text) {
          completer.complete(Iterable<String>.empty());
        }

        completer.complete(searchResult.map((s) => s.displayName.toString()));
      } catch (e) {
        // Handle potential network errors or exceptions from the library
        completer.complete(const Iterable<String>.empty());
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ValueListenableBuilder<ViewState>(
      valueListenable: eventFormViewModel.viewState,
      builder: (context, snapshot, child) {
        if (snapshot == ViewState.isLoading) {
          return FormScreenWrapper(
            pageTitle: localizations.loadingTitle,
            widgetFormChild: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot == ViewState.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => CustomErrorDialog(
                  errorMessage: eventFormViewModel.errorMessage,
                  onCancel: () => {
                    widget.eventCollectionViewModel.setErrorKey(null),
                    eventFormViewModel.viewState.value = ViewState.loadFinished,
                    Navigator.of(context).pop(),
                  },
                  buttonText: localizations.closeButton,
                ),
              );
            }
          });
        }
        return FormScreenWrapper(
          pageTitle: widget.eventId != null
              ? localizations.editEventTitle
              : localizations.createEventTitle,
          widgetFormChild: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  widget.eventId != null
                      ? localizations.editingEvent
                      : localizations.creatingEvent,
                  style: AppFonts.titleHeadingForm.copyWith(color: Colors.blue),
                ),
                SectionInputForm(
                  label: localizations.eventNameLabel,
                  childInput: TextFormField(
                    key: _nameFieldKey,
                    focusNode: _nameFocus,
                    controller: _nameController,
                    maxLines: 1,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: localizations.eventNameHint,
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? localizations.requiredField
                        : null,
                  ),
                ),
                SectionInputForm(
                  label:
                      "Location", // Consider adding this to your AppLocalizations
                  childInput: Autocomplete<String>(
                    optionsBuilder: _getSuggestions,
                    onSelected: (String selection) {
                      _locationController.text = selection;
                    },
                    fieldViewBuilder:
                        (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          // We need to use a separate controller for the field view
                          // and sync it with our main controller.
                          // This is a common pattern for Autocomplete.
                          if (_locationController.text.isNotEmpty &&
                              fieldTextEditingController.text.isEmpty) {
                            fieldTextEditingController.text =
                                _locationController.text;
                          }

                          // The Autocomplete widget manages its own controller and focus node.
                          // We must use the ones provided by the fieldViewBuilder.
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: AppDecorations.textFieldDecoration.copyWith(
                              hintText:
                                  "Enter event location", // Consider localizing
                            ),
                            onChanged: (text) {
                              // Sync our controller with the field's controller
                              _locationController.text = text;
                            },
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? localizations.requiredField
                                : null,
                          );
                        },
                  ),
                ),
                SectionInputForm(
                  label: localizations.startDateLabel,
                  childInput: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _startDateFieldKey,
                          focusNode: _startDateFocus,
                          controller: _startDateController,
                          readOnly: true,
                          decoration: AppDecorations.textFieldDecoration
                              .copyWith(hintText: localizations.dateHint),
                          onTap: () =>
                              _selectDate(context, _startDateController),
                          validator: (value) => (value == null || value.isEmpty)
                              ? localizations.requiredField
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasEndDate)
                  SectionInputForm(
                    label: localizations.endDateLabel,
                    childInput: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: _endDateFieldKey,
                            focusNode: _endDateFocus,
                            controller: _endDateController,
                            readOnly: true,
                            decoration: AppDecorations.textFieldDecoration
                                .copyWith(hintText: localizations.dateHint),
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
                        localizations.addEndDate,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                SectionInputForm(
                  label: localizations.roomsLabel,
                  childInput: SizedBox(
                    height: 200,
                    child: AddRoom(
                      rooms: _tracks.toList(),
                      editedRooms: (List<Track> currentRooms) async {
                        _tracks = currentRooms;
                      },
                      removeRoom: (Track track) async {
                        await eventFormViewModel.removeTrack(track.uid);
                      },
                      eventUid: widget.eventId.toString(),
                    ),
                  ),
                ),
                SectionInputForm(
                  label: localizations.timezoneLabel,
                  childInput: TextFormField(
                    key: _timezoneFieldKey,
                    focusNode: _timezoneFocus,
                    controller: _timezoneController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: localizations.timezoneHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: localizations.primaryColorLabel,
                  childInput: TextFormField(
                    key: _primaryColorFieldKey,
                    focusNode: _primaryColorFocus,
                    controller: _primaryColorController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: localizations.primaryColorHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: localizations.secondaryColorLabel,
                  childInput: TextFormField(
                    key: _secondaryColorFieldKey,
                    focusNode: _secondaryColorFocus,
                    controller: _secondaryColorController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: localizations.secondaryColorHint,
                    ),
                  ),
                ),
                SectionInputForm(
                  label: "YouTube URL", // Consider localizing
                  childInput: TextFormField(
                    key: _youtubeUrlFieldKey,
                    focusNode: _youtubeUrlFocus,
                    controller: _youtubeUrlController,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText:
                      "https://www.youtube.com/watch?v=...", // Consider localizing
                    ),
                    // Optional: Add a validator for the URL format
                  ),
                ),
                SectionInputForm(
                  label: localizations.visibilityLabel,
                  childInput: SwitchListTile(
                    title: Text(
                      _isVisible
                          ? localizations.eventIsVisible
                          : localizations.eventIsHidden,
                    ),
                    value: _isVisible,
                    onChanged: (bool value) {
                      setState(() {
                        _isVisible = value;
                        if (!_isVisible) {
                          _isOpenByDefault = false;
                        }
                      });
                    },
                  ),
                ),
                SectionInputForm(
                  label: localizations.openByDefaultLabel,
                  childInput: SwitchListTile(
                    title: Text(
                      _isOpenByDefault
                          ? localizations.eventIsOpenByDefault
                          : localizations.eventIsNotOpenByDefault,
                    ),
                    value: _isOpenByDefault,
                    onChanged: (bool value) {
                      setState(() {
                        _isOpenByDefault = value;
                        if (value) {
                          _isVisible = true;
                        }
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(localizations.cancelButton),
                    ),
                    FilledButton(
                      onPressed: _onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(localizations.saveButton),
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
    final localizations = AppLocalizations.of(context)!;

    // First, force validation to show errors.
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      // Ordered list of (key, focusNode) pairs in the same visual order as the form.
      final fields = <MapEntry<GlobalKey<FormFieldState>, FocusNode>>[
        MapEntry(_nameFieldKey, _nameFocus),
        MapEntry(_locationFieldKey, _locationFocus),
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
        MapEntry(_youtubeUrlFieldKey, _youtubeUrlFocus),
      ];

      // Find the ones with errors
      final invalidFields = fields.where((f) {
        final state = f.key.currentState;
        return state != null && state.hasError;
      }).toList();

      if (invalidFields.isNotEmpty) {
        final firstInvalidField = invalidFields.first;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomErrorDialog(
            errorMessage: localizations.formError,
            onCancel: () => Navigator.of(context).pop(),
            buttonText: localizations.closeButton,
          ),
        );

        if (!mounted) return;

        firstInvalidField.value.requestFocus();

        // Automatically scroll to make the error visible.
        await Scrollable.ensureVisible(
          firstInvalidField.value.context!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
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
      location: _locationController.text,
      tracks: _tracks.map((track) {
        track.eventUid = eventId;
        return track;
      }).toList(),
      year: eventDates.startDate.split('-').first,
      primaryColor: _primaryColorController.text,
      secondaryColor: _secondaryColorController.text,
      isVisible: _isVisible,
      youtubeUrl: _youtubeUrlController.text,
      eventDates: eventDates,
    );
    if (_isOpenByDefault) {
      config.eventForcedToViewUID = eventId;
    } else if (config.eventForcedToViewUID == eventId) {
      config.eventForcedToViewUID = null;
    }

    await widget.eventCollectionViewModel.updateConfig(config);
    var result = await eventFormViewModel.onSubmit(eventModified);
    if (result) {
      if (mounted) {
        Navigator.pop(context, eventModified);
      }
    }
  }
}
