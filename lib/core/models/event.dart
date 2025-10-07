import '../config/paths_github.dart';
import 'agenda.dart';
import 'event_dates.dart';
import 'github/github_model.dart';

/// Main configuration class for the event_collection site
/// Contains all the essential information needed to configure and display an event_collection
/// including branding, dates, venue, and deployment settings
class Event extends GitHubModel {
  /// The name of the event_collection (e.g., "DevFest Spain 2025")
  final String eventName;



  /// The year of the event_collection, used for organizing multi-year events
  final String year;

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

  String agendaUID;
  final List<String> speakersUID;
  final List<String> sponsorsUID;
  /// the name of the room where the event_collection will take place
  final List<Track> tracks;

  /// Creates a new event instance
  Event({
    required super.uid,
    required this.tracks,
    required this.eventName,
    required this.year,
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
  }) : super();

  /// Creates a event from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from events.json
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory Event.fromJson(Map<String, dynamic> json) {
    List<String> speakers = (json['speakersUID'] != null)
        ? (json['speakersUID'] as List)
              .map((item) => item['UID'].toString())
              .toList()
        : [];
    List<String> sponsors = (json['sponsorsUID'] != null)
        ? (json['sponsorsUID'] as List)
              .map((item) => item['UID'].toString())
              .toList()
        : [];
    List<Track> tracks = (json['tracks'] != null)
        ? (json['tracks'] as List)
            .map((item) => Track.fromJson(item))
            .toList()
        : [];
    var agendaUID = json['agendaUID'].toString();
    return Event(
      uid: json["UID"].toString(),
      eventName: json['eventName'],
      year: json['year'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      eventDates: EventDates.fromJson(json['eventDates']),
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
      description: json['description'],
      agendaUID: agendaUID,
      speakersUID: speakers,
      sponsorsUID: sponsors,
      tracks: tracks,
    );
  }

  /// Converts the event instance to a JSON object
  @override
  Map<String, dynamic> toJson() {
    return {
      'UID': uid,
      'eventName': eventName,
      'year': year,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'eventDates': eventDates.toJson(),
      'venue': venue?.toJson(),
      'description': description,
      'agendaUID': agendaUID,
      'speakersUID': speakersUID.map((uid) => {'UID': uid}).toList(),
      'sponsorsUID': sponsorsUID.map((uid) => {'UID': uid}).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }
}
