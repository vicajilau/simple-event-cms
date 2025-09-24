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

    events = await repository.loadEvents();

    return events;
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
