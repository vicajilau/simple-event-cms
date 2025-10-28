import 'package:flutter/foundation.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../view_model_common.dart';

abstract class EventCollectionViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract EventFilter currentFilter;
  void onEventFilterChanged(EventFilter value);
  Future<void> addEvent(Event event);
  Future<Event?> getEventById(String eventId);
  Future<Result<void>> editEvent(Event event);
  Future<void> deleteEvent(Event event);
}

class EventCollectionViewModelImp extends EventCollectionViewModel {
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
    final result = await useCase.getEvents();
    switch (result) {
      case Ok<List<Event>>():
        _allEvents = result.value;
        _updateEventsToShow();
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  void onEventFilterChanged(EventFilter value) {
    currentFilter = value;
    _applyFilters();
  }

  @override
  Future<void> addEvent(Event event) async {
    _allEvents.removeWhere((element) => element.uid == event.uid);
    _allEvents.add(event);
    _updateEventsToShow();
  }

  @override
  Future<Result<void>> editEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents[index] = event;
      _updateEventsToShow();

      viewState.value = ViewState.isLoading;
      final result =  await useCase.saveEvent(event);
      viewState.value = ViewState.loadFinished;
      return result;
    }
    return Result.error(GithubException('Event not found'));
  }

  @override
  Future<void> deleteEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents.removeAt(index);
      _applyFilters();

      viewState.value = ViewState.isLoading;
      final result = await useCase.removeEvent(event);
      switch (result) {
        case Ok<void>():
          viewState.value = ViewState.loadFinished;
        case Error():
          viewState.value = ViewState.error;
          setErrorKey(result.error);
      }
    }
  }

  void _updateEventsToShow() async {
    _sortEvents();
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    viewState.value = ViewState.isLoading;
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
    viewState.value = ViewState.loadFinished;
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
  Future<Event?> getEventById(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result =  await useCase.getEventById(eventId);
    switch (result) {
      case Ok<Event?>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return null;
    }
  }

}
