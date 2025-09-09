import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/models/sponsor.dart';

import 'agenda.dart';
import 'event_dates.dart';

/// Main configuration class for the event site
/// Contains all the essential information needed to configure and display an event
/// including branding, dates, venue, and deployment settings
class SiteConfig {
  final String uid;

  /// The name of the event (e.g., "DevFest Spain 2025")
  final String eventName;

  /// the name of the room where the event will take place
  final List<String> rooms;

  /// The year of the event, used for organizing multi-year events
  final String year;

  /// The base URL for data loading (local assets or remote URLs)
  final String baseUrl;

  /// Primary color for the event theme in hex format (e.g., "#4285F4")
  final String primaryColor;

  /// Secondary color for the event theme in hex format (e.g., "#34A853")
  final String secondaryColor;

  /// Event date information including start, end dates and timezone
  final EventDates? eventDates;

  /// Venue information where the event will take place
  final Venue? venue;

  /// Optional description of the event
  final String? description;

  final String agendaUID;
  final List<String> speakersUID;
  final List<String> sponsorsUID;

  Agenda? agenda;
  List<Speaker>? speakers;
  List<Sponsor>? sponsors;

  /// Creates a new SiteConfig instance
  SiteConfig({
    required this.uid,
    required this.rooms,
    required this.eventName,
    required this.year,
    required this.baseUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.agendaUID,
    required this.speakersUID,
    required this.sponsorsUID,
    this.eventDates,
    this.venue,
    this.description,
  });

  /// Creates a SiteConfig from JSON data with additional parameters
  ///
  /// The [json] parameter contains the configuration data from site.json
  /// The [baseUrl] parameter specifies where to load data from (local or remote)
  /// The [year] parameter identifies which event year this configuration represents
  ///
  /// Optional fields (eventDates, venue, description) will be null if not provided
  factory SiteConfig.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
    required String year,
  }) {
    EventDates? eventDates;
    if (json['eventDates'] != null) {
      eventDates = EventDates.fromJson(json['eventDates']);
    }
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
    return SiteConfig(
      uid: json["UID"],
      eventName: json['eventName'],
      year: year,
      baseUrl: baseUrl,
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      eventDates: eventDates,
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
      description: json['description'],
      agendaUID: agendaUID,
      speakersUID: speakers,
      sponsorsUID: sponsors,
      rooms: rooms,
    );
  }

  /// Converts the SiteConfig instance to a JSON object
  Map<String, dynamic> toJson(SiteConfig siteConfig) {
    return {
      'uid': siteConfig.uid,
      'eventName': siteConfig.eventName,
      'year': siteConfig.year,
      'baseUrl': siteConfig.baseUrl,
      'primaryColor': siteConfig.primaryColor,
      'secondaryColor': siteConfig.secondaryColor,
      'eventDates': siteConfig.eventDates?.toJson(),
      'venue': siteConfig.venue?.toJson(),
      'description': siteConfig.description,
      'agendaUID': agendaUID,
      'speakersUID': speakersUID.map((uid) => {'UID': uid}).toList(),
      'sponsorsUID': sponsorsUID.map((uid) => {'UID': uid}).toList(),
      'room': siteConfig.rooms.map((name) => {'name': name}).toList(),
    };
  }
}
