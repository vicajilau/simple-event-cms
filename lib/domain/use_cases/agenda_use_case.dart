import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../core/utils/result.dart';

abstract class AgendaUseCase {
  Future<Result<Agenda>> getAgendaById(String id);
  void saveAgenda(Agenda agenda, String eventId);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId);
  Future<Result<List<AgendaDay>>> getAgendaDayByListId(
    List<String> agendaDayIds,
  );
  Future<Result<List<Session>>> getSessionsByListId(List<String> sessionsIds);
  Future<Result<List<Track>>> getTracksByListId(List<String> tracksIds);
  Future<Result<Track>> getTrackById(String trackId);
  void addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  );
  void editSession(Session session, String parentId);
  void deleteSessionFromAgendaDay(String sessionId);
  Future<Result<Event>> loadEvent(String eventId);

  Future<List<Speaker>> getSpeakersForEventId(String eventId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<Agenda>> getAgendaById(String id) async {
    final result = await repository.loadEAgendas();
    switch (result) {
      case Ok<List<Agenda>>():
        if(result.value.isEmpty  || result.value.indexWhere((agenda) => agenda.uid == id) == -1){
          return Result.error(NetworkException("No agendas found"));
        }
        return Result.ok(result.value.firstWhere((event) => event.uid == id));

      case Error():
        return Result.error(result.error);
    }
  }

  @override
  void saveAgenda(Agenda agenda, String eventId) {
    repository.saveAgenda(agenda, eventId);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    await repository.saveAgendaDayById(agendaDay, agendaId);
  }

  @override
  void addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  ) {
    repository.addSessionIntoAgenda(agendaId, agendaDayId, trackId, session);
  }

  @override
  void editSession(Session session, String parentId) {
    repository.editSession(session, parentId);
  }

  @override
  void deleteSessionFromAgendaDay(String sessionId) {
    repository.deleteSessionFromAgendaDay(sessionId);
  }

  @override
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId) async {
    return repository.loadAgendaDayById(agendaDayId);
  }

  @override
  Future<Result<Track>> getTrackById(String trackId) {
    return repository.loadTrackById(trackId);
  }

  @override
  Future<Result<Event>> loadEvent(String eventId) {
    return repository.loadEventById(eventId);
  }

  @override
  Future<Result<List<AgendaDay>>> getAgendaDayByListId(
    List<String> agendaDayIds,
  ) {
    return repository.loadAgendaDayByListId(agendaDayIds);
  }

  @override
  Future<Result<List<Track>>> getTracksByListId(List<String> tracksIds) {
    return repository.loadTracksByListId(tracksIds);
  }

  @override
  Future<Result<List<Session>>> getSessionsByListId(List<String> sessionsIds) {
    return repository.loadSessionsByListId(sessionsIds);
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    return await repository.getSpeakersForEventId(eventId);
  }
}
