import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader = getIt<DataLoader>();

  //load items
  @override
  Future<Result<List<Event>>> loadEvents() async {
    try {
      final events = await dataLoader.loadEvents();
      return Result.ok(events);
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
  Future<Result<void>> saveEvent(Event event) async {
    try{
    await DataUpdate.addItemAndAssociations(event, event.uid);
    return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveTracks(List<Track> tracks) async {
    try{
    await DataUpdate.addItemListAndAssociations(tracks);
    return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveAgendaDays(List<AgendaDay> agendaDays) async {
    try{
    await DataUpdate.addItemListAndAssociations(agendaDays);
    return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveSpeaker(Speaker speaker, String? parentId) async {
    try {
      await DataUpdate.addItemAndAssociations(speaker, parentId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveSponsor(Sponsor sponsor, String parentId) async {
    try{
    await DataUpdate.addItemAndAssociations(sponsor, parentId);
    return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> addSession(Session session,String trackUID) async {
    try{
    await DataUpdate.addItemAndAssociations(session, trackUID);
    return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> addSpeaker(String eventId, Speaker speaker) async {
    try {
      await DataUpdate.addItemAndAssociations(speaker, eventId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveTrack(Track track,String eventId) async {
    try {
      await DataUpdate.addItemAndAssociations(track,eventId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  //delete items
  @override
  Future<Result<void>> removeEvent(String eventId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(eventId, Event);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> removeAgendaDay(String agendaDayId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(agendaDayId, AgendaDay);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> removeSpeaker(String speakerId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(speakerId, Speaker);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> removeSponsor(String sponsorId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(sponsorId, Sponsor);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSessionFromAgendaDay(String sessionId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(sessionId, Session);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<AgendaDay>> loadAgendaDayById(String agendaDayById) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(
        agendaDays.firstWhere((agendaDay) => agendaDay.uid == agendaDayById),
      );
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
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventId(String eventId) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(
        agendaDays.where((agendaDay) => eventId == agendaDay.eventUID).toList(),
      );
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventIdFiltered(String eventId) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(
        agendaDays.where((agendaDay) => eventId == agendaDay.eventUID && agendaDay.trackUids!= null && agendaDay.trackUids!.isNotEmpty).toList(),
      );
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Track>>> loadTracksByEventId(eventId) async {
    try {
      var tracks = await dataLoader.loadAllTracks();

      return Result.ok(
        tracks.where((track) => eventId == track.eventUid).toList(),
      );
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Track>>> loadTracks() async {
    try {
      var tracks = await dataLoader.loadAllTracks();

      return Result.ok(tracks);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<Event>> loadEventById(String eventId) async {
    try {
     final events = await dataLoader.loadEvents();
      return Result.ok(events.firstWhere((event) => event.uid == eventId));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId) async {
    try {
      final speakers = await dataLoader.loadSpeakers();
      return Result.ok(
        speakers.where((speaker) => speaker.eventUID == eventId).toList(),
      );
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }

  @override
  Future<Result<void>> saveAgendaDay(AgendaDay agendaDay, String eventUID) async {
    try {
      await DataUpdate.addItemAndAssociations(agendaDay,eventUID);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Something really unknown: $e'));
    }
  }
}
