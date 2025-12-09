import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

@GenerateMocks([SecRepository])
void main() {
  late SpeakerUseCaseImp useCase;
  late MockSecRepository mockSecRepository;

  setUpAll(() async{
    mockSecRepository = MockSecRepository();
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    useCase = SpeakerUseCaseImp();
    useCase.repository = mockSecRepository;
    provideDummy<Result<List<Speaker>>>(
      Result.ok([
        Speaker(
          uid: '1',
          name: 'Speaker 1',
          bio: '',
          eventUIDS: ['event1'],
          image: '',
          social: MockSocial(),
        )
      ]),
    );
    provideDummy<Result<void>>(const Result.ok(null));
  });

  group('getSpeakersById', () {
    test(
      'should return a filtered list of speakers when repository call is successful',
      () async {
        // arrange
        final speakers = [
          Speaker(
            uid: '1',
            name: 'Speaker 1',
            bio: '',
            eventUIDS: ['event1'],
            image: '',
            social: MockSocial(),
          ),
          Speaker(
            uid: '2',
            name: 'Speaker 2',
            bio: '',
            eventUIDS: ['event1', 'event2'],
            image: '',
            social: MockSocial(),
          ),
          Speaker(
            uid: '3',
            name: 'Speaker 3',
            bio: '',
            image: '',
            social: MockSocial(),
            eventUIDS: ['event2'],
          ),
        ];
        when(
          mockSecRepository.loadESpeakers(),
        ).thenAnswer((_) async => Result.ok(speakers));

        // act
        final result = await useCase.getSpeakersById('event1');

        // assert
        expect(result, isA<Ok<List<Speaker>>>());
        final filteredList = (result as Ok<List<Speaker>>).value;
        expect(filteredList.length, 2);
        expect(filteredList.any((s) => s.uid == '1'), isTrue);
        expect(filteredList.any((s) => s.uid == '2'), isTrue);
      },
    );

    test('should return an error when repository call fails', () async {
      // arrange
      when(
        mockSecRepository.loadESpeakers(),
      ).thenAnswer((_) async => Result.error(NetworkException('Failed to load')));

      // act
      final result = await useCase.getSpeakersById('event1');

      // assert
      expect(result, isA<Error>());
      expect((result as Error).error, isA<Exception>());
    });
  });

  group('saveSpeaker', () {
    test(
      'should return success when repository saves speaker successfully',
      () async {
        // arrange
        final speaker = Speaker(
          uid: '1',
          name: 'New Speaker',
          bio: '',
          eventUIDS: ['event1'],
          image: '',
          social: MockSocial(),
        );
        when(
          mockSecRepository.saveSpeaker(speaker, 'event1'),
        ).thenAnswer((_) async => Result.ok(null));

        // act
        final result = await useCase.saveSpeaker(speaker, 'event1');

        // assert
        expect(result, isA<Ok>());
        verify(mockSecRepository.saveSpeaker(speaker, 'event1'));
      },
    );

    test(
      'should return an error when repository fails to save speaker',
      () async {
        // arrange
        final speaker = Speaker(
          uid: '1',
          name: 'New Speaker',
          bio: '',
          eventUIDS: ['event1'],
          image: '',
          social: MockSocial(),
        );
        final exception = NetworkException('Save failed');
        when(
          mockSecRepository.saveSpeaker(speaker, 'event1'),
        ).thenAnswer((_) async => Result.error(exception));

        // act
        final result = await useCase.saveSpeaker(speaker, 'event1');

        // assert
        expect(result, isA<Error>());
        expect((result as Error).error, exception);
      },
    );
  });

  group('removeSpeaker', () {
    test(
      'should return success when repository removes speaker successfully',
      () async {
        // arrange
        when(
          mockSecRepository.removeSpeaker('speaker1', 'event1'),
        ).thenAnswer((_) async => Result.ok(null));

        // act
        final result = await useCase.removeSpeaker('speaker1', 'event1');

        // assert
        expect(result, isA<Ok>());
        verify(mockSecRepository.removeSpeaker('speaker1', 'event1'));
      },
    );

    test(
      'should return an error when repository fails to remove speaker',
      () async {
        // arrange
        final exception = NetworkException('Remove failed');
        when(
          mockSecRepository.removeSpeaker('speaker1', 'event1'),
        ).thenAnswer((_) async => Result.error(exception));

        // act
        final result = await useCase.removeSpeaker('speaker1', 'event1');

        // assert
        expect(result, isA<Error>());
        expect((result as Error).error, exception);
      },
    );
  });
}
