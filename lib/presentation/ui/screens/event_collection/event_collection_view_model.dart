import 'package:flutter/foundation.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../view_model_common.dart';

abstract class EventCollectionViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract final ValueNotifier<bool> isLoading;
  abstract EventFilter currentFilter;
  void onEventFilterChanged(EventFilter value);
  void addEvent(Event event);
  void editEvent(Event event);
  void deleteEvent(Event event);
}

class EventCollectionViewModelImp implements EventCollectionViewModel {
  EventUseCase useCase;

  @override
  final ValueNotifier<List<Event>> eventsToShow = ValueNotifier<List<Event>>(
    [],
  );

  @override
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  EventFilter currentFilter = EventFilter.all;

  List<Event> _allEvents = [];

  EventCollectionViewModelImp({required this.useCase});

  @override
  Future<void> setup() async {
    _allEvents = await useCase.getComposedEvents();
    _updateEventsToShow();
  }

  @override
  void dispose() {
    eventsToShow.dispose();
    isLoading.dispose();
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
    useCase.saveEvents(_allEvents);
  }

  @override
  void editEvent(Event event) {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents[index] = event;
      _updateEventsToShow();
      useCase.saveEvents(_allEvents);
    }
  }

  @override
  void deleteEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents.removeAt(index);
      _applyFilters();
      useCase.saveEvents(_allEvents);
    }
  }

  void _updateEventsToShow() async {
    _sortEvents();
    _applyFilters();
  }

  void _applyFilters() {
    final now = DateTime.now();
    List<Event> eventsFiltered = [..._allEvents];
    switch (currentFilter) {
      case EventFilter.all:
        // Show all events
        break;
      case EventFilter.past:
        eventsFiltered = eventsFiltered.where((event) {
          final startDate = DateTime.parse(event.eventDates!.startDate);
          return startDate.isBefore(now);
        }).toList();
        break;
      case EventFilter.current:
        eventsFiltered = eventsFiltered.where((event) {
          final startDate = DateTime.parse(event.eventDates!.startDate);
          return startDate.isAfter(now);
        }).toList();
        break;
    }
    eventsToShow.value = eventsFiltered;
  }

  void _sortEvents() {
    _allEvents.sort((a, b) {
      final aDate = DateTime.parse(a.eventDates!.startDate);
      final bDate = DateTime.parse(b.eventDates!.startDate);
      return aDate.compareTo(bDate);
    });
  }
}
