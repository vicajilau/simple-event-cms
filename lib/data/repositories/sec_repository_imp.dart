import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader = getIt<DataLoader>();
  List<Event> _events = [];

  final DataUpdateInfo dataUpdateInfo = DataUpdateInfo(
    dataCommons: CommonsServicesImp(),
  );

  @override
  Future<Result<List<Event>>> loadEvents() async {
    try {
      if (_events.isNotEmpty) {
        return Result.ok(_events);
      }

      final events = await dataLoader.loadEvents();
      _events = events;
      return Result.ok(events);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Agenda>>> loadEAgendas() async {
    try {
      final agenda = await dataLoader.getFullAgendaData();
      return Result.ok(agenda);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Speaker>>> loadESpeakers() async {
    try {
      final speakers = await dataLoader.loadSpeakers();
      return Result.ok(speakers);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Sponsor>>> loadSponsors() async {
    try {
      final sponsors = await dataLoader.loadSponsors();
      return Result.ok(sponsors);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  //update Items
  @override
  Future<void> saveEvent(Event event) async {
    await DataUpdate.addItemAndAssociations(event, event.uid);
  }

  @override
  Future<void> saveAgenda(Agenda agenda, String eventId) async {
    await ManagerData.addItemAndAssociations(
      agenda,
      eventId,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    await ManagerData.addItemAndAssociations(
      agendaDay,
      agendaId,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> saveSpeaker(Speaker speaker, String parentId) async {
    await ManagerData.addItemAndAssociations(
      speaker,
      parentId,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> saveSponsor(Sponsor sponsor, String parentId) async {
    await ManagerData.addItemAndAssociations(
      sponsor,
      parentId,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> removeAgenda(String agendaId) async {
    await ManagerData.deleteItemAndAssociations(
      agendaId,
      agendaId.runtimeType,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> removeAgendaDay(String agendaDayId, String agendaId) async {
    await ManagerData.deleteItemAndAssociations(
      agendaDayId,
      AgendaDay,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> removeSpeaker(String speakerId) async {
    await ManagerData.deleteItemAndAssociations(
      speakerId,
      Speaker,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> removeSponsor(String sponsorId) async {
    ManagerData.deleteItemAndAssociations(
      sponsorId,
      Sponsor,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  ) async {
    ManagerData.addItemAndAssociations(
      session,
      agendaDayId,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> deleteSessionFromAgendaDay(String sessionId) async {
    ManagerData.deleteItemAndAssociations(
      sessionId,
      Session,
      dataLoader,
      dataUpdateInfo,
    );
  }

  @override
  Future<void> editSession(Session session, String parentId) async {
    ManagerData.addItemAndAssociations(
      session,
      parentId,
      dataLoader,
      dataUpdateInfo,
    );
  }
}
