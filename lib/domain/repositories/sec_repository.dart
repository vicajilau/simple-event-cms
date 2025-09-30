import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';

abstract class SecRepository {
  Future<Result<List<Event>>> loadEvents();
  Future<Result<List<Agenda>>> loadEAgendas();
  Future<Result<List<Speaker>>> loadESpeakers();
  Future<Result<List<Sponsor>>> loadSponsors();
  Future<void> saveEvent(Event event);
  Future<void> saveSpeaker(Speaker speaker, String parentId);
  Future<void> removeSpeaker(String speakerId);
  Future<void> saveAgenda(Agenda agenda, String eventId);
  Future<void> removeAgenda(String agendaId);
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  Future<void> removeAgendaDay(String agendaDayId, String agendaId);
  Future<void> addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  );
  Future<void> editSession(Session session, String parentId);
  Future<void> deleteSessionFromAgendaDay(String sessionId);
  Future<void> saveSponsor(Sponsor sponsor, String parentId);
  Future<void> removeSponsor(String sponsorId);
}
