import '../../core/models/agenda.dart';

/*void _editSession(
    String date,
    String trackName,
    Session sessionToEdit,
    ) async {
  AgendaDay agendaDayEdited = await _navigateTo(
    _eventFormScreen(day: date, track: trackName, session: sessionToEdit),
  );

  _removeSessionFromAgenda(agendaDayEdited.tracks.first.sessions.first);
  _insertSessionToAgenda(agendaDayEdited);

  _refreshAgendaState();
}

void _insertSessionToAgenda(AgendaDay agendaDay) {

  AgendaDay? targetDay = _agendaDays.firstWhere(
        (d) => d.date == agendaDay.date,
    orElse: () => AgendaDay(date: agendaDay.date, tracks: []),
  );

  Track? targetTrack = targetDay.tracks.firstWhere(
        (t) => t.name == agendaDay.tracks.first.name,
    orElse: () {
      final newTrack = Track(
        color: '',
        name: agendaDay.tracks.first.name,
        sessions: [],
      );
      targetDay.tracks.add(newTrack);
      return newTrack;
    },
  );

  targetTrack.sessions.add(editedSession);
  _sortSessionsByStartTime(targetTrack);

  if (!_agendaDays.any((d) => d.date == targetDay.date)) {
    _agendaDays.add(targetDay);
  }
  _sortAgendaDaysByDate();
}

void _sortSessionsByStartTime(Track track) {
  track.sessions.sort((a, b) {
    final aMinutes = TimeUtils.parseStartTimeToMinutes(a.time);
    final bMinutes = TimeUtils.parseStartTimeToMinutes(b.time);
    return aMinutes.compareTo(bMinutes);
  });
}

void _sortAgendaDaysByDate() {
  _agendaDays.sort((a, b) {
    final aDate = DateTime.parse(a.date);
    final bDate = DateTime.parse(b.date);
    return aDate.compareTo(bDate);
  });
}

void _removeSessionFromAgenda(Session sessionToRemove) {
  for (var agendaDay in _agendaDays) {
    for (var track in agendaDay.tracks) {
      track.sessions.removeWhere((s) => s.uid == sessionToRemove.uid);
    }
  }
}*/