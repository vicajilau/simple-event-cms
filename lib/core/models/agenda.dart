import 'package:sec/core/config/paths_github.dart';
import 'github/github_model.dart';

/// Represents the overall structure of the event agenda, linking to days by their UIDs.
class Agenda extends GitHubModel {
  List<String> dayUids;
  List<AgendaDay>? resolvedDays = []; // Field for in-memory resolved objects

  Agenda({
    required super.uid,
    required this.dayUids,
    this.resolvedDays, // Allow initialization
    super.pathUrl = PathsGithub.agendaPath,
    super.updateMessage = PathsGithub.agendaUpdateMessage,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      uid: json["UID"].toString(),
      dayUids: (json["days"] as List)
          .map((dayUid) => dayUid["UID"].toString())
          .toList(),
      // resolvedDays will be populated by DataLoader
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "days": dayUids.map((uid) => {'UID': uid}).toList(), // Only UIDs are serialized
  };
}

/// Represents a single day in the event agenda, linking to tracks by their UIDs.
class AgendaDay extends GitHubModel {
  final String date;
  List<String> trackUids;
  List<Track>? resolvedTracks; // Field for in-memory resolved objects

  AgendaDay({
    required super.uid,
    required this.date,
    required this.trackUids,
    this.resolvedTracks, // Allow initialization
    super.pathUrl = PathsGithub.daysPath,
    super.updateMessage = PathsGithub.daysUpdateMessage,
  });

  factory AgendaDay.fromJson(Map<String, dynamic> json) {
    return AgendaDay(
      uid: json['UID'].toString(),
      date: json['date'],
      trackUids: (json['tracks'] as List)
          .map((trackUid) => trackUid["UID"].toString())
          .toList(),
      // resolvedTracks will be populated by DataLoader
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "date": date,
    "tracks": trackUids, // Only UIDs are serialized
  };
}

/// Represents a track or room, linking to sessions by their UIDs.
class Track extends GitHubModel {
  final String name;
  final String color;
  List<String> sessionUids;
  List<Session>? resolvedSessions; // Field for in-memory resolved objects

  Track({
    required super.uid,
    required this.name,
    required this.color,
    required this.sessionUids,
    this.resolvedSessions, // Allow initialization
    super.pathUrl = PathsGithub.tracksPath,
    super.updateMessage = PathsGithub.tracksUpdateMessage,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      uid: json['UID'].toString(),
      name: json['name'],
      color: json['color'],
      sessionUids: (json['sessions'] as List)
          .map((sessionUid) => sessionUid['UID'].toString())
          .toList(),
      // resolvedSessions will be populated by DataLoader
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "color": color,
    "sessions": sessionUids.map((uid) => {'UID': uid}).toList(), // Only UIDs are serialized
  };
}

/// Represents an individual session within a track.
/// Its structure remains largely the same, but path and message are updated.
class Session extends GitHubModel {
  final String title;
  final String time;
  String? speakerUID;
  final String? description;
  final String type;

  Session({
    required super.uid,
    required this.title,
    required this.time,
    required this.speakerUID,
    super.pathUrl = PathsGithub.sessionsPath,
    super.updateMessage = PathsGithub.sessionsUpdateMessage,
    this.description,
    required this.type,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      uid: json['UID'].toString(),
      title: json['title'],
      time: json['time'],
      speakerUID: json['speakerUID'],
      description: json['description'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "title": title,
    "time": time,
    "speakerUID": speakerUID,
    "description": description,
    "type": type,
  };
}
