import 'package:intl/intl.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class EventUseCase {
  Future<Result<List<Event>>> getEvents();
  Future<Result<Event?>> getEventById(String id);
  Future<Result<void>> saveEvent(Event event);
  Future<Result<void>> removeEvent(Event event);
  Future<Result<void>> prepareAgendaDays(Event event);
  Future<Result<void>> removeTrack(String trackUID);
  Future<Result<void>> updateConfig(Config config);
}

class EventUseCaseImp implements EventUseCase {
  SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Event>>> getEvents() async {
    return repository.loadEvents();
  }

  @override
  Future<Result<Event?>> getEventById(String id) async {
    final events = await repository.loadEvents();
    switch (events) {
      case Ok<List<Event>>():
        return Result.ok(events.value.firstWhere((event) => event.uid == id));
      case Error():
        return Result.error(GithubException("Event not found"));
    }
  }

  @override
  Future<Result<void>> saveEvent(Event event) async {
    return await repository.saveEvent(event);
  }

  @override
  Future<Result<void>> prepareAgendaDays(Event event) async {
    final startDate = DateTime.tryParse(event.eventDates.startDate);
    final endDate = DateTime.tryParse(event.eventDates.endDate);

    if (startDate != null && endDate != null) {
      final difference = endDate.difference(startDate).inDays;
      List<AgendaDay> days = [];

      for (int i = 0; i <= difference; i++) {
        var date = DateFormat(
          'yyyy-MM-dd',
        ).format(startDate.add(Duration(days: i)));
        days.add(
          AgendaDay(uid: date, date: date, eventsUID: [event.uid].toList()),
        );
      }
      return await repository.saveAgendaDays(
        days,
        event.uid,
        overrideAgendaDays: true,
      );
    } else if (startDate != null) {
      var date = DateFormat('yyyy-MM-dd').format(startDate);
      final agendaDayToAdd = AgendaDay(
        uid: date,
        date: date,
        eventsUID: [event.uid].toList(),
      );
      return await repository.saveAgendaDays(
        [agendaDayToAdd],
        event.uid,
        overrideAgendaDays: true,
      );
    } else {
      return Result.error(GithubException("Invalid date format"));
    }
  }

  @override
  Future<Result<void>> removeEvent(Event event) async {
    return await repository.removeEvent(event.uid);
  }

  @override
  Future<Result<void>> removeTrack(String trackUID) async {
    return await repository.removeTrack(trackUID);
  }

  @override
  Future<Result<void>> updateConfig(Config config) async {
    return await repository.saveConfig(config);
  }
}
