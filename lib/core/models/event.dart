import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/models/sponsor.dart';

import '../config/paths_github.dart';
import 'agenda.dart';
import 'event_dates.dart';
import 'github/github_model.dart';

/// Main configuration class for the event_collection site
/// Contains all the essential information needed to configure and display an event_collection
/// including branding, dates, venue, and deployment settings
class Event extends GitHubModel {
  @override
  final String uid;

  /// The name of the event_collection (e.g., "DevFest Spain 2025")
  final String eventName;

  /// the name of the room where the event_collection will take place
  final List<String> tracks;

  /// The year of the event_collection, used for organizing multi-year events
  final String year;

  /// The base URL for data loading (local assets or remote URLs)
  final String baseUrl;

  /// Primary color for the event_collection theme in hex format (e.g., "#4285F4")
  final String primaryColor;

  /// Secondary color for the event_collection theme in hex format (e.g., "#34A853")
  final String secondaryColor;

  /// Event date information including start, end dates and timezone
  final EventDates eventDates;

  /// Venue information where the event_collection will take place
  final Venue? venue;

  /// Optional description of the event_collection
  final String? description;

  final String agendaUID;
  final List<String> speakersUID;
  final List<String> sponsorsUID;

  Agenda? agenda;
  List<Speaker>? speakers;
  List<Sponsor>? sponsors;

  /// Creates a new event instance
  Event({
    required this.uid,
    required this.tracks,
    required this.eventName,
    required this.year,
    required this.baseUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.agendaUID,
    required this.speakersUID,
    required this.sponsorsUID,
    required this.eventDates,
    this.venue,
    this.description,
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  }) : super(uid: '');

  /// Creates a event from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from site.json
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory Event.fromJson(Map<String, dynamic> json) {
    List<String> speakers = (json['speakersUID'] != null)
        ? (json['speakersUID'] as List)
              .map((item) => item['UID'] as String)
              .toList()
        : [];
    List<String> sponsors = (json['sponsorsUID'] != null)
        ? (json['sponsorsUID'] as List)
              .map((item) => item['UID'] as String)
              .toList()
        : [];
    List<String> rooms = (json['rooms'] != null)
        ? (json['rooms'] as List).map((item) => item['name'] as String).toList()
        : [];
    var agendaUID = json['agendaUID'];
    return Event(
      uid: json["UID"],
      eventName: json['eventName'],
      year: json['year'],
      baseUrl: json['baseUrl'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      eventDates: EventDates.fromJson(json['eventDates']),
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
      description: json['description'],
      agendaUID: agendaUID,
      speakersUID: speakers,
      sponsorsUID: sponsors,
      tracks: rooms,
    );
  }

  /// Converts the event instance to a JSON object
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'eventName': eventName,
      'year': year,
      'baseUrl': baseUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'eventDates': eventDates.toJson(),
      'venue': venue?.toJson(),
      'description': description,
      'agendaUID': agendaUID,
      'speakersUID': speakersUID.map((uid) => {'UID': uid}).toList(),
      'sponsorsUID': sponsorsUID.map((uid) => {'UID': uid}).toList(),
      'room': tracks.map((name) => {'name': name}).toList(),
    };
  }
}
