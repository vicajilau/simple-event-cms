import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<Result<List<Event>>> getEvents();
  Future<Event?> getEventById(String id);
  Future<void> saveEvent(Event event);
  Future<void> saveTracks(List<Track> tracks);
  Future<void> saveAgendaDays(List<AgendaDay> days);

  }

class EventUseCaseImp implements EventUseCase {
  SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Event>>> getEvents() async {
    return repository.loadEvents();
  }

  @override
  Future<Event?> getEventById(String id) async {
    final events = await repository.loadEvents();
    switch (events) {
      case Ok<List<Event>>():
        return events.value.firstWhere((event) => event.uid == id);
      case Error():
        return null;
    }
  }

  @override
  Future<void> saveEvent(Event event) async {
    repository.saveEvent(event);
  }

  @override
  Future<void> saveTracks(List<Track> tracks) async {
    repository.saveTracks(tracks);
  }
  @override
  Future<void> saveAgendaDays(List<AgendaDay> days) async {
    repository.saveAgendaDays(days);
  }
}
