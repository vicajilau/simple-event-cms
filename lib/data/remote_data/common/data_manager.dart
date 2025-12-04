import 'package:flutter/material.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';

class DataUpdate {
  static DataLoaderManager dataLoader = getIt<DataLoaderManager>();
  static DataUpdateManager dataUpdateInfo = DataUpdateManager(
    dataCommons: CommonsServicesImp(),
  );

  static Future<void> deleteItemAndAssociations(
    String itemId,
    String itemType, {
    String? eventUID,
    String agendaDayUidSelected = "",
    bool overrideData = false,
  }) async {
    switch (itemType) {
      case "Event":
        await _deleteEvent(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Session":
        await _deleteSession(
          itemId,
          dataLoader,
          dataUpdateInfo,
          agendaDayUidSelected: agendaDayUidSelected,
        );
        break;
      case "Track":
        await _deleteTrack(
          itemId,
          dataLoader,
          dataUpdateInfo,
          overrideData = overrideData,
        );
        break;
      case "AgendaDay":
        await _deleteAgendaDay(
          itemId,
          dataLoader,
          dataUpdateInfo,
          eventUID.toString(),
        );
        break;
      case "Speaker":
        await _deleteSpeaker(
          itemId,
          dataLoader,
          dataUpdateInfo,
          eventUID.toString(),
        );
        break;
      case "Sponsor":
        await _deleteSponsor(itemId, dataUpdateInfo, dataLoader);
        break;
      default:
        throw Exception("Unsupported item type for deletion: $itemType");
    }
  }

  static Future<void> addItemAndAssociations(
    dynamic item, // Can be Session, Track, AgendaDay, Speaker, Sponsor
    String? parentId, // Can be Session, Track, AgendaDay, Speaker, Sponsor
  ) async {
    if (item is Event) {
      await _addEvent(item, dataLoader, dataUpdateInfo);
    } else if (item is Session) {
      await _addSession(item, dataLoader, dataUpdateInfo, parentId);
    } else if (item is Track) {
      await _addTrack(item, dataLoader, dataUpdateInfo, parentId);
    } else if (item is AgendaDay) {
      await _addAgendaDay(item, dataLoader, dataUpdateInfo, parentId);
    } else if (item is Speaker) {
      await _addSpeaker(item, dataLoader, dataUpdateInfo, parentId);
    } else if (item is Sponsor) {
      await _addSponsor(item, dataLoader, dataUpdateInfo, parentId);
    } else if (item is Config) {
      await _addOrganization(item, dataLoader, dataUpdateInfo, parentId);
    } else {
      throw Exception("Unsupported item type");
    }
  }

  static Future<void> addItemListAndAssociations(
    List<dynamic>
    items, { // Can be a list of Session, Track, AgendaDay, Speaker, Sponsor
    bool overrideData = false,
  }) async {
    if (items.isEmpty) return;

    if (items.first is Session) {
      await _addSessions(
        items.cast<Session>(),
        dataLoader,
        dataUpdateInfo,
        overrideData: overrideData,
      );
    } else if (items.first is Track) {
      await _addTracks(
        items.cast<Track>(),
        dataLoader,
        dataUpdateInfo,
        overrideData: overrideData,
      );
    } else if (items.first is AgendaDay) {
      await _addAgendaDays(
        items.cast<AgendaDay>(),
        dataLoader,
        dataUpdateInfo,
        overrideData: overrideData,
      );
    } else if (items.first is Speaker) {
      await _addSpeakers(
        items.cast<Speaker>(),
        dataLoader,
        dataUpdateInfo,
        overrideData: overrideData,
      );
    } else if (items.first is Sponsor) {
      await _addSponsors(
        items.cast<Sponsor>(),
        dataLoader,
        dataUpdateInfo,
        overrideData: overrideData,
      );
    } else {
      throw Exception("Unsupported item type list ");
    }
  }

  static Future<void> _addEvent(
    Event event,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
  ) async {
    await addItemListAndAssociations(event.tracks);
    await dataUpdateInfo.updateEvent(event);
    debugPrint("Event ${event.uid} added.");
  }

  static Future<void> _deleteEvent(
    String eventId,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
  ) async {
    await dataUpdateInfo.removeEvent(eventId);
    debugPrint("Event $eventId deleted.");
  }

  static Future<void> _addSession(
    Session session,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String? trackUID,
  ) async {
    await dataUpdateInfo.updateSession(session, trackUID);
    debugPrint("Session ${session.uid} added.");
  }

  static Future<void> _addSessions(
    List<Session> sessions,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    List<Session> allSessions = await dataLoader.loadAllSessions();
    final sessionMap = {for (var s in allSessions) s.uid: s};
    for (var session in sessions) {
      sessionMap[session.uid] = session;
    }
    await dataUpdateInfo.updateSessions(sessionMap.values.toList());
  }

  static Future<void> _deleteSession(
    String sessionId,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    String agendaDayUidSelected = "",
  }) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();

    List<Track> updatedTracks = [];
    List<String> tracksToDelete = [];

    for (var track in allTracks) {
      if (track.sessionUids.contains(sessionId)) {
        track.sessionUids.remove(sessionId);
        if (track.sessionUids.isEmpty) {
          tracksToDelete.add(track.uid);
        } else {
          updatedTracks.add(track);
        }
      } else {
        updatedTracks.add(track);
      }
    }

    if (tracksToDelete.isNotEmpty) {
      List<AgendaDay> allAgendaDays = await dataLoader.loadAllDays();
      for (var agendaDay in allAgendaDays) {
        bool modified = false;
        for (var trackId in tracksToDelete) {
          if (agendaDay.trackUids?.contains(trackId) ?? false) {
            agendaDay.trackUids?.remove(trackId);
            modified = true;
          }
        }
        if (modified) await dataUpdateInfo.updateAgendaDay(agendaDay);
      }
    }

    await dataUpdateInfo.updateTracks(updatedTracks, overrideData: true);
    await dataUpdateInfo.removeSession(sessionId);
    debugPrint("Session $sessionId and its associations removed.");
  }

  static Future<void> _addTrack(
    Track track,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      List<AgendaDay> allDays = await dataLoader.loadAllDays();
      for (var day in allDays) {
        if (day.uid == parentId) {
          await _updateAgendaDaysAddingTrack([day], track, dataUpdateInfo);
        }
      }
    }
    // Similar to sessions, if tracks are associated with agenda days, update the agenda day.
    await dataUpdateInfo.updateTrack(track);
    debugPrint("Track ${track.uid} added.");
  }

  static Future<void> _addTracks(
    List<Track> tracks,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();
    final trackMap = {for (var t in allTracks) t.uid: t};
    for (var track in tracks) {
      trackMap[track.uid] = track;
    }
    await dataUpdateInfo.updateTracks(trackMap.values.toList());
  }

  static Future<void> _deleteTrack(
    String trackId,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, [
    bool override = false,
  ]) async {
    var allTracks = await dataLoader.loadAllTracks();
    var track = allTracks.firstWhere((t) => t.uid == trackId);
    if (track.sessionUids.isEmpty || override) {
      Event event = (await dataLoader.loadEvents()).toList().firstWhere(
        (event) => event.tracks.any((track) => track.uid == trackId),
      );
      event.tracks.removeWhere((track) => track.uid == trackId);
      await dataUpdateInfo.updateEvent(event);
      List<AgendaDay> allDays = await dataLoader.loadAllDays();
      for (var day in allDays) {
        if (day.trackUids?.contains(trackId) == true) {
          await _updateAgendaDaysRemovingTrack([day], trackId, dataUpdateInfo);
        }
      }
      await dataUpdateInfo.removeTrack(trackId);
      debugPrint("Track $trackId and its associations removed.");
    } else {
      debugPrint(
        "Track $trackId not removed because has another sessions associated.",
      );
      throw CertainException(
        "Track ${track.name} not removed because has another sessions associated.",
      );
    }
  }

  static Future<void> _addAgendaDay(
    AgendaDay day,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      var allDays = await dataLoader.loadAllDays();
      var existingDay = allDays.firstWhere(
        (d) => d.uid == day.uid,
        orElse: () => day,
      );

      if (!existingDay.eventsUID.contains(parentId)) {
        existingDay.eventsUID.add(parentId);
      }
      existingDay.trackUids?.toList().removeWhere(
        (trackId) => day.trackUids?.contains(trackId) == true,
      );
      existingDay.trackUids?.addAll(day.trackUids?.toList() ?? []);
      day = existingDay;
    }
    // If agenda days are associated with an agenda, update the agenda.
    await dataUpdateInfo.updateAgendaDay(day);
    debugPrint("AgendaDay ${day.uid} added.");
  }

  static Future<void> _addAgendaDays(
    List<AgendaDay> days,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    var allDays = await dataLoader.loadAllDays();
    if (overrideData == true) {
      allDays.removeWhere(
        (day) =>
            day.eventsUID.contains(days.first.eventsUID.first) &&
            !days.map((dayModified) => dayModified.uid).contains(day.uid),
      );
    }
    Map<String, AgendaDay> allDaysMap = {for (var day in allDays) day.uid: day};

    for (var day in days) {
      if (allDaysMap.containsKey(day.uid)) {
        allDaysMap[day.uid]?.eventsUID.addAll(day.eventsUID);
      } else {
        allDaysMap[day.uid] = day;
      }
    }

    await dataUpdateInfo.updateAgendaDays(
      allDaysMap.values.toList(),
      overrideData: overrideData,
    );
  }

  static Future<void> _deleteAgendaDay(
    String dayId,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String eventId,
  ) async {
    var agendaDays = await dataLoader.loadAllDays();
    var agendaDay = agendaDays.firstWhere((day) => day.uid == dayId);
    if (agendaDay.eventsUID.isNotEmpty) {
      agendaDay.eventsUID.remove(eventId);
      debugPrint("AgendaDay $dayId remove eventId from eventUID.");
      if (agendaDay.eventsUID.isEmpty) {
        await dataUpdateInfo.removeAgendaDay(dayId);
        debugPrint("AgendaDay $dayId and its associations removed.");
      }
    } else {
      await dataUpdateInfo.removeAgendaDay(dayId);
      debugPrint("AgendaDay $dayId and its associations removed.");
    }
  }

  static Future<void> _addSpeaker(
    Speaker speaker,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      speaker.eventUIDS.add(parentId);
    }

    // If speakers are associated with events, you might need to update the event.
    await dataUpdateInfo.updateSpeaker(speaker);
    debugPrint("Speaker ${speaker.uid} added.");
  }

  static Future<void> _addSpeakers(
    List<Speaker> speakers,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    List<Speaker> allSpeakers = await dataLoader.loadSpeakers() ?? [];
    final speakerMap = {for (var s in allSpeakers) s.uid: s};
    for (var speaker in speakers) {
      speakerMap[speaker.uid] = speaker;
    }
    await dataUpdateInfo.updateSpeakers(speakerMap.values.toList());
  }

  static Future<void> _deleteSpeaker(
    String speakerId,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo,
    String eventUID,
  ) async {
    // If speakers are linked to events similarly to sessions, that logic would be added here.
    await dataUpdateInfo.removeSpeaker(speakerId, eventUID);
    debugPrint("Speaker $speakerId and its associations removed.");
  }

  static Future<void> _addSponsor(
    Sponsor sponsor,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfom,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      sponsor.eventUID = parentId;
    }

    await dataUpdateInfo.updateSponsors(sponsor);
    debugPrint("Sponsor ${sponsor.uid} added.");
  }

  static Future<void> _addOrganization(
    Config config,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfom,
    String? parentId,
  ) async {
    await dataUpdateInfo.updateOrganization(config);
    debugPrint("Organization ${config.configName} added.");
  }

  static Future<void> _addSponsors(
    List<Sponsor> sponsors,
    DataLoaderManager dataLoader,
    DataUpdateManager dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    List<Sponsor> allSponsors = await dataLoader.loadSponsors();
    final sponsorMap = {for (var s in allSponsors) s.uid: s};
    for (var sponsor in sponsors) {
      sponsorMap[sponsor.uid] = sponsor;
    }
    await dataUpdateInfo.updateSponsorsList(sponsorMap.values.toList());
  }

  static Future<void> _deleteSponsor(
    String sponsorId,
    DataUpdateManager dataUpdateInfo,
    DataLoaderManager dataLoader,
  ) async {
    // If sponsors are linked to events similarly to speakers, that logic would be added here.
    await dataUpdateInfo.removeSponsors(sponsorId);
    debugPrint("Sponsor $sponsorId and its associations removed.");
  }
}

Future<void> _updateAgendaDaysRemovingTrack(
  List<AgendaDay> days,
  String trackId,
  DataUpdateManager dataUpdateInfo, {
  String sessionId = "",
}) async {
  if (days.length == 1) {
    var daysUpdated = await _removeTrackFromDay(days.first, trackId);
    await dataUpdateInfo.updateAgendaDay(daysUpdated);
  } else {
    List<AgendaDay> modifiedDays = [];
    for (var day in days) {
      if (sessionId.isNotEmpty &&
          day.resolvedTracks
                  ?.expand((track) => track.sessionUids)
                  .toList()
                  .contains(sessionId) ==
              true) {
        modifiedDays.add(await _removeTrackFromDay(day, trackId));
      } else {
        if (sessionId.isEmpty) {
          modifiedDays.add(await _removeTrackFromDay(day, trackId));
        } else {
          modifiedDays.add(day);
        }
      }
    }
    await dataUpdateInfo.updateAgendaDays(modifiedDays);
  }
}

Future<void> _updateAgendaDaysAddingTrack(
  List<AgendaDay> days,
  Track track,
  DataUpdateManager dataUpdateInfo,
) async {
  if (days.length == 1) {
    await _addTrackFromDay(days.first, track);
    await dataUpdateInfo.updateAgendaDay(days.first);
  } else {
    days.map((day) async {
      await _addTrackFromDay(day, track);
    });
    await dataUpdateInfo.updateAgendaDays(days);
  }
}

Future<AgendaDay> _removeTrackFromDay(AgendaDay day, String trackId) async {
  final trackUidIndex = day.trackUids?.indexOf(trackId);
  if (trackUidIndex != null && trackUidIndex != -1) {
    day.trackUids?.removeAt(trackUidIndex);
  }

  if (day.resolvedTracks != null) {
    final resolvedTrackIndex = day.resolvedTracks!.indexWhere(
      (t) => t.uid == trackId,
    );
    if (resolvedTrackIndex != -1) {
      day.resolvedTracks!.removeAt(resolvedTrackIndex);
    }
  }
  return Future.value(day);
}

Future<AgendaDay> _addTrackFromDay(AgendaDay day, Track track) async {
  final trackUidIndex = day.trackUids?.indexOf(track.uid);
  if (trackUidIndex == null || trackUidIndex == -1) {
    day.trackUids?.toList().add(track.uid);
  }

  final resolvedTrackIndex = day.resolvedTracks!.indexWhere(
    (t) => t.uid == track.uid,
  );
  if (resolvedTrackIndex != -1) {
    day.resolvedTracks!.removeAt(resolvedTrackIndex);
  }
  day.resolvedTracks?.toList().add(track);

  return Future.value(day);
}
