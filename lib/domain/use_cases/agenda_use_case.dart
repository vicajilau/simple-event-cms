import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../core/utils/result.dart';

abstract class AgendaUseCase {
  Future<Result<Agenda>> getAgendaById(String id);
  Future<void> saveAgenda(Agenda agenda, String eventId);
  Future<void> saveSpeaker(Speaker speaker,String eventId);
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId);
  Future<Result<List<AgendaDay>>> getAgendaDayByEventId(String eventId);
  Future<Result<List<Session>>> getSessionsByListId(List<String> sessionsIds);
  Future<Result<List<Track>>> getTracks();
  Future<Result<Track>> getTrackById(String trackId);
  Future<void> addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  );
  Future<void> addSpeakerIntoAgenda(String agendaId, Speaker speaker);
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
  Future<void> saveAgenda(Agenda agenda, String eventId) async {
    await repository.saveAgenda(agenda, eventId);
  }

  @override
  Future<void> saveSpeaker(Speaker speaker,String eventId) async {
    await repository.saveSpeaker(speaker,eventId);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    await repository.saveAgendaDayById(agendaDay, agendaId);
  }

  @override
  Future<void> addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  ) async {
    await repository.addSessionIntoAgenda(agendaId, agendaDayId, trackId, session);
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
  Future<Result<List<AgendaDay>>> getAgendaDayByEventId(String eventId) async {
    return await repository.loadAgendaDayByEventId(eventId);
  }

  @override
  Future<Result<List<Track>>> getTracks() async {
    return await repository.loadTracks();
  }

  @override
  Future<Result<List<Session>>> getSessionsByListId(List<String> sessionsIds) {
    return repository.loadSessionsByListId(sessionsIds);
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    return await repository.getSpeakersForEventId(eventId);
  }

  @override
  Future<void> addSpeakerIntoAgenda(String agendaId, Speaker speaker) async {
    return await repository.addSpeakerIntoAgenda(agendaId, speaker);
  }
}
