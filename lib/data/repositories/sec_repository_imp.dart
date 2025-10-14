import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader = getIt<DataLoader>();
  List<Event> _events = [];

  //load items
  @override
  Future<Result<List<Event>>> loadEvents() async {
    try {

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
  Future<void> saveTracks(List<Track> tracks) async {
    await DataUpdate.addItemListAndAssociations(tracks);
  }

  @override
  Future<void> saveAgendaDays(List<AgendaDay> agendaDays) async {
    await DataUpdate.addItemListAndAssociations(agendaDays);
  }

  @override
  Future<void> saveAgenda(Agenda agenda, String eventId) async {
    await DataUpdate.addItemAndAssociations(agenda, eventId);
  }

  @override
  Future<void> saveAgendaDayById(AgendaDay agendaDay, String agendaId) async {
    await DataUpdate.addItemAndAssociations(agendaDay, agendaId);
  }

  @override
  Future<void> saveSpeaker(Speaker speaker, String parentId) async {
    await DataUpdate.addItemAndAssociations(speaker, parentId);
  }

  @override
  Future<void> saveSponsor(Sponsor sponsor, String parentId) async {
    await DataUpdate.addItemAndAssociations(sponsor, parentId);
  }

  @override
  Future<void> addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  ) async {
    DataUpdate.addItemAndAssociations(session, agendaDayId);
  }

  @override
  Future<void> editSession(Session session, String parentId) async {
    DataUpdate.addItemAndAssociations(session, parentId);
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
    DataUpdate.deleteItemAndAssociations(sessionId, Session);
  }

  @override
  Future<Result<AgendaDay>> loadAgendaDayById(String agendaDayById) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(agendaDays.firstWhere((agendaDay) => agendaDay.uid == agendaDayById));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<Track>> loadTrackById(String trackId) async {
    try {
      var tracks = await dataLoader.loadAllTracks();
      return Result.ok(tracks.firstWhere((track) => track.uid == trackId));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<AgendaDay>>> loadAgendaDayByListId(
    List<String> agendaDayIds,
  ) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(agendaDays
          .where((agendaDay) => agendaDayIds.contains(agendaDay.uid))
          .toList());
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Track>>> loadTracksByListId(List<String> tracksIds) async {
    try {
      var tracks = await dataLoader.loadAllTracks();

      return Result.ok(tracks.where((track) => tracksIds.contains(track.uid)).toList());
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Session>>> loadSessionsByListId(List<String> sessionsIds) async {
    try {
      var sessions = await dataLoader.loadAllSessions();

      return Result.ok(sessions
          .where((session) => sessionsIds.contains(session.uid))
          .toList());
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<Event>> loadEventById(String eventId) async {
    try {
      if (_events.isNotEmpty) {
        return Result.ok(_events.firstWhere((event) => event.uid == eventId));
      }

      final events = await dataLoader.loadEvents();
      _events = events;
      return Result.ok(events.firstWhere((event) => event.uid == eventId));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    try {
      List<Speaker> speakersEvent = [];
      final speakers = await dataLoader.loadSpeakers();
      final events = await dataLoader.loadEvents();
      final event = events.firstWhere((event) => event.uid == eventId);
      for (var uidSpeaker in event.speakersUID) {
        speakersEvent.add(speakers.firstWhere((speaker) => speaker.uid == uidSpeaker));
      }

      return speakersEvent.toList();
    } on Exception catch (_) {
      return [];
    } catch (e) {
      return [];
    }
  }
}
