import 'package:sec/core/config/paths_github.dart';

import 'github/github_model.dart';

/// Represents a single day in the event agenda, linking to tracks by their UIDs.
class AgendaDay extends GitHubModel {
  String date;
  List<String> eventsUID;
  List<String>? trackUids = [];
  List<Track>? resolvedTracks; // Field for in-memory resolved objects

  AgendaDay({
    required super.uid,
    required this.date,
    this.trackUids,
    required this.eventsUID,
    this.resolvedTracks, // Allow initialization
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  });

  factory AgendaDay.fromJson(Map<String, dynamic> json) {
    return AgendaDay(
      uid: json['UID'],
      date: json['date'],
      eventsUID:
          (json['eventUID'] as List<dynamic>?)
              ?.map<String>((trackUid) => trackUid['UID'].toString())
              .toSet()
              .toList() ??
          [],
      trackUids:
          (json['trackUids'] as List?)
              ?.map<String>((trackUid) => trackUid['UID'].toString())
              .toSet()
              .toList() ??
          [],
      // resolvedTracks will be populated by DataLoader
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "date": date,
    "eventUID": eventsUID.toSet().map((uid) => {'UID': uid}).toList(),
    "trackUids": trackUids
        ?.map((uid) => {'UID': uid})
        .toList(), // Only UIDs are serialized
  };
}

/// Represents a track or room, linking to sessions by their UIDs.
class Track extends GitHubModel {
  String name;
  String eventUid;
  final String color;
  List<String> sessionUids = [];
  List<Session> resolvedSessions =
      []; // Field for in-memory resolved objects, order might matter for display.

  Track({
    required super.uid,
    required this.name,
    required this.color,
    required this.sessionUids,
    required this.eventUid,
    this.resolvedSessions = const [], // Allow initialization
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      uid: json['UID'].toString(),
      name: json['name'],
      color: json['color'],
      eventUid: json['eventUid'],
      sessionUids: (json['sessionUids'] as List<dynamic>)
          .map<String>((sessionUid) => sessionUid['UID'].toString())
          .toSet()
          .toList(),
      // resolvedSessions will be populated by DataLoader
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "color": color,
    "sessionUids": sessionUids
        .map((uid) => {'UID': uid})
        .toList(), // Only UIDs are serialized
    "eventUid": eventUid,
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
  final String agendaDayUID;
  final String eventUID;

  Session({
    required super.uid,
    required this.title,
    required this.time,
    required this.speakerUID,
    required this.eventUID,
    required this.agendaDayUID,
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
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
      eventUID: json['eventUID'],
      agendaDayUID: json['agendaDayUID'],
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
    "eventUID": eventUID,
    "agendaDayUID": agendaDayUID,
  };
}
