import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<Result<List<Event>>> getComposedEvents();
  Future<Event?> getEventById(String id);
  Future<void> saveEvent(Event event);
}

class EventUseCaseImp implements EventUseCase {
  SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Event>>> getComposedEvents() async {
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
}
