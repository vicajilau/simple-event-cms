import 'package:sec/core/models/models.dart';

/// Main configuration class for the event_collection site
/// Contains all the essential information needed to configure and display an event_collection
/// including branding, dates, venue, and deployment settings
class GithubJsonModel {
  final List<Event> events;

  /// the name of the room where the event_collection will take place
  final List<Track> tracks;

  /// Lista de sesiones del evento
  final List<Session> sessions;

  /// Lista de días de la agenda del evento
  final List<AgendaDay> agendadays;

  /// Lista de patrocinadores del evento
  final List<Sponsor> sponsors;

  /// Lista de ponentes del evento
  final List<Speaker> speakers;

  /// Creates a new event instance
  GithubJsonModel({
    this.events = const [],
    this.tracks = const [],
    this.sessions = const [],
    this.agendadays = const [],
    this.sponsors = const [],
    this.speakers = const [],
  }) : super();

  /// Creates a event from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from githubItem.json
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory GithubJsonModel.fromJson(Map<String, dynamic> json) {
    List<Event> events = (json['events'] != null)
        ? (json['events'] as List?)
                  ?.map((item) => Event.fromJson(item))
                  .toList() ??
              []
        : [];
    List<Track> tracks = (json['tracks'] != null)
        ? (json['tracks'] as List?)
                  ?.map((item) => Track.fromJson(item))
                  .toList() ??
              []
        : [];
    List<Session> sessions = (json['sessions'] != null)
        ? (json['sessions'] as List?)
                  ?.map((item) => Session.fromJson(item))
                  .toList() ??
              []
        : [];
    List<AgendaDay> agendadays = (json['agendadays'] != null)
        ? (json['agendadays'] as List?)
                  ?.map((item) => AgendaDay.fromJson(item))
                  .toList() ??
              []
        : [];
    List<Sponsor> sponsors = (json['sponsors'] != null)
        ? (json['sponsors'] as List?)
                  ?.map((item) => Sponsor.fromJson(item))
                  .toList() ??
              []
        : [];
    List<Speaker> speakers = (json['speakers'] != null)
        ? (json['speakers'] as List?)
                  ?.map((item) => Speaker.fromJson(item))
                  .toList() ??
              []
        : [];
    return GithubJsonModel(
      events: events,
      tracks: tracks,
      sessions: sessions,
      agendadays: agendadays,
      sponsors: sponsors,
      speakers: speakers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((event) => event.toJson()).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'agendadays': agendadays.map((day) => day.toJson()).toList(),
      'sponsors': sponsors.map((sponsor) => sponsor.toJson()).toList(),
      'speakers': speakers.map((speaker) => speaker.toJson()).toList(),
    };
  }
}
