import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../core/utils/result.dart';

abstract class AgendaUseCase {
  Future<Result<Agenda?>> getAgendaById(String id);
  void saveAgenda(Agenda agenda, String eventId);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  Result<Future<AgendaDay>> getAgendaDayById(String agendaDayId);
  Result<Future<List<AgendaDay>>> getAgendaDayByListId(List<String> agendaDayIds);
  Result<Future<List<Session>>> getSessionsByListId(List<String> sessionsIds);
  Result<Future<List<Track>>> getTracksByListId(List<String> tracksIds);
  Result<Future<Track>> getTrackById(String trackId);
  void addSessionIntoAgenda(
      String agendaId,
      String agendaDayId,
      String trackId,
      Session session,
      );
  void editSession(Session session,String parentId);
  void deleteSessionFromAgendaDay(String sessionId);
  Result<Future<Event>> loadEvent(String eventId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<Agenda?>> getAgendaById(String id) async {
    final result = await repository.loadEAgendas();
    switch (result) {
      case Ok<List<Agenda>>():
        return Result.ok(result.value.firstWhere((event) => event.uid == id));
      case Error():
        return Result.error(result.error);
    }
    return Result.error(result.error);
  }

  @override
  void saveAgenda(Agenda agenda, String eventId) {
    repository.saveAgenda(agenda, eventId);
  }

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    repository.saveAgendaDayById(agendaDay, agendaId);
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
  Result<Future<AgendaDay>> getAgendaDayById(String agendaDayId) {
    return repository.loadAgendaDayById(agendaDayId);
  }

  @override
  Result<Future<Track>> getTrackById(String trackId) {
    return repository.loadTrackById(trackId);
  }

  @override
  Result<Future<Event>> loadEvent(String eventId) {
    return repository.loadEvents().then((eventS) => eventS.firstWhere((event) => event.uid == eventId));
  }

  @override
  Result<Future<List<AgendaDay>>> getAgendaDayByListId(List<String> agendaDayIds) {
    return repository.loadAgendaDayByListId(agendaDayIds);
  }

  @override
  Result<Future<List<Track>>> getTracksByListId(List<String> tracksIds) {
    return repository.loadTracksByListId(tracksIds);
  }

  @override
  Result<Future<List<Session>>> getSessionsByListId(List<String> sessionsIds) {
    return repository.loadSessionsByListId(sessionsIds);
  }
}

