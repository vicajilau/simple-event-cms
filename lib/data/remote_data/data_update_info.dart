import 'package:http/http.dart' as http;

import '../../core/models/models.dart';
import 'commons_services.dart';

class DataUpdateInfo {
  final CommonsServices dataCommons;

  DataUpdateInfo({required this.dataCommons});

  /// Loads speaker information from the speakers.json file
  /// Returns a Future containing a list of speaker data
  Future<http.Response> updateSpeakers(List<Speaker> speakers) async {
    if (speakers.isEmpty) {
      throw Exception("No speakers to update");
    }
    return dataCommons.updateData(
      speakers,
      speakers[0].pathUrl,
      speakers[0].updateMessage,
    );
  }

  /// Loads event_collection agenda information from the agenda.json file
  /// Parses the JSON structure and returns a list of AgendaDay objects
  /// with proper type conversion and validation
  /// Returns a Future containing a list of AgendaDay models
  Future<http.Response> updateAgenda(List<Agenda> agenda) async {
    if (agenda.isEmpty) {
      throw Exception("No agenda to update");
    }
    return dataCommons.updateData(
      agenda,
      agenda[0].pathUrl,
      agenda[0].updateMessage,
    );
  }

  /// Loads sponsor information from the sponsors.json file
  /// Returns a Future containing a list of sponsor data with logos and details
  Future<http.Response> updateSponsors(List<Sponsor> sponsors) async {
    if (sponsors.isEmpty) {
      throw Exception("No sponsors to update");
    }
    return dataCommons.updateData(
      sponsors,
      sponsors[0].pathUrl,
      sponsors[0].updateMessage,
    );
  }

  /// Update events information from the events.json file
  /// Returns a Future containing a list of events data with logos and details
  Future<http.Response> updateEvents(List<Event> events) async {
    if (events.isEmpty) {
      throw Exception("No events to update");
    }
    return dataCommons.updateData(
      events,
      events[0].pathUrl,
      events[0].updateMessage,
    );
  }
}
