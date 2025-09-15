import 'package:http/http.dart' as http;
import 'package:sec/core/core.dart';

import '../../../core/models/models.dart';
import '../common/commons_services.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;

  DataUpdateInfo({required this.dataCommons});

  Future<DataLoader> getDataLoader() async {
    final config = await ConfigLoader.loadConfig();
    final organization = await ConfigLoader.loadOrganization();
    return DataLoader(config, organization);
  }

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeaker(Speaker speakers) async {
    var dataLoader = await getDataLoader();
    var speakersOriginal = await dataLoader.loadSpeakers("2025");

    return dataCommons.updateData(
      speakersOriginal,
      speakers,
      "events/2025/${speakers.pathUrl}",
      speakers.updateMessage,
    );
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(Agenda agenda) async {
    var dataLoader = await getDataLoader();
    var agendaOriginal = await dataLoader.loadAgenda("2025");
    return dataCommons.updateData(
      agendaOriginal,
      agenda,
      "events/2025/${agenda.pathUrl}",
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
    var dataLoader = await getDataLoader();
    var agendaOriginal = await dataLoader.loadAgenda("2025");

    return dataCommons.updateData(
      agendaOriginal,
      agenda,
      "events/2025/${agenda.pathUrl}",
      agenda.updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(Sponsor sponsors) async {
    var dataLoader = await getDataLoader();
    var sponsorOriginal = await dataLoader.loadSponsors("2025");
    return dataCommons.updateData(
      sponsorOriginal,
      sponsors,
      "events/2025/${sponsors.pathUrl}",
      sponsors.updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvent(Event event) async {
    var dataLoader = await getDataLoader();
    var eventsOriginal = await dataLoader.loadEvents("2025");
    return dataCommons.updateData(
      eventsOriginal,
      event,
      "events/2025/${event.pathUrl}",
      event.updateMessage,
    );
  }
}
