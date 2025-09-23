import 'package:sec/core/models/models.dart';

abstract class SecRepository {
  Future<List<Event>> loadEvents();
  Future<List<Agenda>> loadEAgendas();
  Future<List<Speaker>> loadESpeakers();
  Future<List<Sponsor>> loadSponsors();
  Future<void> saveEvent(Event event);
  Future<void> saveSpeaker(Speaker speaker);
  Future<void> removeSpeaker(String speakerId);
  Future<void> saveAgenda(Agenda agenda);
  Future<void> removeAgenda(String agendaId);
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  Future<void> removeAgendaDayById(String agendaDayId, String agendaId);
  Future<void> addSessionToAgendaDay(String agendaId,String agendaDayId,String trackId,Session session);
  Future<void> editSessionInAgendaDay(String agendaId,String agendaDayId,String trackId,Session session);
  Future<void> deleteSessionFromAgendaDay(String agendaId,String agendaDayId,String trackId,Session session);
  Future<void> saveSponsor(Sponsor sponsor);
  Future<void> removeSponsor(String sponsorId);
}
