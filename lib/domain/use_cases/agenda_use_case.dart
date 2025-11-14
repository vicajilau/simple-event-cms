import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../core/utils/result.dart';

abstract class AgendaUseCase {
  Future<Result<void>> saveEvent(Event event);
  Future<Result<void>> saveSpeaker(Speaker speaker, String eventId);
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId);
  Future<Result<List<AgendaDay>>> getAgendaDayByEventId(String eventId);
  Future<Result<List<AgendaDay>>> getAgendaDayByEventIdFiltered(String eventId);
  Future<Result<List<Track>>> getTracks();
  Future<Result<List<Track>>> getTracksByEventId(String eventId);
  Future<Result<void>> updateTrack(Track track, String agendaDayId);
  Future<Result<void>> updateAgendaDay(AgendaDay agendaDay, String eventUID);
  Future<Result<Track>> getTrackById(String trackId);
  Future<Result<void>> addSession(Session session, String trackUID);
  Future<Result<void>> addSpeaker(String eventId, Speaker speaker);
  Future<Result<void>> deleteSession(String sessionId, {String? agendaDayUID});
  Future<Result<Event>> loadEvent(String eventId);
  Future<Result<void>> removeTrack(String trackID, {var overrideTrack = false});

  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<void>> saveSpeaker(Speaker speaker, String eventId) async {
    return await repository.saveSpeaker(speaker, eventId);
  }

  @override
  Future<Result<void>> addSession(Session session, String trackUID) async {
    return await repository.addSession(session, trackUID);
  }

  @override
  Future<Result<void>> deleteSession(
    String sessionId, {
    String? agendaDayUID,
  }) async {
    return await repository.deleteSession(
      sessionId,
      agendaDayUID: agendaDayUID,
    );
  }

  @override
  Future<Result<AgendaDay>> getAgendaDayById(String agendaDayId) async {
    return await repository.loadAgendaDayById(agendaDayId);
  }

  @override
  Future<Result<Track>> getTrackById(String trackId) async {
    return await repository.loadTrackById(trackId);
  }

  @override
  Future<Result<Event>> loadEvent(String eventId) async {
    return await repository.loadEventById(eventId);
  }

  @override
  Future<Result<List<AgendaDay>>> getAgendaDayByEventId(String eventId) async {
    return await repository.loadAgendaDayByEventId(eventId);
  }

  @override
  Future<Result<List<AgendaDay>>> getAgendaDayByEventIdFiltered(
    String eventId,
  ) async {
    return await repository.loadAgendaDayByEventIdFiltered(eventId);
  }

  @override
  Future<Result<List<Track>>> getTracks() async {
    return await repository.loadTracks();
  }

  @override
  Future<Result<List<Track>>> getTracksByEventId(String eventId) async {
    return await repository.loadTracksByEventId(eventId);
  }

  @override
  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId) async {
    return await repository.getSpeakersForEventId(eventId);
  }

  @override
  Future<Result<void>> addSpeaker(String eventId, Speaker speaker) async {
    return await repository.addSpeaker(eventId, speaker);
  }

  @override
  Future<Result<void>> saveEvent(Event event) async {
    return await repository.saveEvent(event);
  }

  @override
  Future<Result<void>> updateTrack(Track track, String agendaDayId) async {
    return await repository.saveTrack(track, agendaDayId);
  }

  @override
  Future<Result<void>> updateAgendaDay(
    AgendaDay agendaDay,
    String eventUID,
  ) async {
    return await repository.saveAgendaDay(agendaDay, eventUID);
  }

  @override
  Future<Result<void>> removeTrack(
    String trackID, {
    var overrideTrack = false,
  }) async {
    return await repository.removeTrack(trackID);
  }
}
