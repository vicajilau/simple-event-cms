import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/sponsor.dart';

void main() {
  group('Sponsor Model', () {
    final json = {
      'UID': 'sponsor1',
      'name': 'Sponsor Name',
      'type': 'Sponsor Type',
      'logo': 'https://example.com/logo.png',
      'website': 'https://example.com',
      'eventUID': 'event1'
    };

    test('fromJson should return a valid Sponsor object', () {
      final sponsor = Sponsor.fromJson(json);

      expect(sponsor.uid, 'sponsor1');
      expect(sponsor.name, 'Sponsor Name');
      expect(sponsor.type, 'Sponsor Type');
      expect(sponsor.logo, 'https://example.com/logo.png');
      expect(sponsor.website, 'https://example.com');
      expect(sponsor.eventUID, 'event1');
    });

    test('toJson should return a valid JSON object', () {
      final sponsor = Sponsor(
        uid: 'sponsor1',
        name: 'Sponsor Name',
        type: 'Sponsor Type',
        logo: 'https://example.com/logo.png',
        website: 'https://example.com',
        eventUID: 'event1',
      );

      final result = sponsor.toJson();

      expect(result['UID'], 'sponsor1');
      expect(result['name'], 'Sponsor Name');
      expect(result['type'], 'Sponsor Type');
      expect(result['logo'], 'https://example.com/logo.png');
      expect(result['website'], 'https://example.com');
      expect(result['eventUID'], 'event1');
    });
  });
}
