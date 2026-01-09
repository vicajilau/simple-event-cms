import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';

import '../../helpers/test_helpers.dart';
import '../../mocks.mocks.dart';

@GenerateMocks([SecRepository])
void main() {
  late EventUseCaseImp useCase;
  late MockSecRepository mockSecRepository;

  setUpAll(() async {
    mockSecRepository = MockSecRepository();
    getIt.registerSingleton<SecRepository>(mockSecRepository);
    useCase = EventUseCaseImp();
    useCase.repository = mockSecRepository;
    provideDummy<Result<void>>(Result.ok(null));
    provideDummy<Result<List<Event>>>(Result.ok([]));

  });

  group('EventUseCase', () {
    final event1 = Event(
      uid: '1',
      eventName: 'Event 1',
      eventDates: EventDates(
        startDate: '2024-01-01',
        endDate: '2024-01-02',
        timezone: 'gmt',
        uid: 'test_event_date_1',
      ),
      primaryColor: 'ff0000',
      secondaryColor: '00ff00',
      isVisible: true,
      tracks: [],
      year: '',
    );
    final eventWithoutStartDate = Event(
      uid: '1',
      eventName: 'Event 1',
      eventDates: EventDates(
        startDate: '',
        endDate: '2024-01-01',
        timezone: 'gmt',
        uid: 'test_event_date_1',
      ),
      primaryColor: 'ff0000',
      secondaryColor: '00ff00',
      isVisible: true,
      tracks: [],
      year: '',
    );
    final eventWithoutEndDate = Event(
      uid: '1',
      eventName: 'Event 1',
      eventDates: EventDates(
        startDate: '2024-01-01',
        endDate: '',
        timezone: 'gmt',
        uid: 'test_event_date_1',
      ),
      primaryColor: 'ff0000',
      secondaryColor: '00ff00',
      isVisible: true,
      tracks: [],
      year: '',
    );
    final event2 = Event(
      uid: '2',
      eventName: 'Event 2',
      eventDates: EventDates(
        startDate: '2024-02-01',
        endDate: '2024-02-02',
        timezone: 'gmt',
        uid: 'test_event_date_2',
      ),
      primaryColor: 'ff0000',
      secondaryColor: '00ff00',
      isVisible: true,
      tracks: [],
      year: '',
    );
    final events = [event1, event2];

    test('getEvents returns a list of events on success', () async {
      when(
        mockSecRepository.loadEvents(),
      ).thenAnswer((_) async => Result.ok(events));
      final result = await useCase.getEvents();
      expect(result, isA<Ok<List<Event>>>());
      expect((result as Ok<List<Event>>).value, events);
    });
    test('getEvents returns an error on failure', () async {
      when(
        mockSecRepository.loadEvents(),
      ).thenAnswer((_) async => Result.error(GithubException('')));
      final result = await useCase.getEvents();
      expect(result, isA<Error>());
      expect((result as Error).error, isA<GithubException>());
    });

    test('prepareAgendaDays without end date succeeds', () async {
      when(
        mockSecRepository.saveAgendaDays(
          any,
          any,
          overrideAgendaDays: anyNamed('overrideAgendaDays'),
        ),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.prepareAgendaDays(eventWithoutEndDate);
      verify(
        mockSecRepository.saveAgendaDays(any, eventWithoutEndDate.uid, overrideAgendaDays: true),
      );
    });
    test('prepareAgendaDays returns an error on failure', () async {
      when(
        mockSecRepository.saveAgendaDays(
          any,
          any,
          overrideAgendaDays: anyNamed('overrideAgendaDays'),
        ),
      ).thenAnswer((_) async => Result.ok(null));
      final result = await useCase.prepareAgendaDays(eventWithoutStartDate);
      expect(result, isA<Error>());
    });

    test('getEventById returns an event on success', () async {
      when(
        mockSecRepository.loadEvents(),
      ).thenAnswer((_) async => Result.ok(events));
      final result = await useCase.getEventById('1');
      expect(result, isA<Ok<Event?>>());
      expect((result as Ok<Event?>).value, event1);
    });
    test('getEventById returns an error on failure', () async {
      when(
        mockSecRepository.loadEvents(),
      ).thenAnswer((_) async => Result.error(GithubException('')));
      final result = await useCase.getEventById('1');
      expect(result, isA<Error>());
      expect((result as Error).error, isA<GithubException>());
    });

    test('saveEvent calls repository', () async {
      when(
        mockSecRepository.saveEvent(event1),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.saveEvent(event1);
      verify(mockSecRepository.saveEvent(event1));
    });

    test(
      'prepareAgendaDays creates correct number of days for date range',
      () async {
        when(
          mockSecRepository.saveAgendaDays(
            any,
            any,
            overrideAgendaDays: anyNamed('overrideAgendaDays'),
          ),
        ).thenAnswer((_) async => Result.ok(null));
        await useCase.prepareAgendaDays(event1);
        verify(
          mockSecRepository.saveAgendaDays(any, '1', overrideAgendaDays: true),
        );
      },
    );

    test('removeEvent calls repository', () async {
      when(
        mockSecRepository.removeEvent('1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.removeEvent(event1);
      verify(mockSecRepository.removeEvent('1'));
    });

    test('removeTrack calls repository', () async {
      when(
        mockSecRepository.removeTrack('track1'),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.removeTrack('track1');
      verify(mockSecRepository.removeTrack('track1'));
    });

    test('updateConfig calls repository', () async {
      final config = Config(
        eventForcedToViewUID: 'event1',
        configName: '',
        primaryColorOrganization: '',
        secondaryColorOrganization: '',
        githubUser: '',
        projectName: '',
        branch: '',
      );
      when(
        mockSecRepository.saveConfig(config),
      ).thenAnswer((_) async => Result.ok(null));
      await useCase.updateConfig(config);
      verify(mockSecRepository.saveConfig(config));
    });
  });
}
