import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

@GenerateMocks([SecRepository])
void main() {
  late SponsorUseCaseImp useCase;
  late MockSecRepository mockSecRepository;

  setUpAll(() async{
    mockSecRepository = MockSecRepository();
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    provideDummy<Result<List<Sponsor>>>(Result.ok([]));
    provideDummy<Result<void>>(Result.ok(null));
    useCase = SponsorUseCaseImp();
    useCase.repository = mockSecRepository;
  });

  group('getSponsorByIds', () {
    test(
      'should return a list of sponsors when the repository returns a list of sponsors',
      () async {
        // arrange
        final sponsors = [
          Sponsor(
            uid: '1',
            name: 'Sponsor 1',
            logo: 'logo1',
            eventUID: 'event1',
            type: '',
            website: '',
          ),
          Sponsor(
            uid: '2',
            name: 'Sponsor 2',
            logo: 'logo2',
            eventUID: 'event1',
            type: '',
            website: '',
          ),
          Sponsor(
            uid: '3',
            name: 'Sponsor 3',
            logo: 'logo3',
            eventUID: 'event2',
            type: '',
            website: '',
          ),
        ];
        when(
          mockSecRepository.loadSponsors(),
        ).thenAnswer((_) async => Result.ok(sponsors));
        // act
        final result = await useCase.getSponsorByIds('event1');
        // assert
        expect(result, isA<Ok<List<Sponsor>>>());
        expect((result as Ok<List<Sponsor>>).value.length, 2);
      },
    );

    test(
      'should return an error when the repository returns an error',
      () async {
        // arrange
        when(
          mockSecRepository.loadSponsors(),
        ).thenAnswer((_) async => Result.error(NetworkException('error')));
        // act
        final result = await useCase.getSponsorByIds('event1');
        // assert
        expect(result, isA<Error>());
      },
    );
  });

  group('saveSponsor', () {
    test(
      'should return a success when the repository saves the sponsor',
      () async {
        // arrange
        final sponsor = Sponsor(
          uid: '1',
          name: 'Sponsor 1',
          logo: 'logo1',
          eventUID: 'event1',
          type: '',
          website: '',
        );
        when(
          mockSecRepository.saveSponsor(sponsor, 'event1'),
        ).thenAnswer((_) async => Result.ok(null));
        // act
        final result = await useCase.saveSponsor(sponsor, 'event1');
        // assert
        expect(result, isA<Ok>());
      },
    );

    test(
      'should return an error when the repository fails to save the sponsor',
      () async {
        // arrange
        final sponsor = Sponsor(
          uid: '1',
          name: 'Sponsor 1',
          logo: 'logo1',
          eventUID: 'event1',
          type: '',
          website: '',
        );
        when(
          mockSecRepository.saveSponsor(sponsor, 'event1'),
        ).thenAnswer((_) async => Result.error(NetworkException('error')));
        // act
        final result = await useCase.saveSponsor(sponsor, 'event1');
        // assert
        expect(result, isA<Error>());
      },
    );
  });

  group('removeSponsor', () {
    test(
      'should return a success when the repository removes the sponsor',
      () async {
        // arrange
        when(
          mockSecRepository.removeSponsor('1'),
        ).thenAnswer((_) async => Result.ok(null));
        // act
        final result = await useCase.removeSponsor('1');
        // assert
        expect(result, isA<Ok>());
      },
    );

    test(
      'should return an error when the repository fails to remove the sponsor',
      () async {
        // arrange
        when(
          mockSecRepository.removeSponsor('1'),
        ).thenAnswer((_) async => Result.error(NetworkException('error')));
        // act
        final result = await useCase.removeSponsor('1');
        // assert
        expect(result, isA<Error>());
      },
    );
  });
}
