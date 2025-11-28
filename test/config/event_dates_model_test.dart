import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/event_dates.dart';

void main() {
  group('EventDates Model', () {
    final json = {
      'UID': 'dates1',
      'startDate': '2024-01-01',
      'endDate': '2024-01-03',
      'timezone': 'UTC'
    };

    test('fromJson should return a valid EventDates object', () {
      final eventDates = EventDates.fromJson(json);

      expect(eventDates.uid, 'dates1');
      expect(eventDates.startDate, '2024-01-01');
      expect(eventDates.endDate, '2024-01-03');
      expect(eventDates.timezone, 'UTC');
    });

    test('toJson should return a valid JSON object', () {
      final eventDates = EventDates(
        uid: 'dates1',
        startDate: '2024-01-01',
        endDate: '2024-01-03',
        timezone: 'UTC',
      );

      final result = eventDates.toJson();

      expect(result['UID'], 'dates1');
      expect(result['startDate'], '2024-01-01');
      expect(result['endDate'], '2024-01-03');
      expect(result['timezone'], 'UTC');
    });

    test('getFormattedDaysInDateRange should return the correct list of days', () {
      final eventDates = EventDates(
        uid: 'dates1',
        startDate: '2024-01-01',
        endDate: '2024-01-03',
        timezone: 'UTC',
      );

      final result = eventDates.getFormattedDaysInDateRange();

      expect(result, [
        '2024-01-01',
        '2024-01-02',
        '2024-01-03',
      ]);
    });
  });

  group('Venue Model', () {
    final json = {
      'name': 'Venue Name',
      'address': 'Venue Address',
      'city': 'Venue City'
    };

    test('fromJson should return a valid Venue object', () {
      final venue = Venue.fromJson(json);

      expect(venue.name, 'Venue Name');
      expect(venue.address, 'Venue Address');
      expect(venue.city, 'Venue City');
    });

    test('toJson should return a valid JSON object', () {
      final venue = Venue(
        name: 'Venue Name',
        address: 'Venue Address',
        city: 'Venue City',
      );

      final result = venue.toJson();

      expect(result['name'], 'Venue Name');
      expect(result['address'], 'Venue Address');
      expect(result['city'], 'Venue City');
    });
  });
}
