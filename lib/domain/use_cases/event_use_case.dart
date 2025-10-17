import 'package:intl/intl.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<Result<List<Event>>> getEvents();
  Future<Event?> getEventById(String id);
  Future<void> saveEvent(Event event);
  Future<void> prepareAgendaDays(Event event);
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
    await repository.saveEvent(event);
  }

  @override
  Future<void> prepareAgendaDays(Event event) async {
    final startDate = DateTime.tryParse(event.eventDates.startDate);
    final endDate = DateTime.tryParse(event.eventDates.endDate);

    if (startDate != null && endDate != null) {
      final difference = endDate.difference(startDate).inDays;
      List<AgendaDay> days = [];
      for (int i = 1; i <= difference; i++) {
        days.add(
          AgendaDay(
            uid:
                'AgendaDay_$i${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
            date: DateFormat(
              'yyyy-MM-dd',
            ).format(startDate.add(Duration(days: i))),
            eventUID: event.uid
          ),
        );
      }
      await repository.saveAgendaDays(days);
    }
  }
}
