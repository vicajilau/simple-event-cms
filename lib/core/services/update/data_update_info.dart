import 'package:http/http.dart' as http;

import '../../models/models.dart';
import '../commons/commons_services.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;

  DataUpdateInfo({required this.dataCommons});

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeakers(List<Speaker> speakers) async {
    return dataCommons.updateData(
      speakers,
      speakers[0].pathUrl,
      speakers[0].updateMessage,
    );
  }

  /// Loads event agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(List<Agenda> agenda) async {
    return dataCommons.updateData(
      agenda,
      agenda[0].pathUrl,
      agenda[0].updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(List<Sponsor> sponsors) async {
    return dataCommons.updateData(
      sponsors,
      sponsors[0].pathUrl,
      sponsors[0].updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvents(List<Event> events) async {
    return dataCommons.updateData(
      events,
      events[0].pathUrl,
      events[0].updateMessage,
    );
  }
}
