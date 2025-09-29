import 'package:flutter/material.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/update_data/data_update_info.dart';

class ManagerData {

  static Future<void> deleteItemAndAssociations(
      String itemId,
      Type itemType,
      DataLoader dataLoader,
      DataUpdateInfo dataUpdateInfo,
      ) async {
    switch (itemType.toString()) {
      case "Agenda":
        await _deleteAgenda(itemId, dataLoader, dataUpdateInfo);
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
      String parentId, // Can be Session, Track, AgendaDay, Speaker, Sponsor
      DataLoader dataLoader,
      DataUpdateInfo dataUpdateInfo,
      ) async {
    switch (item.runtimeType.toString()) {
      case "Agenda":
        await _addAgenda(item as Agenda, dataLoader, dataUpdateInfo,parentId);
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

  static Future<void> _addAgenda(Agenda agenda, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.uid == parentId) {
        event.agendaUID = agenda.uid; // Ensure no duplicates
        await dataUpdateInfo.updateEvent(event);
      }
    }
    await dataUpdateInfo.updateAgenda(agenda);
    debugPrint("Agenda ${agenda.uid} added.");
  }

  static Future<void> _deleteAgenda(String agendaId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.agendaUID == agendaId) {
        event.agendaUID = ""; // Ensure no duplicates
        await dataUpdateInfo.updateEvent(event);
      }
    }
    await dataUpdateInfo.removeAgendaDay(agendaId);
    debugPrint("Agenda $agendaId and its associations removed.");
  }

  static Future<void> _addSession(Session session, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<Track> allTracks = await dataLoader.loadAllTracks();
    for (var track in allTracks) {
      if (track.uid == parentId) {
        track.sessionUids.removeWhere((uid) => uid == session.uid); // Ensure no duplicates
        track.sessionUids.add(session.uid);
        track.resolvedSessions?.removeWhere((s) => s.uid == session.uid); // Ensure no duplicates
        track.resolvedSessions?.add(session);
        await dataUpdateInfo.updateTrack(track);
      }
    }
    await dataUpdateInfo.updateSession(session);
    debugPrint("Session ${session.uid} added.");
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

  static Future<void> _addTrack(Track track, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<AgendaDay> allDays = await dataLoader.loadAllDays();
    for (var day in allDays) {
      if (day.uid == parentId) {
        day.trackUids.removeWhere((uid) => uid == track.uid); // Ensure no duplicates
        day.trackUids.add(track.uid);
        day.resolvedTracks?.removeWhere((t) => t.uid == track.uid); // Ensure no duplicates
        day.resolvedTracks?.add(track);
        await dataUpdateInfo.updateAgendaDay(day);
      }
    }
    // Similar to sessions, if tracks are associated with agenda days, update the agenda day.
    await dataUpdateInfo.updateTrack(track);
    debugPrint("Track ${track.uid} added.");
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
  static Future<void> _addAgendaDay(AgendaDay day, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<Agenda> allAgendas = await dataLoader.loadAgendaStructures();
    for (var agenda in allAgendas) {
      if (agenda.uid.contains(parentId)) {
        agenda.dayUids.removeWhere((uid) => uid == day.uid); // Ensure no duplicates
        agenda.dayUids.add(day.uid);
        agenda.resolvedDays?.removeWhere((d) => d.uid == day.uid); // Ensure no duplicates
        agenda.resolvedDays?.add(day);
        await dataUpdateInfo.updateAgenda(agenda);
      }
    }
    // If agenda days are associated with an agenda, update the agenda.
    await dataUpdateInfo.updateAgendaDay(day);
    debugPrint("AgendaDay ${day.uid} added.");
  }
  static Future<void> _deleteAgendaDay(String dayId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Agenda> allAgendas = await dataLoader.loadAgendaStructures();
    for (var agenda in allAgendas) {
      if (agenda.dayUids.contains(dayId)) {
        agenda.dayUids.remove(dayId);
        agenda.resolvedDays?.removeWhere((day) => day.uid == dayId);
        await dataUpdateInfo.updateAgenda(agenda);
      }
    }
    await dataUpdateInfo.removeAgendaDay(dayId);
    debugPrint("AgendaDay $dayId and its associations removed.");
  }

  static Future<void> _addSpeaker(Speaker speaker, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.uid.contains(speaker.uid)) {
        event.speakersUID.removeWhere((uid) => uid == speaker.uid); // Ensure no duplicates
        event.speakersUID.add(speaker.uid); // Ensure no duplicates
        await dataUpdateInfo.updateEvent(event);
      }
    }
    // If speakers are associated with events, you might need to update the event.
    await dataUpdateInfo.updateSpeaker(speaker);
    debugPrint("Speaker ${speaker.uid} added.");
  }
  static Future<void> _deleteSpeaker(String speakerId, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.speakersUID.contains(speakerId)) {
        event.speakersUID.remove(speakerId);
        await dataUpdateInfo.updateEvent(event);
      }
    }

    // Assuming speakers are primarily standalone or linked in a way not covered by other data types.
    // If speakers are linked to events similarly to sessions, that logic would be added here.
    await dataUpdateInfo.removeSpeaker(speakerId);
    debugPrint("Speaker $speakerId and its associations removed.");
  }
  static Future<void> _addSponsor(Sponsor sponsor, DataLoader dataLoader, DataUpdateInfo dataUpdateInfo, String parentId) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.sponsorsUID.contains(sponsor.uid)) {
        event.sponsorsUID.removeWhere((uid) => uid == sponsor.uid); // Ensure no duplicates
        event.sponsorsUID.add(sponsor.uid); // Add, ensuring it's not duplicated
        await dataUpdateInfo.updateEvent(event);
      }
    }
    await dataUpdateInfo.updateSponsors(sponsor);
    debugPrint("Sponsor ${sponsor.uid} added.");
  }
  static Future<void> _deleteSponsor(String sponsorId, DataUpdateInfo dataUpdateInfo,DataLoader dataLoader) async {
    List<Event> allEvents = await dataLoader.loadEvents();
    for (var event in allEvents) {
      if (event.sponsorsUID.contains(sponsorId)) {
        event.sponsorsUID.remove(sponsorId);
        await dataUpdateInfo.updateEvent(event);
        return;
      }
    }
    // Assuming sponsors are primarily standalone or linked in a way not covered by other data types.
    // If sponsors are linked to events similarly to speakers, that logic would be added here.
    await dataUpdateInfo.removeSponsors(sponsorId);
    debugPrint("Sponsor $sponsorId and its associations removed.");
  }


}