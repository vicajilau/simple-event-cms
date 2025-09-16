import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<List<Event>> getComposedEvents();
  Event? getEventById(String id);
  void saveEvent(Event event);
}

class EventUseCaseImp implements EventUseCase {
  SecRepository repository = getIt<SecRepository>();

  List<Event> events = [];

  @override
  Future<List<Event>> getComposedEvents() async {
    if (events.isNotEmpty) {
      return events;
    }

    final allEvents = await repository.loadEvents();
    var agenda = await repository.loadEAgendas();
    var speakers = await repository.loadESpeakers();
    var sponsors = await repository.loadSponsors();

    for (var event in allEvents) {
      // Find agenda, return null if not found
      try {
        event.agenda = agenda.firstWhere(
          (element) => element.uid == event.agendaUID,
        );
      } on StateError {
        event.agenda = null;
      }

      // Find speakers, filter out nulls
      event.speakers = event.speakersUID
          .map((uid) {
            try {
              return speakers.firstWhere((s) => s.uid == uid);
            } on StateError {
              return null;
            }
          })
          .whereType<Speaker>()
          .toList();

      // Find sponsors, filter out nulls
      event.sponsors = event.sponsorsUID
          .map((uid) {
            try {
              return sponsors.firstWhere((s) => s.uid == uid);
            } on StateError {
              return null;
            }
          })
          .whereType<Sponsor>()
          .toList();
    }
    events = allEvents;
    return allEvents;
  }

  @override
  Event? getEventById(String id) {
    if (events.isEmpty) {
      getComposedEvents();
    }
    try {
      return events.firstWhere((event) => event.uid == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> saveEvent(Event event) async {
    repository.saveEvent(event);
  }
}
