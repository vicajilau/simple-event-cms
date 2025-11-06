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

  /// Optional description of the event_collection
  final String? description;
  
  /// The location of the event
  final String? location;

  /// the name of the room where the event_collection will take place
  final List<Track> tracks;

  /// Indica si el evento está visible o no
  bool isVisible = true;

  /// Lista de sesiones del evento
  final List<Session> sessions;

  /// Lista de días de la agenda del evento
  final List<AgendaDay> agendadays;

  /// Lista de patrocinadores del evento
  final List<Sponsor> sponsors;

  /// Lista de ponentes del evento
  final List<Speaker> speakers;

  /// Indica si el evento debe abrirse por defecto
  bool openAtTheBeggining = false;

  /// Creates a new event instance
  Event({
    required super.uid,
    required this.tracks,
    required this.eventName,
    required this.year,
    required this.primaryColor,
    required this.secondaryColor,
    required this.eventDates,
    this.description,
    this.sessions = const [],
    this.agendadays = const [],
    this.sponsors = const [],
    this.speakers = const [],
    this.isVisible = true,
    this.openAtTheBeggining = false,
    this.location,
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  }) : super();

  /// Creates a event from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from events.json
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory Event.fromJson(Map<String, dynamic> json) {
    List<Track> tracks = (json['tracks'] != null)
        ? (json['tracks'] as List?)
            ?.map((item) => Track.fromJson(item))
            .toList() ?? []
        : [];
    List<Session> sessions = (json['sessions'] != null)
        ? (json['sessions'] as List?)?.map((item) => Session.fromJson(item)).toList() ?? []
        : [];
    List<AgendaDay> agendadays = (json['agendadays'] != null)
        ? (json['agendadays'] as List?)
            ?.map((item) => AgendaDay.fromJson(item))
            .toList() ?? []
        : [];
    List<Sponsor> sponsors = (json['sponsors'] != null)
        ? (json['sponsors'] as List?)?.map((item) => Sponsor.fromJson(item)).toList() ?? []
        : [];
    List<Speaker> speakers = (json['speakers'] != null)
        ? (json['speakers'] as List?)?.map((item) => Speaker.fromJson(item)).toList() ?? []
        : [];
    return Event(
      uid: json["UID"].toString(),
      eventName: json['eventName'],
      year: json['year'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      eventDates: EventDates.fromJson(json['eventDates']),
      description: json['description'],
      isVisible: json['isVisible'] ?? true,
      openAtTheBeggining: json['openAtTheBeggining'] ?? false,
      location: json['location'],
      tracks: tracks,
      sessions: sessions,
      agendadays: agendadays,
      sponsors: sponsors,
      speakers: speakers,
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
      'description': description,
      'location': location,
      'isVisible': isVisible,
      'openAtTheBeggining': openAtTheBeggining,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'agendadays': agendadays.map((day) => day.toJson()).toList(),
      'sponsors': sponsors.map((sponsor) => sponsor.toJson()).toList(),
      'speakers': speakers.map((speaker) => speaker.toJson()).toList(),
    };
  }
}
