import 'package:flutter/cupertino.dart';
import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github_json_model.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';

import '../../exceptions/exceptions.dart';

class DataUpdateManager {
  final CommonsServices dataCommons;
  final DataLoaderManager dataLoader = getIt<DataLoaderManager>();
  final Config config = getIt<Config>();

  DataUpdateManager({required this.dataCommons});

  Future<void> _commitDataUpdate(
    GithubJsonModel allData, {
    List<Event>? events,
    List<AgendaDay>? agendaDays,
    List<Track>? tracks,
    List<Session>? sessions,
    List<Speaker>? speakers,
    List<Sponsor>? sponsors,
    bool overrideData = false,
  }) async {
    // Check if all attributes of allData are null or empty.
    if ((events == null || events.isEmpty) &&
        (agendaDays == null || agendaDays.isEmpty) &&
        (tracks == null || tracks.isEmpty) &&
        (sessions == null || sessions.isEmpty) &&
        (speakers == null || speakers.isEmpty) &&
        (sponsors == null || sponsors.isEmpty) &&
        !overrideData) {
      // If all lists are empty or null, there is nothing to update.
      // You could log a message or just return.
      debugPrint("No data to update. All lists are empty or null.");
      return;
    } else {
      await dataCommons.updateAllData(
        allData,
        "events/${PathsGithub.eventPath}",
        PathsGithub.eventUpdateMessage,
      );
      await dataLoader.loadAllEventData(forceUpdate: true);
    }
  }

  Future<void> _updateAllEventData({
    List<Event>? events,
    List<AgendaDay>? agendaDays,
    List<Track>? tracks,
    List<Session>? sessions,
    List<Speaker>? speakers,
    List<Sponsor>? sponsors,
    bool overrideData = false,
  }) async {
    final currentEvents = (await dataLoader.loadEvents()).toList(
      growable: true,
    );

    final currentAgendaDays = (await dataLoader.loadAllDays()).toList(
      growable: true,
    );

    final currentTracks = (await dataLoader.loadAllTracks()).toList(
      growable: true,
    );

    final currentSessions = (await dataLoader.loadAllSessions()).toList(
      growable: true,
    );

    final currentSpeakers = (await dataLoader.loadSpeakers() ?? []).toList(
      growable: true,
    );

    final currentSponsors = (await dataLoader.loadSponsors()).toList(
      growable: true,
    );
    if (overrideData) {
      final allData = GithubJsonModel(
        events: events?.toList() ?? currentEvents,
        agendadays: agendaDays?.toList() ?? currentAgendaDays,
        tracks: tracks?.toList() ?? currentTracks,
        sessions: sessions?.toList() ?? currentSessions,
        speakers: speakers?.toList() ?? currentSpeakers,
        sponsors: sponsors?.toList() ?? currentSponsors,
      );

      await _commitDataUpdate(
        allData,
        events: events,
        agendaDays: agendaDays,
        tracks: tracks,
        sessions: sessions,
        speakers: speakers,
        sponsors: sponsors,
        overrideData: true,
      );
      await dataLoader.loadAllEventData(forceUpdate: true);
    } else {
      currentEvents.removeWhere(
        (event) => events?.map((e) => e.uid).contains(event.uid) == true,
      );
      currentAgendaDays.removeWhere(
        (day) => agendaDays?.map((d) => d.uid).contains(day.uid) == true,
      );
      currentTracks.removeWhere(
        (track) => tracks?.map((t) => t.uid).contains(track.uid) == true,
      );
      currentSessions.removeWhere(
        (session) => sessions?.map((s) => s.uid).contains(session.uid) == true,
      );
      currentSpeakers.removeWhere(
        (speaker) => speakers?.map((s) => s.uid).contains(speaker.uid) == true,
      );
      currentSponsors.removeWhere(
        (sponsor) => sponsors?.map((s) => s.uid).contains(sponsor.uid) == true,
      );

      currentEvents.addAll(events ?? []);
      currentTracks.addAll(tracks ?? []);
      currentAgendaDays.addAll(agendaDays ?? []);
      currentSessions.addAll(sessions ?? []);
      currentSpeakers.addAll(speakers ?? []);
      currentSponsors.addAll(sponsors ?? []);

      final allData = GithubJsonModel(
        events: currentEvents.toList(),
        agendadays: currentAgendaDays.toList(),
        tracks: currentTracks.toList(),
        sessions: currentSessions.toList(),
        speakers: currentSpeakers.toList(),
        sponsors: currentSponsors.toList(),
      );

      await _commitDataUpdate(
        allData,
        events: events,
        agendaDays: agendaDays,
        tracks: tracks,
        sessions: sessions,
        speakers: speakers,
        sponsors: sponsors,
      );
      await dataLoader.loadAllEventData(forceUpdate: true);
    }
  }

  Future<void> updateSpeaker(Speaker speaker) async {
    var speakersOriginal = await dataLoader.loadSpeakers() ?? [];
    int index = speakersOriginal.indexWhere((s) => s.uid == speaker.uid);
    if (index != -1) {
      speakersOriginal[index] = speaker;
    } else {
      speakersOriginal.add(speaker);
    }
    await _updateAllEventData(speakers: speakersOriginal);
  }

  Future<void> updateSpeakers(List<Speaker> speakers) async {
    await _updateAllEventData(speakers: speakers);
  }

  Future<void> updateTrack(Track track) async {
    var tracksOriginal = await dataLoader.loadAllTracks();
    int index = tracksOriginal.indexWhere((t) => t.uid == track.uid);
    if (index != -1) {
      tracksOriginal[index] = track;
    } else {
      tracksOriginal.add(track);
    }
    await _updateAllEventData(tracks: tracksOriginal, overrideData: true);
  }

  Future<void> updateTracks(
    List<Track> tracks, {
    bool overrideData = false,
  }) async {
    await _updateAllEventData(tracks: tracks, overrideData: overrideData);
  }

  Future<void> updateAgendaDay(AgendaDay agendaDay) async {
    var daysOriginal = await dataLoader.loadAllDays();
    int index = daysOriginal.indexWhere((d) => d.uid == agendaDay.uid);
    if (index != -1) {
      daysOriginal[index] = agendaDay;
    } else {
      daysOriginal.add(agendaDay);
    }
    await _updateAllEventData(agendaDays: daysOriginal);
  }

  Future<void> updateAgendaDays(
    List<AgendaDay> agendaDays, {
    bool overrideData = false,
  }) async {
    var agendaDaysRepo = await dataLoader.loadAllDays();
    if (overrideData) {
      if (agendaDays.isNotEmpty) {
        final eventUID = agendaDays.first.eventsUID.first;
        agendaDaysRepo.removeWhere((day) => day.eventsUID.contains(eventUID));
        agendaDaysRepo.addAll(agendaDays);
      }
    } else {
      for (var day in agendaDays) {
        final index = agendaDaysRepo.indexWhere((d) => d.uid == day.uid);
        if (index != -1) {
          agendaDaysRepo[index] = day;
        } else {
          agendaDaysRepo.add(day);
        }
      }
    }
    await _updateAllEventData(agendaDays: agendaDaysRepo);
  }

  Future<void> updateSponsors(Sponsor sponsor) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    int index = sponsorOriginal.indexWhere((s) => s.uid == sponsor.uid);
    if (index != -1) {
      sponsorOriginal[index] = sponsor;
    } else {
      sponsorOriginal.add(sponsor);
    }
    await _updateAllEventData(sponsors: sponsorOriginal);
  }

  Future<void> updateSponsorsList(List<Sponsor> sponsors) async {
    await _updateAllEventData(sponsors: sponsors);
  }

  Future<void> updateOrganization(Config config) async {
    await dataCommons.updateSingleData(
      config,
      "events/${config.pathUrl}",
      config.updateMessage,
    );
  }

  Future<void> updateEvent(Event event) async {
    var eventsOriginal = (await dataLoader.loadEvents()).toList(growable: true);

    int index = eventsOriginal.indexWhere((e) => e.uid == event.uid);
    if (index != -1) {
      eventsOriginal[index] = event;
    } else {
      eventsOriginal.add(event);
    }
    await _updateAllEventData(events: eventsOriginal);
  }

  Future<void> updateEvents(List<Event> events) async {
    await _updateAllEventData(events: events);
  }

  Future<void> updateSession(Session session, String? trackUID) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    Track? track = (await dataLoader.loadAllTracks())
        .where((selectedTrack) => selectedTrack.uid == trackUID)
        .toList()
        .firstOrNull;

    List<Event> events = (await dataLoader.loadEvents()).map((event) {
      var trackSelectedIndez = event.tracks.indexWhere(
        (track) => track.uid == trackUID,
      );
      if (trackSelectedIndez != -1) {
        event.tracks.removeAt(trackSelectedIndez);
      }

      if (track != null && track.eventUid == event.uid) {
        event.tracks.add(track);
      }
      return event;
    }).toList();

    List<Track> tracks = (await dataLoader.loadAllTracks()).map((track) {
      if (track.uid != trackUID) {
        track.sessionUids.remove(session.uid);
      } else {
        track.sessionUids.add(session.uid);
      }
      return track;
    }).toList();

    List<AgendaDay> agendaDays = (await dataLoader.loadAllDays()).map((day) {
      if (day.trackUids?.contains(trackUID) == true) {
        day.trackUids?.remove(trackUID);
      }
      if (day.uid == session.agendaDayUID && trackUID != null) {
        day.trackUids?.add(trackUID);
      }
      return day;
    }).toList();

    int index = sessionListOriginal.indexWhere((s) => s.uid == session.uid);
    if (index != -1) {
      sessionListOriginal[index] = session;
    } else {
      sessionListOriginal.add(session);
    }
    await _updateAllEventData(
      events: events,
      tracks: tracks,
      agendaDays: agendaDays,
      sessions: sessionListOriginal,
      overrideData: true,
    );
  }

  Future<void> updateSessions(List<Session> sessions) async {
    await _updateAllEventData(sessions: sessions);
  }

  Future<void> removeSpeaker(String speakerId, String eventUID) async {
    var speakersOriginal = (await dataLoader.loadSpeakers() ?? []).toList(
      growable: true,
    );
    var allsessions = await dataLoader.loadAllSessions();

    if (allsessions.indexWhere((session) => session.speakerUID == speakerId) !=
        -1) {
      throw CertainException(
        "Exists sessions with this speaker, please remove them first",
      );
    }

    if (speakersOriginal.isNotEmpty) {
      var speakerToRemoveIndex = speakersOriginal.indexWhere(
        (speaker) => speaker.uid == speakerId,
      );

      if (speakerToRemoveIndex != -1) {
        var speakerToRemove = speakersOriginal[speakerToRemoveIndex];
        if (speakerToRemove.eventUIDS.length <= 1) {
          speakersOriginal.remove(speakerToRemove);
        } else {
          speakerToRemove.eventUIDS.remove(eventUID);
        }
        await overwriteItems(speakersOriginal,Speaker);
      }
    }
  }

  Future<void> removeSponsors(String sponsorId) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    sponsorOriginal.removeWhere((sponsor) => sponsor.uid == sponsorId);
    await overwriteItems(sponsorOriginal,Sponsor);
  }

  Future<void> removeEvent(String eventId) async {
    var events = await dataLoader.loadEvents();
    var tracks = await dataLoader.loadAllTracks();
    var sessions = await dataLoader.loadAllSessions();
    var speakers = await dataLoader.loadSpeakers() ?? [];
    var days = await dataLoader.loadAllDays();
    if (eventId == config.eventForcedToViewUID) {
      config.eventForcedToViewUID = null;
      await updateOrganization(config);
    }

    events.removeWhere((event) => event.uid == eventId);
    tracks.removeWhere((track) => track.eventUid == eventId);
    sessions.removeWhere((session) => session.eventUID == eventId);

    List<AgendaDay> updatedDays = [];
    for (var day in days) {
      day.eventsUID.remove(eventId);
      if (day.eventsUID.isNotEmpty) {
        updatedDays.add(day);
      }
    }

    List<Speaker> updatedSpeakers = [];
    for (var speaker in speakers) {
      speaker.eventUIDS.remove(eventId);
      if (speaker.eventUIDS.isNotEmpty) {
        updatedSpeakers.add(speaker);
      }
    }

    await _updateAllEventData(
      events: events,
      tracks: tracks,
      sessions: sessions,
      speakers: updatedSpeakers,
      agendaDays: updatedDays,
      overrideData: true,
    );
  }

  Future<void> removeAgendaDay(String agendaDayId) async {
    var agendaDaysListOriginal = await dataLoader.loadAllDays();
    agendaDaysListOriginal.removeWhere((day) => day.uid == agendaDayId);
    await overwriteItems(agendaDaysListOriginal,AgendaDay);
  }

  Future<void> removeSession(String sessionId) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    var tracksOriginal = await dataLoader.loadAllTracks();

    sessionListOriginal.removeWhere((session) => session.uid == sessionId);

    // Elimina el UID de la sesión de la lista `sessionUids` en los tracks correspondientes.
    for (var track in tracksOriginal) {
      track.sessionUids.remove(sessionId);
    }

    await _updateAllEventData(
      sessions: sessionListOriginal,
      tracks: tracksOriginal,
      overrideData: true,
    );
  }

  Future<void> removeTrack(String trackId) async {
    var tracksOriginal = await dataLoader.loadAllTracks();
    tracksOriginal.removeWhere((track) => track.uid == trackId);
    await overwriteItems(tracksOriginal,Track);
  }

  /// Overwrites a list of items in the remote data source.
  ///
  /// This function takes a list of items that should be present in the remote
  /// data source. It automatically detects the type of items and overwrites
  /// the corresponding list in the remote JSON data file with the provided list.
  ///
  /// [itemsToKeep] is a `List<dynamic>` containing the objects that will form
  /// the new list. All items in the list must be of the same type.
  Future<void> overwriteItems(List<dynamic> itemsToKeep, Type typeItem) async {
    if (itemsToKeep.isEmpty) {
      debugPrint(
        "Warning: Overwriting with an empty list. This will remove all items of this type.",
      );
      // If you want to prevent deleting all items, you can add a return here.
      // For now, it's allowed.
    }

    if (typeItem is Event) {
      await _updateAllEventData(
        events: itemsToKeep.cast<Event>().toList(),
        overrideData: true,
      );
    } else if (typeItem is AgendaDay) {
      await _updateAllEventData(
        agendaDays: itemsToKeep.cast<AgendaDay>().toList(),
        overrideData: true,
      );
    } else if (typeItem is Track) {
      await _updateAllEventData(
        tracks: itemsToKeep.cast<Track>().toList(),
        overrideData: true,
      );
    } else if (typeItem is Session) {
      await _updateAllEventData(
        sessions: itemsToKeep.cast<Session>().toList(),
        overrideData: true,
      );
    } else if (typeItem is Speaker) {
      await _updateAllEventData(
        speakers: itemsToKeep.cast<Speaker>().toList(),
        overrideData: true,
      );
    } else if (typeItem is Sponsor) {
      await _updateAllEventData(
        sponsors: itemsToKeep.cast<Sponsor>().toList(),
        overrideData: true,
      );
    } else {
      debugPrint("Unknown item type for overwrite: ${typeItem.runtimeType}");
    }
  }
}
