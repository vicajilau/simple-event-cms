import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/models/speaker.dart';

void main() {
  group('Speaker Models', () {
    group('Speaker', () {
      final json = {
        'UID': 'speaker1',
        'name': 'Speaker Name',
        'bio': 'Speaker Bio',
        'image': 'https://example.com/image.png',
        'social': {
          'linkedin': 'https://linkedin.com',
          'twitter': 'https://twitter.com',
          'website': 'https://example.com',
          'github': 'https://github.com'
        },
        'eventUIDS': [
          {'UID': 'event1'}
        ]
      };

      test('fromJson should return a valid Speaker object', () {
        final speaker = Speaker.fromJson(json);

        expect(speaker.uid, 'speaker1');
        expect(speaker.name, 'Speaker Name');
        expect(speaker.bio, 'Speaker Bio');
        expect(speaker.image, 'https://example.com/image.png');
        expect(speaker.social.linkedin, 'https://linkedin.com');
        expect(speaker.eventUIDS, ['event1']);
      });

      test('toJson should return a valid JSON object', () {
        final speaker = Speaker(
          uid: 'speaker1',
          name: 'Speaker Name',
          bio: 'Speaker Bio',
          image: 'https://example.com/image.png',
          social: Social(linkedin: 'https://linkedin.com'),
          eventUIDS: ['event1'],
        );

        final result = speaker.toJson();

        expect(result['UID'], 'speaker1');
        expect(result['name'], 'Speaker Name');
        expect(result['bio'], 'Speaker Bio');
        expect(result['image'], 'https://example.com/image.png');
        expect(result['social']['linkedin'], 'https://linkedin.com');
        expect(result['eventUIDS'], [
          {'UID': 'event1'}
        ]);
      });

      test('copyWith should create a copy with the given fields replaced', () {
        final speaker = Speaker(
          uid: 'speaker1',
          name: 'Speaker Name',
          bio: 'Speaker Bio',
          image: 'https://example.com/image.png',
          social: Social(),
          eventUIDS: [],
        );

        final newSpeaker = speaker.copyWith(name: 'New Name', bio: 'New Bio');

        expect(newSpeaker.name, 'New Name');
        expect(newSpeaker.bio, 'New Bio');
        expect(newSpeaker.uid, speaker.uid);
      });
    });

    group('Social', () {
      final json = {
        'linkedin': 'https://linkedin.com',
        'twitter': 'https://twitter.com',
        'website': 'https://example.com',
        'github': 'https://github.com'
      };

      test('fromJson should return a valid Social object', () {
        final social = Social.fromJson(json);

        expect(social.linkedin, 'https://linkedin.com');
        expect(social.twitter, 'https://twitter.com');
        expect(social.website, 'https://example.com');
        expect(social.github, 'https://github.com');
      });

      test('toJson should return a valid JSON object', () {
        final social = Social(
          linkedin: 'https://linkedin.com',
          twitter: 'https://twitter.com',
          website: 'https://example.com',
          github: 'https://github.com',
        );

        final result = social.toJson();

        expect(result['linkedin'], 'https://linkedin.com');
        expect(result['twitter'], 'https://twitter.com');
        expect(result['website'], 'https://example.com');
        expect(result['github'], 'https://github.com');
      });
    });
  });
}
