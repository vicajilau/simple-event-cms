class PathsGithub {
  // Paths for data loading
  static const String agendaPath = 'config/agenda.json';
  static const String daysPath = 'agendaDays/agenda_days.json';
  static const String tracksPath = 'tracks/tracks.json';
  static const String sessionsPath = 'sessions/sessions.json';
  
  static const String eventPath = 'config/events.json';
  static const String organizationPath = 'organization/organization.json';
  static const String speakerPath = 'speakers/speakers.json';
  static const String sponsorPath = 'sponsors/sponsors.json';

  // Messages for PUT requests to GitHub commits
  static const String agendaUpdateMessage = 'Update agenda structure from JSON';
  static const String daysUpdateMessage = 'Update days from JSON';
  static const String tracksUpdateMessage = 'Update tracks from JSON';
  static const String sessionsUpdateMessage = 'Update sessions from JSON';
  
  static const String eventUpdateMessage = 'Update events from JSON';
  static const String organizationUpdateMessage =
      'Update organization from JSON';
  static const String speakerUpdateMessage = 'Update speakers from JSON';
  static const String sponsorUpdateMessage = 'Update sponsors from JSON';
}
