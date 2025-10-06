import 'package:sec/core/config/paths_github.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/core/models/models.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;
  final DataLoader dataLoader = getIt<DataLoader>();
  final Organization organization = getIt<Organization>();

  DataUpdateInfo({required this.dataCommons});

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<void> updateSpeaker(Speaker speakers) async {
    var speakersOriginal = await dataLoader.loadSpeakers();

    dataCommons.updateData(
      speakersOriginal,
      speakers,
      "events/${organization.year}/${speakers.pathUrl}",
      speakers.updateMessage,
    );
  }

  /// Loads track information from the agenda.json file
  /// Returns a Future containing a list of track data
  Future<void> updateTrack(Track track) async {
    var trackOriginal = await dataLoader.loadAllTracks();
    dataCommons.updateData(
      trackOriginal,
      track,
      "events/${organization.year}/${PathsGithub.tracksPath}",
      PathsGithub.tracksUpdateMessage,
    );
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<void> updateAgenda(Agenda agenda) async {
    var agendaOriginal = await dataLoader.loadAgendaStructures();
    dataCommons.updateData(
      agendaOriginal,
      agenda,
      "events/${organization.year}/${agenda.pathUrl}",
      agenda.updateMessage,
    );
  }

  /// Loads event agenda day information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<void> updateAgendaDay(AgendaDay agendaDay) async {
    var daysOriginal = await dataLoader.loadAllDays();

    dataCommons.updateData(
      daysOriginal,
      daysOriginal.firstWhere((day) => day.uid == agendaDay.uid),
      "events/${organization.year}/${agendaDay.pathUrl}",
      agendaDay.updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<void> updateSponsors(Sponsor sponsors) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    dataCommons.updateData(
      sponsorOriginal,
      sponsors,
      "events/${organization.year}/${sponsors.pathUrl}",
      sponsors.updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<void> updateEvent(Event event) async {
    var eventsOriginal = await dataLoader.loadEvents();
    dataCommons.updateData(
      eventsOriginal,
      event,
      "events/${organization.year}/${event.pathUrl}",
      event.updateMessage,
    );
  }

  /// Update session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<void> updateSession(Session session) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    dataCommons.updateData(
      sessionListOriginal,
      session,
      "events/${organization.year}/${session.pathUrl}",
      session.updateMessage,
    );
  }

  /// Removes speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<void> removeSpeaker(String speakerId) async {
    var speakersOriginal = await dataLoader.loadSpeakers();
    var speakerToRemove = speakersOriginal.firstWhere(
      (agenda) => agenda.uid == speakerId,
    );
    dataCommons.removeData(
      speakersOriginal,
      speakerToRemove,
      "events/${organization.year}/${speakerToRemove.pathUrl}",
      speakerToRemove.updateMessage,
    );
  }

  /// Removes event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<void> removeAgenda(String agendaId, String eventId) async {
    var agendaOriginal = await dataLoader.loadAgendaStructures();
    var agendaToRemove = agendaOriginal.firstWhere(
      (agenda) => agenda.uid == agendaId,
    );
    dataCommons.removeData(
      agendaOriginal,
      agendaToRemove,
      "events/${organization.year}/${agendaToRemove.pathUrl}",
      agendaToRemove.updateMessage,
    );
  }

  /// Removes sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<void> removeSponsors(String sponsorId) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    var sponsorToRemove = sponsorOriginal.firstWhere(
      (sponsor) => sponsor.uid == sponsorId,
    );
    dataCommons.removeData(
      sponsorOriginal,
      sponsorToRemove,
      "events/${organization.year}/${sponsorToRemove.pathUrl}",
      sponsorToRemove.updateMessage,
    );
  }

  /// Remove events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<void> removeEvent(String eventId) async {
    var eventsOriginal = await dataLoader.loadEvents();
    var eventToRemove = eventsOriginal.firstWhere(
      (event) => event.uid == eventId,
    );
    dataCommons.removeData(
      eventsOriginal,
      eventToRemove,
      "events/${organization.year}/${eventToRemove.pathUrl}",
      eventToRemove.updateMessage,
    );
  }

  /// Removes an agenda day entry from the agenda.json file by its ID.
  /// This function first loads all agenda entries for the year "2025".
  /// It then iterates through each `Agenda` object to find an `AgendaDay`
  /// whose `uid` matches the provided `agendaDayId`.
  /// If a match is found, it calls `dataCommons.removeData` to remove
  /// that specific `AgendaDay` from the corresponding `Agenda`'s list of days.
  /// The path for removal is constructed using the `pathUrl` of the parent `Agenda`.
  /// The update message is also taken from the parent `Agenda`.
  /// Returns a `Future<http.Response>` indicating the outcome of the operation.
  Future<void> removeAgendaDay(String agendaDayId) async {
    var agendaDaysListOriginal = await dataLoader.loadAllDays();
    dataCommons.updateData(
      agendaDaysListOriginal,
      agendaDaysListOriginal.firstWhere((day) => day.uid == agendaDayId),
      "events/${organization.year}/${PathsGithub.daysPath}",
      PathsGithub.daysUpdateMessage,
    );
  }

  /// Removes session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<void> removeSession(String sessionId) async {
    var sessionListOriginal = await dataLoader.loadAllSessions();
    dataCommons.removeData(
      sessionListOriginal,
      sessionListOriginal.firstWhere((session) => session.uid == sessionId),
      "events/${organization.year}/${PathsGithub.sessionsPath}",
      PathsGithub.sessionsUpdateMessage,
    );
  }

  /// Removes track information from the agenda.json file
  /// Returns a Future containing a list of track data
  Future<void> removeTrack(String trackId) async {
    var tracksOriginal = await dataLoader.loadAllTracks();
    dataCommons.updateData(
      // Using updateData as we are modifying an existing agenda by removing a track
      tracksOriginal,
      tracksOriginal.firstWhere((track) => track.uid == trackId),
      "events/${organization.year}/${PathsGithub.tracksPath}",
      PathsGithub.tracksUpdateMessage,
    );
  }
}
