import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/agenda.dart';

void main() {
  group('Agenda Models', () {
    group('AgendaDay', () {
      final json = {
        'UID': 'day1',
        'date': '2024-01-01',
        'eventUID': [
          {'UID': 'event1'}
        ],
        'trackUids': [
          {'UID': 'track1'}
        ]
      };

      test('fromJson should return a valid AgendaDay object', () {
        final agendaDay = AgendaDay.fromJson(json);

        expect(agendaDay.uid, 'day1');
        expect(agendaDay.date, '2024-01-01');
        expect(agendaDay.eventsUID, ['event1']);
        expect(agendaDay.trackUids, ['track1']);
      });

      test('toJson should return a valid JSON object', () {
        final agendaDay = AgendaDay(
          uid: 'day1',
          date: '2024-01-01',
          eventsUID: ['event1'],
          trackUids: ['track1'],
        );

        final result = agendaDay.toJson();

        expect(result['UID'], 'day1');
        expect(result['date'], '2024-01-01');
        expect(result['eventUID'], [
          {'UID': 'event1'}
        ]);
        expect(result['trackUids'], [
          {'UID': 'track1'}
        ]);
      });
    });

    group('Track', () {
      final json = {
        'UID': 'track1',
        'name': 'Track 1',
        'color': '#FFFFFF',
        'eventUid': 'event1',
        'sessionUids': [
          {'UID': 'session1'}
        ]
      };

      test('fromJson should return a valid Track object', () {
        final track = Track.fromJson(json);

        expect(track.uid, 'track1');
        expect(track.name, 'Track 1');
        expect(track.color, '#FFFFFF');
        expect(track.eventUid, 'event1');
        expect(track.sessionUids, ['session1']);
      });

      test('toJson should return a valid JSON object', () {
        final track = Track(
          uid: 'track1',
          name: 'Track 1',
          color: '#FFFFFF',
          eventUid: 'event1',
          sessionUids: ['session1'],
        );

        final result = track.toJson();

        expect(result['UID'], 'track1');
        expect(result['name'], 'Track 1');
        expect(result['color'], '#FFFFFF');
        expect(result['eventUid'], 'event1');
        expect(result['sessionUids'], [
          {'UID': 'session1'}
        ]);
      });
    });

    group('Session', () {
      final json = {
        'UID': 'session1',
        'title': 'Session 1',
        'time': '10:00',
        'speakerUID': 'speaker1',
        'description': 'Description',
        'type': 'talk',
        'eventUID': 'event1',
        'agendaDayUID': 'day1'
      };

      test('fromJson should return a valid Session object', () {
        final session = Session.fromJson(json);

        expect(session.uid, 'session1');
        expect(session.title, 'Session 1');
        expect(session.time, '10:00');
        expect(session.speakerUID, 'speaker1');
        expect(session.description, 'Description');
        expect(session.type, 'talk');
        expect(session.eventUID, 'event1');
        expect(session.agendaDayUID, 'day1');
      });

      test('toJson should return a valid JSON object', () {
        final session = Session(
          uid: 'session1',
          title: 'Session 1',
          time: '10:00',
          speakerUID: 'speaker1',
          description: 'Description',
          type: 'talk',
          eventUID: 'event1',
          agendaDayUID: 'day1',
        );

        final result = session.toJson();

        expect(result['UID'], 'session1');
        expect(result['title'], 'Session 1');
        expect(result['time'], '10:00');
        expect(result['speakerUID'], 'speaker1');
        expect(result['description'], 'Description');
        expect(result['type'], 'talk');
        expect(result['eventUID'], 'event1');
        expect(result['agendaDayUID'], 'day1');
      });
    });
  });
}
