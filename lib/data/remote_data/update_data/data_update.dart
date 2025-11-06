import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;
  final DataLoader dataLoader = getIt<DataLoader>();
  final Organization organization = getIt<Organization>();

  DataUpdateInfo({required this.dataCommons});

  Future<void> _updateAllEventData({
    List<Event>? events,
    List<AgendaDay>? agendaDays,
    List<Track>? tracks,
    List<Session>? sessions,
    List<Speaker>? speakers,
    List<Sponsor>? sponsors,
  }) async {
    final currentEvents = await dataLoader.loadEvents();
    final currentAgendaDays = await dataLoader.loadAllDays();
    final currentTracks = await dataLoader.loadAllTracks();
    final currentSessions = await dataLoader.loadAllSessions();
    final currentSpeakers = await dataLoader.loadSpeakers() ?? [];
    final currentSponsors = await dataLoader.loadSponsors();

    final allData = {
      'events': (events ?? currentEvents).map((e) => e.toJson()).toList(),
      'agendaDays': (agendaDays ?? currentAgendaDays).map((e) => e.toJson()).toList(),
      'tracks': (tracks ?? currentTracks).map((e) => e.toJson()).toList(),
      'sessions': (sessions ?? currentSessions).map((e) => e.toJson()).toList(),
      'speakers': (speakers ?? currentSpeakers).map((e) => e.toJson()).toList(),
      'sponsors': (sponsors ?? currentSponsors).map((e) => e.toJson()).toList(),
    };

    await dataCommons.updateAllData(
      allData,
      "events/${PathsGithub.eventPath}",
      PathsGithub.eventUpdateMessage,
    );
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
    await _updateAllEventData(tracks: tracksOriginal);
  }

  Future<void> updateTracks(List<Track> tracks) async {
    await _updateAllEventData(tracks: tracks);
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

  Future<void> updateOrganization(Organization organization) async {
    await dataCommons.updateSingleData(
      organization,
      "events/${organization.pathUrl}",
      organization.updateMessage,
    );
  }

  Future<void> updateEvent(Event event) async {
    var eventsOriginal = await dataLoader.loadEvents();
    if (event.openAtTheBeggining == true) {
      for (var e in eventsOriginal) {
        e.openAtTheBeggining = false;
      }
    }
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

  Future<void> updateSession(Session session) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    int index = sessionListOriginal.indexWhere((s) => s.uid == session.uid);
    if (index != -1) {
      sessionListOriginal[index] = session;
    } else {
      sessionListOriginal.add(session);
    }
    await _updateAllEventData(sessions: sessionListOriginal);
  }

  Future<void> updateSessions(List<Session> sessions) async {
    await _updateAllEventData(sessions: sessions);
  }

  Future<void> removeSpeaker(String speakerId, String eventUID) async {
    var speakersOriginal = await dataLoader.loadSpeakers() ?? [];
    if (speakersOriginal.isNotEmpty) {
      var speakerToRemoveIndex = speakersOriginal.indexWhere(
        (speaker) => speaker.uid == speakerId,
      );

      if (speakerToRemoveIndex != -1) {
        var speakerToRemove = speakersOriginal[speakerToRemoveIndex];
        if (speakerToRemove.eventUIDS.length <= 1) {
          speakersOriginal.removeAt(speakerToRemoveIndex);
        } else {
          speakerToRemove.eventUIDS.remove(eventUID);
        }
        await _updateAllEventData(speakers: speakersOriginal);
      }
    }
  }

  Future<void> removeSponsors(String sponsorId) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    sponsorOriginal.removeWhere((sponsor) => sponsor.uid == sponsorId);
    await _updateAllEventData(sponsors: sponsorOriginal);
  }

  Future<void> removeEvent(String eventId) async {
    var events = await dataLoader.loadEvents();
    var tracks = await dataLoader.loadAllTracks();
    var sessions = await dataLoader.loadAllSessions();
    var speakers = await dataLoader.loadSpeakers() ?? [];
    var days = await dataLoader.loadAllDays();

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
    );
  }

  Future<void> removeAgendaDay(String agendaDayId) async {
    var agendaDaysListOriginal = await dataLoader.loadAllDays();
    agendaDaysListOriginal.removeWhere((day) => day.uid == agendaDayId);
    await _updateAllEventData(agendaDays: agendaDaysListOriginal);
  }

  Future<void> removeSession(String sessionId) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    sessionListOriginal.removeWhere((session) => session.uid == sessionId);
    await _updateAllEventData(sessions: sessionListOriginal);
  }

  Future<void> removeTrack(String trackId) async {
    var tracksOriginal = await dataLoader.loadAllTracks();
    tracksOriginal.removeWhere((track) => track.uid == trackId);
    await _updateAllEventData(tracks: tracksOriginal);
  }
}
