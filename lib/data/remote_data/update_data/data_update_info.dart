import 'package:http/http.dart' as http;
import 'package:sec/core/core.dart';
import 'package:sec/core/di/dependency_injection.dart';

import '../../../core/models/models.dart';
import '../common/commons_services.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;
  final DataLoader dataLoader = getIt<DataLoader>();
  final Organization organization = getIt<Organization>();

  DataUpdateInfo({required this.dataCommons});

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeaker(Speaker speakers) async {
    var speakersOriginal = await dataLoader.loadSpeakers();

    return dataCommons.updateData(
      speakersOriginal,
      speakers,
      "events/${organization.year}/${speakers.pathUrl}",
      speakers.updateMessage,
    );
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(Agenda agenda) async {
    var agendaOriginal = await dataLoader.loadAgenda();
    return dataCommons.updateData(
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
  Future<http.Response> updateAgendaDay(
    AgendaDay agendaDay,
    Agenda agenda,
  ) async {
    var agendaOriginal = await dataLoader.loadAgenda();

    return dataCommons.updateData(
      agendaOriginal,
      agenda,
      "events/${organization.year}/${agenda.pathUrl}",
      agenda.updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(Sponsor sponsors) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    return dataCommons.updateData(
      sponsorOriginal,
      sponsors,
      "events/${organization.year}/${sponsors.pathUrl}",
      sponsors.updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvent(Event event) async {
    var eventsOriginal = await dataLoader.loadEvents();
    return dataCommons.updateData(
      eventsOriginal,
      event,
      "events/${organization.year}/${event.pathUrl}",
      event.updateMessage,
    );
  }

  /// Removes speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> removeSpeaker(String speakerId) async {
    var speakersOriginal = await dataLoader.loadSpeakers();
    var speakerToRemove = speakersOriginal.firstWhere(
      (agenda) => agenda.uid == speakerId,
    );
    return dataCommons.removeData(
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
  Future<http.Response> removeAgenda(String agendaId) async {
    var agendaOriginal = await dataLoader.loadAgenda();
    var agendaToRemove = agendaOriginal.firstWhere(
      (agenda) => agenda.uid == agendaId,
    );
    return dataCommons.removeData(
      agendaOriginal,
      agendaToRemove,
      "events/${organization.year}/${agendaToRemove.pathUrl}",
      agendaToRemove.updateMessage,
    );
  }

  /// Removes sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> removeSponsors(String sponsorId) async {
    var sponsorOriginal = await dataLoader.loadSponsors();
    var sponsorToRemove = sponsorOriginal.firstWhere(
      (sponsor) => sponsor.uid == sponsorId,
    );
    return dataCommons.removeData(
      sponsorOriginal,
      sponsorToRemove,
      "events/${organization.year}/${sponsorToRemove.pathUrl}",
      sponsorToRemove.updateMessage,
    );
  }

  /// Remove events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> removeEvent(String eventId) async {
    var eventsOriginal = await dataLoader.loadEvents();
    var eventToRemove = eventsOriginal.firstWhere(
      (event) => event.uid == eventId,
    );
    return dataCommons.removeData(
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
  Future<http.Response> removeAgendaDayById(String agendaDayId) async {
    var agendaListOriginal = await dataLoader.loadAgenda();
    Agenda agendaToRemove = agendaListOriginal.firstWhere(
      (agenda) => agenda.days.any((day) => day.uid == agendaDayId),
    );
    AgendaDay agendaDayToRemove = agendaToRemove.days.firstWhere(
      (day) => day.uid == agendaDayId,
    );
    agendaToRemove.days.remove(agendaDayToRemove);
    // Note: This modifies the parentAgenda's days list, but the actual removal from the remote data
    // will be handled by dataCommons.removeData logic, which might need adjustment
    // if it's not designed to handle removal of sub-items within a larger JSON object structure.
    // For now, we assume dataCommons.removeData can handle this by path.
    return dataCommons.updateData(
      agendaListOriginal,
      agendaToRemove,
      "events/${organization.year}/${agendaToRemove.pathUrl}",
      agendaToRemove.updateMessage,
    );
  }

  /// Add session information to the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<http.Response> addSession(Session session, String agendaId,String agendaDayId, String trackId) async {
    var sessionsOriginal = await dataLoader.addSessionIntoAgenda(agendaId,agendaDayId,trackId,session);
    return dataCommons.updateData(
      sessionsOriginal,
      session,
      "events/${organization.year}/${session.pathUrl}",
      session.updateMessage,
    );
  }
  /// Update session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<http.Response> updateSession(Session session, String agendaId,String agendaDayId, String trackId) async {
    var agendaListOriginal = await dataLoader.loadAgenda();
    var agendaWithSessionEdited = await dataLoader.editSessionsFromAgendaId(agendaId,agendaDayId,trackId,session);
    return dataCommons.updateData(
      agendaListOriginal,
      agendaWithSessionEdited,
      "events/${organization.year}/${session.pathUrl}",
      session.updateMessage,
    );
  }

  /// Removes session information from the sessions.json file
  /// Returns a Future containing a list of sessions data
  Future<http.Response> removeSession(Session session, String agendaId,String agendaDayId, String trackId) async {
    var agendaListOriginal = await dataLoader.loadAgenda();
    var agendaWithoutSession = await dataLoader.removeSessionsFromAgendaId(agendaId,agendaDayId,trackId,session);
    return dataCommons.removeData(
      agendaListOriginal,
      agendaWithoutSession,
      "events/${organization.year}/${session.pathUrl}",
      session.updateMessage,
    );
  }
}
