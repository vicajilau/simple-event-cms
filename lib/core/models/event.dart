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

  /// The URL of the YouTube live stream
  final String? youtubeUrl;

  /// Indica si el evento está visible o no
  bool isVisible = true;

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
    this.isVisible = true,
    this.youtubeUrl,
    this.location,
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  }) : super();

  /// Creates a event from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from githubItem.json
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory Event.fromJson(Map<String, dynamic> json) {
    List<Track> tracks = (json['tracks'] != null)
        ? (json['tracks'] as List?)
                  ?.map((item) => Track.fromJson(item))
                  .toList() ??
              []
        : [];
    return Event(
      uid: json["UID"].toString(),
      eventName: json['eventName'],
      year: json['year'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      eventDates: EventDates.fromJson(json['eventDates']),
      description: json['description'],
      youtubeUrl: json['youtubeUrl'],
      isVisible: json['isVisible'] ?? true,
      location: json['location'],
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
      'description': description,
      'location': location,
      'youtubeUrl': youtubeUrl,
      'isVisible': isVisible,
      'tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }

  /// Creates a copy of this event but with the given fields replaced with the new values.
  Event copyWith({
    String? uid,
    String? eventName,
    String? year,
    String? primaryColor,
    String? secondaryColor,
    EventDates? eventDates,
    String? description,
    String? location,
    List<Track>? tracks,
    bool? isVisible,
  }) {
    return Event(
      uid: uid ?? this.uid,
      eventName: eventName ?? this.eventName,
      year: year ?? this.year,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      eventDates: eventDates ?? this.eventDates,
      description: description ?? this.description,
      location: location ?? this.location,
      tracks: tracks ?? this.tracks,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
