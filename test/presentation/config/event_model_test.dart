import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/event_dates.dart';

void main() {
  group('Event Model', () {
    final json = {
      'UID': 'event1',
      'eventName': 'Test Event',
      'year': '2024',
      'primaryColor': '#FFFFFF',
      'secondaryColor': '#000000',
      'eventDates': {
        'startDate': '2024-01-01',
        'endDate': '2024-01-02',
        'timezone': 'UTC'
      },
      'description': 'Description',
      'youtubeUrl': 'https://youtube.com',
      'isVisible': true,
      'location': 'Location',
      'tracks': []
    };

    test('fromJson should return a valid Event object', () {
      final event = Event.fromJson(json);

      expect(event.uid, 'event1');
      expect(event.eventName, 'Test Event');
      expect(event.year, '2024');
      expect(event.primaryColor, '#FFFFFF');
      expect(event.secondaryColor, '#000000');
      expect(event.eventDates.startDate, '2024-01-01');
      expect(event.description, 'Description');
      expect(event.youtubeUrl, 'https://youtube.com');
      expect(event.isVisible, true);
      expect(event.location, 'Location');
    });

    test('toJson should return a valid JSON object', () {
      final event = Event(
        uid: 'event1',
        eventName: 'Test Event',
        year: '2024',
        primaryColor: '#FFFFFF',
        secondaryColor: '#000000',
        eventDates: EventDates(startDate: '2024-01-01', endDate: '2024-01-02', timezone: 'UTC', uid: ''),
        description: 'Description',
        youtubeUrl: 'https://youtube.com',
        isVisible: true,
        location: 'Location',
        tracks: [],
      );

      final result = event.toJson();

      expect(result['UID'], 'event1');
      expect(result['eventName'], 'Test Event');
      expect(result['year'], '2024');
      expect(result['primaryColor'], '#FFFFFF');
      expect(result['secondaryColor'], '#000000');
      expect(result['eventDates']['startDate'], '2024-01-01');
      expect(result['description'], 'Description');
      expect(result['youtubeUrl'], 'https://youtube.com');
      expect(result['isVisible'], true);
      expect(result['location'], 'Location');
    });

    test('copyWith should create a copy with the given fields replaced', () {
      final event = Event(
        uid: 'event1',
        eventName: 'Test Event',
        year: '2024',
        primaryColor: '#FFFFFF',
        secondaryColor: '#000000',
        eventDates: EventDates(startDate: '2024-01-01', endDate: '2024-01-02', timezone: 'UTC', uid: ''),
        tracks: [],
      );

      final newEvent = event.copyWith(eventName: 'New Name', isVisible: false);

      expect(newEvent.eventName, 'New Name');
      expect(newEvent.isVisible, false);
      expect(newEvent.year, event.year);
    });
  });
}
