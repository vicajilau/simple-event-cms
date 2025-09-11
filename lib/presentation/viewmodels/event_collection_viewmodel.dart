import 'package:flutter/foundation.dart';

import '../../core/models/models.dart';
import '../../core/services/load/data_loader.dart';

abstract class DataRepository {
  Future<List<Event>> loadEvents();
  Future<void> saveEvents(List<Event> events);
}

class DataRepositoryImp extends DataRepository {
  final DataLoader dataLoader;

  DataRepositoryImp({required this.dataLoader});

  @override
  Future<List<Event>> loadEvents() async {
    final allEvents = dataLoader.config;
    var agenda = await dataLoader.loadAgenda("2025");
    var speakers = await dataLoader.loadSpeakers("2025");
    var sponsors = await dataLoader.loadSponsors("2025");

    for (var event in allEvents) {
      event.agenda = agenda.firstWhere(
        (element) => element.uid == event.agendaUID,
      );

      event.speakers = event.speakersUID
          .map((uid) => speakers.firstWhere((s) => s.uid == uid))
          .whereType<Speaker>()
          .toList();

      event.sponsors = event.sponsorsUID
          .map((uid) => sponsors.firstWhere((s) => s.uid == uid))
          .whereType<Sponsor>()
          .toList();
    }
    return allEvents;
  }

  @override
  Future<void> saveEvents(List<Event> events) {
    // TODO: implement saveEvents
    throw UnimplementedError();
  }
}

abstract class ViewModel {
  void setup();
  void dispose();
}

abstract class EventCollectionViewmodel extends ViewModel {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract final ValueNotifier<bool> isLoading;
  abstract bool showEndedEvents, showNextEvents;
  void toggleShowEndedEvents(bool value);
  void toggleShowNextEvents(bool value);
  void addEvent(Event event);
  void editEvent(Event event);
  void deleteEvent(int index);
}

class EventCollectionViewmodelImp implements EventCollectionViewmodel {
  DataRepository repository;

  @override
  final ValueNotifier<List<Event>> eventsToShow = ValueNotifier<List<Event>>(
    [],
  );

  @override
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  bool showEndedEvents = false, showNextEvents = true;

  List<Event> _allEvents = [];

  EventCollectionViewmodelImp({required this.repository});

  @override
  void setup() async {
    _allEvents = await repository.loadEvents();
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
    repository.saveEvents(_allEvents);
  }

  @override
  void editEvent(Event event) {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents[index] = event;
      _updateEventsToShow();
      repository.saveEvents(_allEvents);
    }
  }

  @override
  void deleteEvent(int index) async {
    _allEvents.removeAt(index);
    repository.saveEvents(_allEvents);
  }

  void _updateEventsToShow() {
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
    eventsToShow.value = [...eventsFiltered];
  }

  void _sortEvents() {
    _allEvents.sort((a, b) {
      final aDate = DateTime.parse(a.eventDates!.startDate);
      final bDate = DateTime.parse(b.eventDates!.startDate);
      return aDate.compareTo(bDate);
    });
  }
}
