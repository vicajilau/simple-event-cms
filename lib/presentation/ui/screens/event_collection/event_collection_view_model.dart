import 'package:flutter/foundation.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../view_model_common.dart';

abstract class EventCollectionViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract EventFilter currentFilter;
  void onEventFilterChanged(EventFilter value);
  void addEvent(Event event);
  Event? getEventById(String eventId);
  void editEvent(Event event);
  void deleteEvent(Event event);
}

class EventCollectionViewModelImp implements EventCollectionViewModel {
  EventUseCase useCase = getIt<EventUseCase>();
  CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();

  @override
  final ValueNotifier<List<Event>> eventsToShow = ValueNotifier<List<Event>>(
    [],
  );

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  EventFilter currentFilter = EventFilter.all;

  List<Event> _allEvents = [];

  @override
  Future<void> setup([Object? argument]) async {
    loadEvents();
  }

  void loadEvents() async {
    viewState.value = ViewState.isLoading;
    try {
      _allEvents = await useCase.getComposedEvents();
      _updateEventsToShow();
      viewState.value = ViewState.loadFinished;
    } catch (e) {
      // TODO: implement error handling (errors need to be created)
      errorMessage = "Error loading data";
      viewState.value = ViewState.error;
    }
  }

  @override
  void onEventFilterChanged(EventFilter value) {
    currentFilter = value;
    _applyFilters();
  }

  @override
  void addEvent(Event event) {
    _allEvents.add(event);
    _updateEventsToShow();
    useCase.saveEvent(event);
  }

  @override
  void editEvent(Event event) {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents[index] = event;
      _updateEventsToShow();
      useCase.saveEvent(event);
    }
  }

  @override
  void deleteEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents.removeAt(index);
      _applyFilters();
      useCase.saveEvent(event);
    }
  }

  void _updateEventsToShow() async {
    _sortEvents();
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    final now = DateTime.now();
    List<Event> eventsFiltered = [..._allEvents];
    switch (currentFilter) {
      case EventFilter.all:
        // Show all events
        eventsFiltered = _allEvents;
        break;
      case EventFilter.past:
        eventsFiltered = eventsFiltered.where((event) {
          final startDate = DateTime.parse(event.eventDates.startDate);
          return startDate.isBefore(now);
        }).toList();
        break;
      case EventFilter.current:
        eventsFiltered = eventsFiltered.where((event) {
          final startDate = DateTime.parse(event.eventDates.startDate);
          return startDate.isAfter(now);
        }).toList();
        break;
    }
    eventsToShow.value = eventsFiltered;
  }

  void _sortEvents() {
    _allEvents.sort((a, b) {
      final aDate = DateTime.parse(a.eventDates.startDate);
      final bDate = DateTime.parse(b.eventDates.startDate);
      return aDate.compareTo(bDate);
    });
  }

  @override
  void dispose() {}

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Event? getEventById(String eventId) {
    return useCase.getEventById(eventId);
  }
}
