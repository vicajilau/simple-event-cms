import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import '../../core/utils/result.dart';

abstract class AgendaUseCase {
  Future<void> saveEvent(Event event);
  Future<void> saveSpeaker(Speaker speaker,String eventId);
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String eventId);
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId);
  Future<Result<List<AgendaDay>>> getAgendaDayByEventId(String eventId);
  Future<Result<List<Session>>> getSessionsByListId(List<String> sessionsIds);
  Future<Result<List<Track>>> getTracks();
  Future<Result<Track>> getTrackById(String trackId);
  Future<void> addSession(
    Session session,
  );
  Future<void> addSpeaker(String eventId, Speaker speaker);
  void editSession(Session session, String parentId);
  void deleteSessionFromAgendaDay(String sessionId);
  Future<Result<Event>> loadEvent(String eventId);

  Future<List<Speaker>> getSpeakersForEventId(String eventId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<void> saveSpeaker(Speaker speaker,String eventId) async {
    await repository.saveSpeaker(speaker,eventId);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String eventId) async {
    await repository.saveAgendaDayById(agendaDay, eventId);
  }

  @override
  Future<void> addSession(
    Session session,
  ) async {
    await repository.addSession(session);
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
  Future<void> addSpeaker(String eventId, Speaker speaker) async {
    return await repository.addSpeaker(eventId, speaker);
  }

  @override
  Future<void> saveEvent(Event event) async {
   await repository.saveEvent(event);

  }
}
