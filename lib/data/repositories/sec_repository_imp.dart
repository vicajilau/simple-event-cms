import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoaderManager dataLoader = getIt<DataLoaderManager>();

  //load items
  @override
  Future<Result<List<Event>>> loadEvents() async {
    try {
      final events = await dataLoader.loadEvents();
      return Result.ok(events);
    } on CertainException catch (e) {
      debugPrint('Error in loadEvents: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadEvents: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadEvents: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<Speaker>>> loadESpeakers() async {
    try {
      final speakers = await dataLoader.loadSpeakers();
      return Result.ok(speakers ?? []);
    } on CertainException catch (e) {
      debugPrint('Error in loadESpeakers: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadESpeakers: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadESpeakers: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<Sponsor>>> loadSponsors() async {
    try {
      final sponsors = await dataLoader.loadSponsors();
      return Result.ok(sponsors);
    } on CertainException catch (e) {
      debugPrint('Error in loadSponsors: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadSponsors: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadSponsors: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  //update Items
  @override
  Future<Result<void>> saveEvent(Event event) async {
    try {
      await DataUpdate.addItemAndAssociations(event, event.uid);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveEvent: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveEvent: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveEvent: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveTracks(List<Track> tracks) async {
    try {
      final allTracks = (await dataLoader.loadAllTracks()).where(
        (track) => track.eventUid == tracks.first.eventUid,
      );
      for (final track in tracks) {
        if (allTracks.any(
          (existingTrack) =>
              existingTrack.name.trim().toLowerCase() ==
              track.name.trim().toLowerCase(),
        )) {
          return Result.error(
            NetworkException(
              'A track with the name "${track.name}" already exists.',
            ),
          );
        }
      }
      await DataUpdate.addItemListAndAssociations(tracks);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveTracks: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveTracks: $e');
      return Result.error(
        NetworkException('Error in saveTracks, please try again'),
      );
    } catch (e) {
      debugPrint('Error in saveTracks: $e');
      return Result.error(
        NetworkException('Error in saveTracks, please try again'),
      );
    }
  }

  @override
  Future<Result<void>> saveAgendaDays(
    List<AgendaDay> agendaDays,
    String eventUID, {
    bool overrideAgendaDays = false,
  }) async {
    try {
      var allAgendaDays = (await dataLoader.loadAllDays())
          .where((agendaDay) => agendaDay.eventsUID.contains(eventUID))
          .toList();
      var thereAreAgendaDaysNotIncluded = allAgendaDays
          .where(
            (agendaDay) =>
                !agendaDays
                    .map((agendaDayToSave) => agendaDayToSave.uid)
                    .contains(agendaDay.uid) &&
                agendaDay.trackUids?.isNotEmpty == true &&
                agendaDay.resolvedTracks
                        ?.expand((track) => track.resolvedSessions)
                        .isNotEmpty ==
                    true,
          )
          .toList()
          .isNotEmpty;
      if (thereAreAgendaDaysNotIncluded && !overrideAgendaDays) {
        debugPrint(
          'There are sessions in days that are not included in the agenda days of the event, please delete them and try again',
        );
        return Result.error(
          NetworkException(
            'There are sessions in days that are not included in the agenda days of the event, please delete them and try again',
          ),
        );
      }

      await DataUpdate.addItemListAndAssociations(
        agendaDays,
        overrideData: overrideAgendaDays,
      );
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveAgendaDays: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveAgendaDays: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveAgendaDays: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveSpeaker(Speaker speaker, String? parentId) async {
    try {
      await DataUpdate.addItemAndAssociations(speaker, parentId);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveSpeaker: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveSponsor(Sponsor sponsor, String parentId) async {
    try {
      await DataUpdate.addItemAndAssociations(sponsor, parentId);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveSponsor: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveSponsor: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveSponsor: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> addSession(Session session, String trackUID) async {
    try {
      await DataUpdate.addItemAndAssociations(session, trackUID);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in addSession: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in addSession: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in addSession: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> addSpeaker(String eventId, Speaker speaker) async {
    try {
      await DataUpdate.addItemAndAssociations(speaker, eventId);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in addSpeaker: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in addSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in addSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveTrack(Track track, String agendaDayId) async {
    try {
      final allTracks = (await dataLoader.loadAllTracks()).where(
        (track) => track.eventUid == track.eventUid,
      );
      if (allTracks.any(
        (existingTrack) =>
            existingTrack.name.trim().toLowerCase() ==
            track.name.trim().toLowerCase(),
      )) {
        return Result.error(
          NetworkException(
            'A track with the name "${track.name}" already exists.',
          ),
        );
      }

      await DataUpdate.addItemAndAssociations(track, agendaDayId);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveTrack: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveTrack: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveTrack: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  //delete items
  @override
  Future<Result<void>> removeEvent(String eventId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(eventId, "Event");
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in removeEvent: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in removeEvent: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in removeEvent: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeAgendaDay(
    String agendaDayId,
    String eventUID,
  ) async {
    try {
      await DataUpdate.deleteItemAndAssociations(
        agendaDayId,
        "AgendaDay",
        eventUID: eventUID,
      );
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in removeAgendaDay: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in removeAgendaDay: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in removeAgendaDay: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeSpeaker(String speakerId, String eventUID) async {
    try {
      await DataUpdate.deleteItemAndAssociations(
        speakerId,
        "Speaker",
        eventUID: eventUID,
      );
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in removeSpeaker: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in removeSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in removeSpeaker: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeSponsor(String sponsorId) async {
    try {
      await DataUpdate.deleteItemAndAssociations(sponsorId, "Sponsor");
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in removeSponsor: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in removeSponsor: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in removeSponsor: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteSession(
    String sessionId, {
    String? agendaDayUID,
  }) async {
    try {
      await DataUpdate.deleteItemAndAssociations(
        sessionId,
        "Session",
        agendaDayUidSelected: agendaDayUID ?? "",
      );
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in deleteSession: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in deleteSession: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in deleteSession: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<AgendaDay>> loadAgendaDayById(String agendaDayById) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(
        agendaDays.firstWhere((agendaDay) => agendaDay.uid == agendaDayById),
      );
    } on CertainException catch (e) {
      debugPrint('Error in loadAgendaDayById: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadAgendaDayById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadAgendaDayById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<Track>> loadTrackById(String trackId) async {
    try {
      var tracks = await dataLoader.loadAllTracks();
      return Result.ok(tracks.firstWhere((track) => track.uid == trackId));
    } on CertainException catch (e) {
      debugPrint('Error in loadTrackById: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadTrackById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadTrackById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventId(String eventId) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      return Result.ok(
        agendaDays
            .where((agendaDay) => agendaDay.eventsUID.contains(eventId))
            .toList(),
      );
    } on CertainException catch (e) {
      debugPrint('Error in loadAgendaDayByEventId: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadAgendaDayByEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadAgendaDayByEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<AgendaDay>>> loadAgendaDayByEventIdFiltered(
    String eventId,
  ) async {
    try {
      var agendaDays = await dataLoader.loadAllDays();
      var tracks = (await dataLoader.loadAllTracks())
          .toList()
          .where((track) => track.eventUid != eventId)
          .toList();
      agendaDays = agendaDays.map((agendaDay) {
        agendaDay.resolvedTracks?.removeWhere(
          (track) => tracks.map((track) => track.uid).contains(track.uid),
        );
        return agendaDay;
      }).toList();
      return Result.ok(
        agendaDays
            .where(
              (agendaDay) =>
                  agendaDay.eventsUID.contains(eventId) &&
                  agendaDay.resolvedTracks != null &&
                  agendaDay.resolvedTracks!.isNotEmpty &&
                  agendaDay.resolvedTracks!
                      .expand((track) => track.resolvedSessions)
                      .isNotEmpty &&
                  agendaDay.resolvedTracks!
                      .expand((track) => track.resolvedSessions)
                      .toList()
                      .where((session) => session.agendaDayUID == agendaDay.uid)
                      .toList()
                      .isNotEmpty,
            )
            .toList(),
      );
    } on CertainException catch (e) {
      debugPrint('Error in loadAgendaDayByEventIdFiltered: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadAgendaDayByEventIdFiltered: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadAgendaDayByEventIdFiltered: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<Track>>> loadTracksByEventId(eventId) async {
    try {
      var tracks = await dataLoader.loadAllTracks();

      return Result.ok(
        tracks.where((track) => eventId == track.eventUid).toList(),
      );
    } on CertainException catch (e) {
      debugPrint('Error in loadTracksByEventId: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadTracksByEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadTracksByEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<Track>>> loadTracks() async {
    try {
      var tracks = await dataLoader.loadAllTracks();

      return Result.ok(tracks);
    } on CertainException catch (e) {
      debugPrint('Error in loadTracks: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadTracks: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadTracks: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<Event>> loadEventById(String eventId) async {
    try {
      final events = await dataLoader.loadEvents();
      return Result.ok(events.firstWhere((event) => event.uid == eventId));
    } on CertainException catch (e) {
      debugPrint('Error in loadEventById: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in loadEventById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in loadEventById: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId) async {
    try {
      final speakers = await dataLoader.loadSpeakers();
      if (speakers != null && speakers.isNotEmpty == true) {
        return Result.ok(
          speakers
              .where((speaker) => speaker.eventUIDS.contains(eventId))
              .toList(),
        );
      } else {
        return Result.ok([]);
      }
    } on CertainException catch (e) {
      debugPrint('Error in getSpeakersForEventId: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in getSpeakersForEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in getSpeakersForEventId: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveAgendaDay(
    AgendaDay agendaDay,
    String eventUID,
  ) async {
    try {
      await DataUpdate.addItemAndAssociations(agendaDay, eventUID);
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveAgendaDay: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveAgendaDay: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveAgendaDay: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeTrack(String trackUID) async {
    try {
      await DataUpdate.deleteItemAndAssociations(trackUID, "Track");
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in removeTrack: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in removeTrack: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in removeTrack: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveConfig(Config config) async {
    try {
      await DataUpdate.addItemAndAssociations(config, "");
      return Result.ok(null);
    } on CertainException catch (e) {
      debugPrint('Error in saveConfig: $e');
      return Result.error(NetworkException(e.message));
    } on Exception catch (e) {
      debugPrint('Error in saveConfig: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    } catch (e) {
      debugPrint('Error in saveConfig: $e');
      return Result.error(
        NetworkException(
          'An unexpected error occurred. Please try again later.',
        ),
      );
    }
  }
}
