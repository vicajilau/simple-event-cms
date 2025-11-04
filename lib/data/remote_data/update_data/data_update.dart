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

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<void> updateSpeaker(Speaker speakers) async {
    var speakersOriginal = await dataLoader.loadSpeakers();

    await dataCommons.updateData(
      speakersOriginal,
      speakers,
      "events/${speakers.pathUrl}",
      speakers.updateMessage,
    );
  }

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<void> updateSpeakers(List<Speaker> speakers) async {
    await dataCommons.updateDataList(
      speakers,
      "events/${PathsGithub.speakerPath}",
      PathsGithub.speakerUpdateMessage,
    );
  }

  /// Loads track information from the agenda.json file
  /// Returns a Future containing a list of track data
  Future<void> updateTrack(Track track) async {
    var trackOriginal = await dataLoader.loadAllTracks();
    await dataCommons.updateData(
      trackOriginal,
      track,
      "events/${PathsGithub.tracksPath}",
      PathsGithub.tracksUpdateMessage,
    );
  }

  /// Loads track information from the agenda.json file
  /// Returns a Future containing a list of track data
  Future<void> updateTracks(List<Track> tracks) async {
    await dataCommons.updateDataList(
      tracks,
      "events/${PathsGithub.tracksPath}",
      PathsGithub.tracksUpdateMessage,
    );
  }

  /// Loads event agenda day information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<void> updateAgendaDay(AgendaDay agendaDay) async {
    var daysOriginal = await dataLoader.loadAllDays();

    await dataCommons.updateData(
      daysOriginal,
      agendaDay,
      "events/${agendaDay.pathUrl}",
      agendaDay.updateMessage,
    );
  }

  /// Loads event agenda day information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<void> updateAgendaDays(
    List<AgendaDay> agendaDays, {
    bool overrideData = false,
  }) async {
    var agendaDaysRepo = (await dataLoader.loadAllDays());
    if (overrideData == false) {
      agendaDaysRepo
          .toList()
          .where(
            (day) =>
                !agendaDays.map((agendaDay) => agendaDay.uid).contains(day.uid),
          )
          .toList();
      agendaDaysRepo.addAll(agendaDays);
    } else {
      agendaDaysRepo.toList().removeWhere(
        (day) => day.eventsUID.contains(agendaDays.first.eventsUID.first),
      );
      agendaDaysRepo.addAll(agendaDays);
    }
    await dataCommons.updateDataList(
      agendaDays,
      "events/${PathsGithub.daysPath}",
      PathsGithub.daysUpdateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<void> updateSponsors(Sponsor sponsors) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    await dataCommons.updateData(
      sponsorOriginal,
      sponsors,
      "events/${sponsors.pathUrl}",
      sponsors.updateMessage,
    );
  }

  /// Loads organization information from the organization.json file
  Future<void> updateOrganization(Organization organization) async {
    await dataCommons.updateSingleData(
      organization,
      "events/${organization.pathUrl}",
      organization.updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<void> updateSponsorsList(List<Sponsor> sponsors) async {
    await dataCommons.updateDataList(
      sponsors,
      "events/${PathsGithub.sponsorPath}",
      PathsGithub.sponsorUpdateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<void> updateEvent(Event event) async {
    var eventsOriginal = await dataLoader.loadEvents();
    await dataCommons.updateData(
      eventsOriginal,
      event,
      "events/${event.pathUrl}",
      event.updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<void> updateEvents(List<Event> events) async {
    await dataCommons.updateDataList(
      events,
      "events/${PathsGithub.eventPath}",
      PathsGithub.eventUpdateMessage,
    );
  }

  /// Update session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<void> updateSession(Session session) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    await dataCommons.updateData(
      sessionListOriginal,
      session,
      "events/${session.pathUrl}",
      session.updateMessage,
    );
  }

  /// Update session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<void> updateSessions(List<Session> sessions) async {
    await dataCommons.updateDataList(
      sessions,
      "events/${PathsGithub.sessionsPath}",
      PathsGithub.sessionsUpdateMessage,
    );
  }

  /// Removes speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<void> removeSpeaker(String speakerId) async {
    var speakersOriginal = await dataLoader.loadSpeakers();
    var speakerToRemove = speakersOriginal.firstWhere(
      (agenda) => agenda.uid == speakerId,
    );
    await dataCommons.removeData(
      speakersOriginal,
      speakerToRemove,
      "events/${speakerToRemove.pathUrl}",
      speakerToRemove.updateMessage,
    );
  }

  /// Removes sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<void> removeSponsors(String sponsorId) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    var sponsorToRemove = sponsorOriginal.firstWhere(
      (sponsor) => sponsor.uid == sponsorId,
    );
    await dataCommons.removeData(
      sponsorOriginal,
      sponsorToRemove,
      "events/${sponsorToRemove.pathUrl}",
      sponsorToRemove.updateMessage,
    );
  }

  /// Remove events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<void> removeEvent(String eventId) async {
    var eventsOriginal = await dataLoader.loadEvents();
    var tracksOriginal = (await dataLoader.loadAllTracks());
    var sessionsOriginal = (await dataLoader.loadAllSessions());
    var daysOriginal = (await dataLoader.loadAllDays());
    List<AgendaDay> eventDays = [];
    List<Session> sessionsFromEvent = [];
    Event? eventToRemove;
    if (daysOriginal.indexWhere((day) => day.eventsUID.contains(eventId)) !=
        -1) {
      for (var value in daysOriginal) {
        if (value.eventsUID.contains(eventId)) {
          value.eventsUID.remove(eventId);
        }
        if (value.eventsUID.isNotEmpty) {
          eventDays.add(value);
        }
      }
      if (eventDays.isNotEmpty) {
        await dataCommons.updateDataList(
          eventDays,
          "events/${eventDays.first.pathUrl}",
          eventDays.first.updateMessage,
        );
      }
    }
    if (sessionsOriginal.indexWhere((session) => session.eventUID == eventId) !=
        -1) {
      sessionsFromEvent = sessionsOriginal
          .where((session) => session.eventUID == eventId)
          .toList();
    }
    if (eventsOriginal.indexWhere((event) => event.uid == eventId) != -1) {
      eventToRemove = eventsOriginal.firstWhere(
        (event) => event.uid == eventId,
      );
    }
    if (sessionsFromEvent.isNotEmpty) {
      await dataCommons.removeDataList(
        sessionsOriginal,
        sessionsFromEvent,
        "events/${sessionsFromEvent.first.pathUrl}",
        sessionsFromEvent.first.updateMessage,
      );
    }

    if (eventToRemove != null) {
      if (eventToRemove.tracks.isNotEmpty) {
        await dataCommons.removeDataList(
          tracksOriginal,
          eventToRemove.tracks,
          "events/${eventToRemove.tracks.first.pathUrl}",
          eventToRemove.tracks.first.updateMessage,
        );
      }

      await dataCommons.removeData(
        eventsOriginal,
        eventToRemove,
        "events/${eventToRemove.pathUrl}",
        eventToRemove.updateMessage,
      );
    }
  }

  /// Removes an agenda day entry from the agenda.json file by its ID.
  /// It then iterates through each `Agenda` object to find an `AgendaDay`
  /// whose `uid` matches the provided `agendaDayId`.
  /// If a match is found, it calls `dataCommons.removeData` to remove
  /// that specific `AgendaDay` from the corresponding `Agenda`'s list of days.
  /// The path for removal is constructed using the `pathUrl` of the parent `Agenda`.
  /// The update message is also taken from the parent `Agenda`.
  /// Returns a `Future<http.Response>` indicating the outcome of the operation.
  Future<void> removeAgendaDay(String agendaDayId) async {
    var agendaDaysListOriginal = await dataLoader.loadAllDays();

    await dataCommons.removeData(
      agendaDaysListOriginal,
      agendaDaysListOriginal.firstWhere((day) => day.uid == agendaDayId),
      "events/${PathsGithub.daysPath}",
      PathsGithub.daysUpdateMessage,
    );
  }

  /// Removes session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<void> removeSession(String sessionId) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    await dataCommons.removeData(
      sessionListOriginal,
      sessionListOriginal.firstWhere((session) => session.uid == sessionId),
      "events/${PathsGithub.sessionsPath}",
      PathsGithub.sessionsUpdateMessage,
    );
  }

  /// Removes track information from the agenda.json file
  /// Returns a Future containing a list of track data
  Future<void> removeTrack(String trackId) async {
    var tracksOriginal = await dataLoader.loadAllTracks();
    await dataCommons.removeData(
      // Using updateData as we are modifying an existing agenda by removing a track
      tracksOriginal,
      tracksOriginal.firstWhere((track) => track.uid == trackId),
      "events/${PathsGithub.tracksPath}",
      PathsGithub.tracksUpdateMessage,
    );
  }
}
