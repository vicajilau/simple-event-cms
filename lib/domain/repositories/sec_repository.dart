import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';

abstract class SecRepository {
  Future<Result<List<Event>>> loadEvents();
  Future<Result<Event>> loadEventById(String eventId);
  Future<Result<List<Speaker>>> loadESpeakers();
  Future<Result<List<Sponsor>>> loadSponsors();
  Future<Result<AgendaDay>> loadAgendaDayById(String agendaDayId);
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventId(String eventId);
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventIdFiltered(
    String eventId,
  );
  Future<Result<List<Track>>> loadTracksByEventId(String eventId);
  Future<Result<List<Track>>> loadTracks();
  Future<Result<Track>> loadTrackById(String trackId);
  Future<Result<void>> saveEvent(Event event);
  Future<Result<void>> saveConfig(Config config);
  Future<Result<void>> saveTracks(List<Track> tracks);
  Future<Result<void>> saveTrack(Track track, String agendaDayId);
  Future<Result<void>> saveAgendaDays(
    List<AgendaDay> agendaDays,
    String eventUID, {
    bool overrideAgendaDays = false,
  });
  Future<Result<void>> saveSpeaker(Speaker speaker, String? parentId);
  Future<Result<void>> removeSpeaker(String speakerId, String eventUID);
  Future<Result<void>> saveAgendaDay(AgendaDay agendaDay, String eventUID);
  Future<Result<void>> removeAgendaDay(String agendaDayId, String eventUID);
  Future<Result<void>> addSession(Session session, String trackUID);
  Future<Result<void>> addSpeaker(String eventId, Speaker speaker);
  Future<Result<void>> deleteSession(String sessionId, {String? agendaDayUID});
  Future<Result<void>> saveSponsor(Sponsor sponsor, String parentId);
  Future<Result<void>> removeSponsor(String sponsorId);
  Future<Result<void>> removeEvent(String eventId);
  Future<Result<void>> removeTrack(String trackUID);

  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId);
}
