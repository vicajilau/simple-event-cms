import 'package:flutter/material.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';

class DataUpdate {
  static DataLoader dataLoader = getIt<DataLoader>();
  static DataUpdateInfo dataUpdateInfo = DataUpdateInfo(
    dataCommons: CommonsServicesImp(),
  );

  static Future<void> deleteItemAndAssociations(
    String itemId,
    Type itemType, {
    String? eventUID,
  }) async {
    switch (itemType.toString()) {
      case "Event":
        await _deleteEvent(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Session":
        await _deleteSession(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Track":
        await _deleteTrack(itemId, dataLoader, dataUpdateInfo);
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
        await _deleteSpeaker(itemId, dataLoader, dataUpdateInfo);
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
    switch (item.runtimeType.toString()) {
      case "Event":
        await _addEvent(item as Event, dataLoader, dataUpdateInfo);
        break;
      case "Session":
        await _addSession(
          item as Session,
          dataLoader,
          dataUpdateInfo,
          parentId,
        );
        break;
      case "Track":
        await _addTrack(item as Track, dataLoader, dataUpdateInfo, parentId);
        break;
      case "AgendaDay":
        await _addAgendaDay(
          item as AgendaDay,
          dataLoader,
          dataUpdateInfo,
          parentId,
        );
        break;
      case "Speaker":
        await _addSpeaker(
          item as Speaker,
          dataLoader,
          dataUpdateInfo,
          parentId,
        );
        break;
      case "Sponsor":
        await _addSponsor(
          item as Sponsor,
          dataLoader,
          dataUpdateInfo,
          parentId,
        );
        break;

      case "Organization":
        await _addOrganization(
          item as Organization,
          dataLoader,
          dataUpdateInfo,
          parentId,
        );
        break;
      default:
        throw Exception(
          "Unsupported item type for addition: ${item.runtimeType}",
        );
    }
  }

  static Future<void> addItemListAndAssociations(
    List<dynamic>
    items, { // Can be a list of Session, Track, AgendaDay, Speaker, Sponsor
    bool overrideData = false,
  }) async {
    if (items.isEmpty) return;

    String itemType = items.first.runtimeType.toString();
    switch (itemType) {
      case "Session":
        await _addSessions(
          items.cast<Session>(),
          dataLoader,
          dataUpdateInfo,
          overrideData: overrideData,
        );
        break;
      case "Track":
        await _addTracks(
          items.cast<Track>(),
          dataLoader,
          dataUpdateInfo,
          overrideData: overrideData,
        );
        break;
      case "AgendaDay":
        await _addAgendaDays(
          items.cast<AgendaDay>(),
          dataLoader,
          dataUpdateInfo,
          overrideData: overrideData,
        );
        break;
      case "Speaker":
        await _addSpeakers(
          items.cast<Speaker>(),
          dataLoader,
          dataUpdateInfo,
          overrideData: overrideData,
        );
        break;
      case "Sponsor":
        await _addSponsors(
          items.cast<Sponsor>(),
          dataLoader,
          dataUpdateInfo,
          overrideData: overrideData,
        );
        break;
      default:
        throw Exception(
          "Unsupported item type for addition: ${items.first.runtimeType}",
        );
    }
  }

  static Future<void> _addEvent(
    Event event,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
  ) async {
    await addItemListAndAssociations(event.tracks);
    await dataUpdateInfo.updateEvent(event);
    debugPrint("Event ${event.uid} added.");
  }

  static Future<void> _deleteEvent(
    String eventId,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
  ) async {
    await dataUpdateInfo.removeEvent(eventId);
    debugPrint("Event $eventId deleted.");
  }

  static Future<void> _addSession(
    Session session,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      List<Track> allTracks = await dataLoader.loadAllTracks();
      for (var track in allTracks) {
        if (track.uid == parentId) {
          _removeSessionFromTrack(track, session.uid);
          track.sessionUids.toList().add(session.uid);
          track.resolvedSessions.toList().add(session);
          await dataUpdateInfo.updateTrack(track);
        }
      }
    }
    await dataUpdateInfo.updateSession(session);
    debugPrint("Session ${session.uid} added.");
  }

  static Future<void> _addSessions(
    List<Session> sessions,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo, {
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
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
  ) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();
    List<AgendaDay> agendaDays = await dataLoader.loadAllDays();
    List<Event> events = await dataLoader.loadEvents();
    for (var track in allTracks) {
      if (track.sessionUids.contains(sessionId)) {
        _removeSessionFromTrack(track, sessionId);
        await dataUpdateInfo.updateTrack(track);
        await _updateAgendaDaysRemovingTrack(
          agendaDays,
          track.uid,
          dataUpdateInfo,
        );
        var event = events.firstWhere((event) => event.uid == track.eventUid);
        event.tracks.removeWhere((track) => track.uid == track.uid);
        await dataUpdateInfo.updateEvent(event);
      }
    }
    await dataUpdateInfo.removeSession(sessionId);
    debugPrint("Session $sessionId and its associations removed.");
  }

  static Future<void> _addTrack(
    Track track,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
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
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo, {
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
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
  ) async {
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
  }

  static Future<void> _addAgendaDay(
    AgendaDay day,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
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
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo, {
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

    await dataUpdateInfo.updateAgendaDays(allDaysMap.values.toList(),overrideData: overrideData);
  }

  static Future<void> _deleteAgendaDay(
    String dayId,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
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
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      speaker.eventUID = parentId;
    }

    // If speakers are associated with events, you might need to update the event.
    await dataUpdateInfo.updateSpeaker(speaker);
    debugPrint("Speaker ${speaker.uid} added.");
  }

  static Future<void> _addSpeakers(
    List<Speaker> speakers,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo, {
    bool overrideData = false,
  }) async {
    List<Speaker> allSpeakers = await dataLoader.loadSpeakers();
    final speakerMap = {for (var s in allSpeakers) s.uid: s};
    for (var speaker in speakers) {
      speakerMap[speaker.uid] = speaker;
    }
    await dataUpdateInfo.updateSpeakers(speakerMap.values.toList());
  }

  static Future<void> _deleteSpeaker(
    String speakerId,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo,
  ) async {
    // If speakers are linked to events similarly to sessions, that logic would be added here.
    await dataUpdateInfo.removeSpeaker(speakerId);
    debugPrint("Speaker $speakerId and its associations removed.");
  }

  static Future<void> _addSponsor(
    Sponsor sponsor,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfom,
    String? parentId,
  ) async {
    if (parentId != null && parentId.isNotEmpty) {
      sponsor.eventUID = parentId;
    }

    await dataUpdateInfo.updateSponsors(sponsor);
    debugPrint("Sponsor ${sponsor.uid} added.");
  }

  static Future<void> _addOrganization(
    Organization organization,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfom,
    String? parentId,
  ) async {
    await dataUpdateInfo.updateOrganization(organization);
    debugPrint("Organization ${organization.organizationName} added.");
  }

  static Future<void> _addSponsors(
    List<Sponsor> sponsors,
    DataLoader dataLoader,
    DataUpdateInfo dataUpdateInfo, {
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
    DataUpdateInfo dataUpdateInfo,
    DataLoader dataLoader,
  ) async {
    // If sponsors are linked to events similarly to speakers, that logic would be added here.
    await dataUpdateInfo.removeSponsors(sponsorId);
    debugPrint("Sponsor $sponsorId and its associations removed.");
  }
}

void _removeSessionFromTrack(Track track, String sessionId) {
  final sessionUidIndex = track.sessionUids.indexOf(sessionId);
  if (sessionUidIndex != -1) {
    track.sessionUids.removeAt(sessionUidIndex);
  }

  final resolvedSessionIndex = track.resolvedSessions.indexWhere(
    (session) => session.uid == sessionId,
  );
  if (resolvedSessionIndex != -1) {
    track.resolvedSessions.removeAt(resolvedSessionIndex);
  }
}

Future<void> _updateAgendaDaysRemovingTrack(
  List<AgendaDay> days,
  String trackId,
  DataUpdateInfo dataUpdateInfo,
) async {
  if (days.length == 1) {
    var daysUpdated = await _removeTrackFromDay(days.first, trackId);
    await dataUpdateInfo.updateAgendaDay(daysUpdated);
  } else {
    days = days.map((day) async {
      return await _removeTrackFromDay(day, trackId);
    }).cast<AgendaDay>().toList();
    await dataUpdateInfo.updateAgendaDays(days);
  }
}

Future<void> _updateAgendaDaysAddingTrack(
  List<AgendaDay> days,
  Track track,
  DataUpdateInfo dataUpdateInfo,
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
  return day;
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

  return day;
}
