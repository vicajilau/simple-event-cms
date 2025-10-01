import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader = getIt<DataLoader>();

  //load items
  @override
  Future<List<Event>> loadEvents() async {
    return dataLoader.loadEvents();
  }

  @override
  Future<List<Agenda>> loadEAgendas() async {
    return await dataLoader.getFullAgendaData();
  }

  @override
  Future<List<Speaker>> loadESpeakers() async {
    return await dataLoader.loadSpeakers();
  }

  @override
  Future<List<Sponsor>> loadSponsors() async {
    return await dataLoader.loadSponsors();
  }

  //update Items
  @override
  Future<void> saveEvent(Event event) async {
    await DataUpdate.addItemAndAssociations(event, event.uid);
  }

  @override
  Future<void> saveAgenda(Agenda agenda,String eventId) async {
    await DataUpdate.addItemAndAssociations(agenda, eventId);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    await DataUpdate.addItemAndAssociations(agendaDay, agendaId);
  }

  @override
  Future<void> saveSpeaker(Speaker speaker,String parentId) async {
    await DataUpdate.addItemAndAssociations(speaker, parentId);
  }

  @override
  Future<void> saveSponsor(Sponsor sponsor,String parentId) async {
    await DataUpdate.addItemAndAssociations(sponsor, parentId);
  }

  @override
  Future<void> addSessionIntoAgenda(
      String agendaId,
      String agendaDayId,
      String trackId,
      Session session,
      ) async {
    DataUpdate.addItemAndAssociations(session,agendaDayId);
  }

  @override
  Future<void> editSession(Session session,String parentId) async {
    DataUpdate.addItemAndAssociations(session,parentId);
  }

  //delete items
  @override
  Future<void> removeEvent(String eventId) async {
    await DataUpdate.deleteItemAndAssociations(eventId, Event);
  }

  @override
  Future<void> removeAgenda(String agendaId) async {
    await DataUpdate.deleteItemAndAssociations(agendaId, Agenda);
  }

  @override
  Future<void> removeAgendaDay(String agendaDayId, String agendaId) async {
    await DataUpdate.deleteItemAndAssociations(agendaDayId, AgendaDay);
  }

  @override
  Future<void> removeSpeaker(String speakerId) async {
    await DataUpdate.deleteItemAndAssociations(speakerId, Speaker);
  }

  @override
  Future<void> removeSponsor(String sponsorId) async {
    DataUpdate.deleteItemAndAssociations(sponsorId, Sponsor);
  }

  @override
  Future<void> deleteSessionFromAgendaDay(String sessionId) async {
    DataUpdate.deleteItemAndAssociations(sessionId,Session);
  }

  @override
  Future<AgendaDay> loadAgendaDayById(String agendaDayById) async {
    var agendaDays = await dataLoader.loadAllDays();
    return agendaDays.firstWhere((agendaDay) => agendaDay.uid == agendaDayById);
  }

  @override
  Future<Track> loadTrackById(String trackId) async {
    var tracks = await dataLoader.loadAllTracks();
    return tracks.firstWhere((track) => track.uid == trackId);
  }


}
