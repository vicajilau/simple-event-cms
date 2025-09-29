import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/manager_data.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../remote_data/common/commons_services.dart';
import '../remote_data/update_data/data_update_info.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader = getIt<DataLoader>();
  final DataUpdateInfo dataUpdateInfo = DataUpdateInfo(
    dataCommons: CommonsServices(),
  );

  @override
  Future<List<Event>> loadEvents() async {
    return dataLoader.loadEvents();
  }

  @override
  Future<List<Agenda>> loadEAgendas() async {
    return await dataLoader.loadAgendaStructures();
  }

  @override
  Future<List<Speaker>> loadESpeakers() async {
    return await dataLoader.loadSpeakers();
  }

  @override
  Future<List<Sponsor>> loadSponsors() async {
    return await dataLoader.loadSponsors();
  }

  @override
  Future<void> saveEvent(Event event) async {
    await dataUpdateInfo.updateEvent(event);
  }

  @override
  Future<void> saveAgenda(Agenda agenda) async {
    await dataUpdateInfo.updateAgenda(agenda);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    Agenda? agendaFounded;
    final agendas = await loadEAgendas();
    agendaFounded = agendas.firstWhere(
      (agenda) => agenda.uid == agendaId,
      orElse: () => throw Exception("Agenda not founded"),
    );
    agendaFounded.resolvedDays?.add(agendaDay);
    await dataUpdateInfo.updateAgenda(agendaFounded);
  }

  @override
  Future<void> saveSpeaker(Speaker speaker,String parentId) async {
    await ManagerData.addItemAndAssociations(speaker, parentId, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> saveSponsor(Sponsor sponsor,String parentId) async {
    await ManagerData.addItemAndAssociations(sponsor, parentId, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> removeAgenda(String agendaId) async {
    await ManagerData.deleteItemAndAssociations(agendaId, agendaId.runtimeType, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> removeAgendaDay(String agendaDayId, String agendaId) async {
    await ManagerData.deleteItemAndAssociations(agendaDayId, AgendaDay, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> removeSpeaker(String speakerId) async {
    await ManagerData.deleteItemAndAssociations(speakerId, Speaker, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> removeSponsor(String sponsorId) async {
    ManagerData.deleteItemAndAssociations(sponsorId, Sponsor, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> addSessionIntoAgenda(
      String agendaId,
      String agendaDayId,
      String trackId,
      Session session,
      ) async {
    ManagerData.addItemAndAssociations(session,agendaDayId, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> deleteSessionFromAgendaDay(String sessionId) async {
    ManagerData.deleteItemAndAssociations(sessionId,Session, dataLoader, dataUpdateInfo);
  }

  @override
  Future<void> editSession(Session session,String parentId) async {
    ManagerData.addItemAndAssociations(session,parentId, dataLoader, dataUpdateInfo);
  }
}
