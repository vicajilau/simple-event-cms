import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<List<Event>> getComposedEvents();
  void saveEvents(List<Event> events);
}

class EventUseCaseImp implements EventUseCase {
  SecRepository repository;

  EventUseCaseImp({required this.repository});

  @override
  Future<List<Event>> getComposedEvents() async {
    final allEvents = await repository.loadEvents();
    var agenda = await repository.loadEAgendas();
    var speakers = await repository.loadESpeakers();
    var sponsors = await repository.loadSponsors();

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
  void saveEvents(List<Event> events) {
    // TODO: implement saveEvents
  }
}
