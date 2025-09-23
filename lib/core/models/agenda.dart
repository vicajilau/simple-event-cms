// ignore: dangling_library_doc_comments
import 'package:sec/core/config/paths_github.dart';

import 'github/github_model.dart';

/// Represents a single day in the event_collection agenda
/// Contains the date and list of tracks for that day
/// Day name is automatically derived from the date using localization

class Agenda extends GitHubModel {
  final List<AgendaDay> days;

  Agenda({
    required super.uid,
    required this.days,
    super.pathUrl = PathsGithub.agendaPath,
    super.updateMessage = PathsGithub.agendaUpdateMessage,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      uid: json["UID"],
      days: (json["days"] as List)
          .map((dayJson) => AgendaDay.fromJson(dayJson))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {"UID": uid, "days": days};
}

class AgendaDay extends GitHubModel {
  /// The date of the event_collection day in ISO format (YYYY-MM-DD)
  final String date;

  /// List of tracks/rooms available on this day
  final List<Track> tracks;

  /// Creates a new AgendaDay instance
  AgendaDay({
    required super.uid,
    required this.date,
    required this.tracks,
    super.pathUrl = PathsGithub.agendaPath,
    super.updateMessage = PathsGithub.agendaUpdateMessage,
  });

  /// Creates an AgendaDay from JSON data
  /// Parses the tracks array and converts each track to a Track object
  /// The day name is automatically generated from the date using localization
  factory AgendaDay.fromJson(Map<String, dynamic> json) {
    return AgendaDay(
      uid: json['UID'],
      date: json['date'],
      tracks: (json['tracks'] as List)
          .map((track) => Track.fromJson(track))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {"UID": uid, "date": date, "tracks": tracks};
}

/// Represents a track or room within an event_collection day
/// Contains track information and the sessions scheduled for that track
class Track extends GitHubModel {

  /// The name or identifier of the track/room (e.g., "Main Hall", "Room A")
  final String name;

  /// The color associated with this track for UI theming (hex format)
  final String color;

  /// List of sessions scheduled for this track
  final List<Session> sessions;

  /// Creates a new Track instance
  Track({
    required super.uid,
    required this.name,
    required this.color,
    required this.sessions,
    super.pathUrl = PathsGithub.agendaPath,
    super.updateMessage = PathsGithub.agendaUpdateMessage,
  });

  /// Creates a Track from JSON data
  /// Parses the sessions array and converts each session to a Session object
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      uid: json['UID'],
      name: json['name'],
      color: json['color'],
      sessions: (json['sessions'] as List)
          .map((session) => Session.fromJson(session))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid, "name": name, "color": color, "sessions": sessions
  };
}

/// Represents an individual session within a track
/// Contains all the details about a specific presentation, talk, or activity
class Session extends GitHubModel {
  /// The title of the session
  final String title;

  /// The time slot for the session (e.g., "09:00 - 10:00")
  final String time;

  /// The name of the speaker presenting this session
  final String speaker;

  /// A detailed description of the session content
  final String? description;

  /// The type of session (e.g., "keynote", "talk", "workshop", "break")
  final String type;

  /// Creates a new Session instance
  Session({
    required super.uid,
    required this.title,
    required this.time,
    required this.speaker,
    super.pathUrl = PathsGithub.sessionPath,
    super.updateMessage = PathsGithub.sessionUpdateMessage,
    this.description,
    required this.type,
  });

  /// Creates a Session from JSON data
  /// All fields are required and must be present in the JSON
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      uid: json['UID'],
      title: json['title'],
      time: json['time'],
      speaker: json['speaker'],
      description: json['description'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "title": title,
    "time": time,
    "speaker": speaker,
    "description": description,
    "type": type,
  };
}
