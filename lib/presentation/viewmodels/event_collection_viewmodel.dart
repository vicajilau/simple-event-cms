import 'package:flutter/foundation.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';

import 'viewmodel_common.dart';

abstract class EventCollectionViewmodel extends ViewModelCommon {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract final ValueNotifier<bool> isLoading;
  abstract bool showEndedEvents, showNextEvents;
  void toggleShowEndedEvents(bool value);
  void toggleShowNextEvents(bool value);
  void addEvent(Event event);
  void editEvent(Event event);
  void deleteEvent(Event event);
}

class EventCollectionViewmodelImp implements EventCollectionViewmodel {
  EventUseCase useCase;

  @override
  final ValueNotifier<List<Event>> eventsToShow = ValueNotifier<List<Event>>(
    [],
  );

  @override
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  bool showEndedEvents = false, showNextEvents = true;

  List<Event> _allEvents = [];

  EventCollectionViewmodelImp({required this.useCase});

  @override
  void setup() async {
    _allEvents = await useCase.getComposedEvents();
    _updateEventsToShow();
  }

  @override
  void dispose() {
    eventsToShow.dispose();
    isLoading.dispose();
  }

  @override
  void toggleShowEndedEvents(bool value) {
    showEndedEvents = value;
    _applyFilters();
  }

  @override
  void toggleShowNextEvents(bool value) {
    showNextEvents = value;
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
    if (showEndedEvents && showNextEvents) {
    } else if (showEndedEvents) {
      eventsFiltered = _allEvents.where((event) {
        final startDate = DateTime.parse(event.eventDates!.startDate);
        return startDate.isBefore(now);
      }).toList();
    } else if (showNextEvents) {
      eventsFiltered = _allEvents.where((event) {
        final startDate = DateTime.parse(event.eventDates!.startDate);
        return startDate.isAfter(now);
      }).toList();
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
