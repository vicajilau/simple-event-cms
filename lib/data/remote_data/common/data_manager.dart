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
      Type itemType
      ) async {
    switch (itemType.toString()) {
      case "Event":
        await _deleteEvent(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Session":
        await _deleteSession(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Track" :
        await _deleteTrack(itemId, dataLoader, dataUpdateInfo);
        break;
      case "AgendaDay" :
        await _deleteAgendaDay(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Speaker" :
        await _deleteSpeaker(itemId, dataLoader, dataUpdateInfo);
        break;
      case "Sponsor" :
        await _deleteSponsor(itemId, dataUpdateInfo,dataLoader);
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
        await _addSession(item as Session, dataLoader, dataUpdateInfo,parentId);
        break;
      case "Track":
        await _addTrack(item as Track, dataLoader, dataUpdateInfo,parentId);
        break;
      case "AgendaDay":
        await _addAgendaDay(item as AgendaDay, dataLoader, dataUpdateInfo,parentId);
        break;
      case "Speaker":
        await _addSpeaker(item as Speaker, dataLoader, dataUpdateInfo,parentId);
        break;
      case "Sponsor":
        await _addSponsor(item as Sponsor,dataLoader,dataUpdateInfo,parentId);
        break;
      default:
        throw Exception("Unsupported item type for addition: ${item.runtimeType}");
    }
  }

  static Future<void> addItemListAndAssociations(
      List<dynamic> items, // Can be a list of Session, Track, AgendaDay, Speaker, Sponsor
      ) async {
    if (items.isEmpty) return;

    String itemType = items.first.runtimeType.toString();
    switch (itemType) {
      case "Session":
        await _addSessions(items.cast<Session>(), dataLoader, dataUpdateInfo);
        break;
      case "Track":
        await _addTracks(items.cast<Track>(), dataLoader, dataUpdateInfo);
        break;
      case "AgendaDay":
        await _addAgendaDays(items.cast<AgendaDay>(), dataLoader, dataUpdateInfo);
        break;
      case "Speaker":
        await _addSpeakers(items.cast<Speaker>(), dataLoader, dataUpdateInfo);
        break;
      case "Sponsor":
        await _addSponsors(items.cast<Sponsor>(), dataLoader, dataUpdateInfo);
        break;
      default:
        throw Exception("Unsupported item type for addition: ${items.first.runtimeType}");
    }
  }

  static Future<void> _addEvent(Event event, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    await addItemListAndAssociations(event.tracks);
    await dataUpdateInfo.updateEvent(event);
    debugPrint("Event ${event.uid} added.");
  }

  static Future<void> _deleteEvent(String eventId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    await dataUpdateInfo.removeEvent(eventId);
    debugPrint("Event $eventId deleted.");
  }

  static Future<void> _addSession(Session session, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String? parentId) async {
    if(parentId != null && parentId.isNotEmpty) {
      List<Track> allTracks = await dataLoader.loadAllTracks();
      for (var track in allTracks) {
        if (track.uid == parentId) {
          track.sessionUids.removeWhere((uid) =>
          uid == session.uid); // Ensure no duplicates
          track.sessionUids.add(session.uid);
          track.resolvedSessions?.removeWhere((s) =>
          s.uid == session.uid); // Ensure no duplicates
          track.resolvedSessions?.add(session);
          await dataUpdateInfo.updateTrack(track);
        }
      }
    }
    await dataUpdateInfo.updateSession(session);
    debugPrint("Session ${session.uid} added.");
  }

  static Future<void> _addSessions(List<Session> sessions, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Session> allSessions = await dataLoader.loadAllSessions();
    final sessionMap = { for (var s in allSessions) s.uid : s };
    for (var session in sessions) {
      sessionMap[session.uid] = session;
    }
    await dataUpdateInfo.updateSessions(sessionMap.values.toList());
  }
  static Future<void> _deleteSession(String sessionId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();
    for (var track in allTracks) {
      if (track.sessionUids.contains(sessionId)) {
        track.sessionUids.remove(sessionId);
        track.resolvedSessions?.removeWhere((session) => session.uid == sessionId);
        await dataUpdateInfo.updateTrack(track);
      }
    }
    await dataUpdateInfo.removeSession(sessionId);
    debugPrint("Session $sessionId and its associations removed.");
  }

  static Future<void> _addTrack(Track track, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String? parentId) async {
    if(parentId != null && parentId.isNotEmpty) {
      List<AgendaDay> allDays = await dataLoader.loadAllDays();
      for (var day in allDays) {
        if (day.uid == parentId) {
          day.trackUids.removeWhere((uid) =>
          uid == track.uid); // Ensure no duplicates
          day.trackUids.add(track.uid);
          day.resolvedTracks?.removeWhere((t) =>
          t.uid == track.uid); // Ensure no duplicates
          day.resolvedTracks?.add(track);
          await dataUpdateInfo.updateAgendaDay(day);
        }
      }
    }
    // Similar to sessions, if tracks are associated with agenda days, update the agenda day.
    await dataUpdateInfo.updateTrack(track);
    debugPrint("Track ${track.uid} added.");
  }

  static Future<void> _addTracks(List<Track> tracks, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();
    final trackMap = { for (var t in allTracks) t.uid : t };
    for (var track in tracks) {
      trackMap[track.uid] = track;
    }
    await dataUpdateInfo.updateTracks(trackMap.values.toList());
  }

  static Future<void> _deleteTrack(String trackId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<AgendaDay> allDays = await dataLoader.loadAllDays();
    for (var day in allDays) {
      if (day.trackUids.contains(trackId)) {
        day.trackUids.remove(trackId);
        day.resolvedTracks?.removeWhere((track) => track.uid == trackId);
        await dataUpdateInfo.updateAgendaDay(day);
      }
    }
    await dataUpdateInfo.removeTrack(trackId);
    debugPrint("Track $trackId and its associations removed.");
  }
  static Future<void> _addAgendaDay(AgendaDay day, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String? parentId) async {
    if(parentId != null && parentId.isNotEmpty) {
      day.eventUID = parentId;
    }
    // If agenda days are associated with an agenda, update the agenda.
    await dataUpdateInfo.updateAgendaDay(day);
    debugPrint("AgendaDay ${day.uid} added.");
  }

  static Future<void> _addAgendaDays(List<AgendaDay> days, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<AgendaDay> allAgendaDays = await dataLoader.loadAllDays();
    final dayMap = { for (var d in allAgendaDays) d.uid : d };
    for (var day in days) {
      dayMap[day.uid] = day;
    }
    await dataUpdateInfo.updateAgendaDays(dayMap.values.toList());
  }
  static Future<void> _deleteAgendaDay(String dayId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    await dataUpdateInfo.removeAgendaDay(dayId);
    debugPrint("AgendaDay $dayId and its associations removed.");
  }

  static Future<void> _addSpeaker(Speaker speaker, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String? parentId) async {
    if(parentId != null && parentId.isNotEmpty){
      speaker.eventUID = parentId;
    }

    // If speakers are associated with events, you might need to update the event.
    await dataUpdateInfo.updateSpeaker(speaker);
    debugPrint("Speaker ${speaker.uid} added.");
  }

  static Future<void> _addSpeakers(List<Speaker> speakers, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Speaker> allSpeakers = await dataLoader.loadSpeakers();
    final speakerMap = { for (var s in allSpeakers) s.uid : s };
    for (var speaker in speakers) {
      speakerMap[speaker.uid] = speaker;
    }
    await dataUpdateInfo.updateSpeakers(speakerMap.values.toList());

  }
  static Future<void> _deleteSpeaker(String speakerId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    // If speakers are linked to events similarly to sessions, that logic would be added here.
    await dataUpdateInfo.removeSpeaker(speakerId);
    debugPrint("Speaker $speakerId and its associations removed.");
  }
  static Future<void> _addSponsor(Sponsor sponsor, DataLoader dataLoader, DataUpdateInfo dataUpdateInfom, String? parentId) async {
    if(parentId != null && parentId.isNotEmpty){
        sponsor.eventUID = parentId;
    }

    await dataUpdateInfo.updateSponsors(sponsor);
    debugPrint("Sponsor ${sponsor.uid} added.");
  }

  static Future<void> _addSponsors(List<Sponsor> sponsors, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Sponsor> allSponsors = await dataLoader.loadSponsors();
    final sponsorMap = { for (var s in allSponsors) s.uid : s };
    for (var sponsor in sponsors) {
      sponsorMap[sponsor.uid] = sponsor;
    }
    await dataUpdateInfo.updateSponsorsList(sponsorMap.values.toList());
  }
  static Future<void> _deleteSponsor(String sponsorId, DataUpdateInfo dataUpdateInfo,DataLoader dataLoader) async {
    // If sponsors are linked to events similarly to speakers, that logic would be added here.
    await dataUpdateInfo.removeSponsors(sponsorId);
    debugPrint("Sponsor $sponsorId and its associations removed.");
  }


}