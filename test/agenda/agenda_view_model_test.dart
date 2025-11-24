import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          // Devuelve un valor simulado para la clave 'github_key' o lo que necesites
          // Puedes devolver un JSON stringificado o null si quieres probar ese caso.
          return '\"{\\"token\\":\\"token_mocked\\",\\"projectName\\":\\"simple-event-cms\\"}\"';
        }
        return null;
      });

  late AgendaViewModelImp viewModel;
  late MockAgendaUseCase mockAgendaUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  setUpAll(() {
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<List<AgendaDay>>>(
      Result.ok([
        AgendaDay(uid: '01/01/2021', date: '01/01/2021', eventsUID: []),
      ]),
    );
    provideDummy<Result<List<Speaker>>>(
      Result.ok([
        Speaker(
          uid: 'speaker2',
          name: 'Jane Doe',
          bio: '',
          image: '',
          social: Social(),
          eventUIDS: [],
        ),
      ]),
    );
  });
  setUp(() {
    // Clear previous registrations
    getIt.reset();

    mockAgendaUseCase = MockAgendaUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    // Register mocks with get_it
    getIt.registerSingleton<AgendaUseCase>(mockAgendaUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);

    viewModel = AgendaViewModelImp();
  });

  group('AgendaViewModel', () {
    const eventId = 'test-event';
    final agendaDays = [
      AgendaDay(uid: '01/01/2021', date: '01/01/2021', eventsUID: [eventId]),
    ];
    final speakers = [
      Speaker(
        uid: 'speaker1',
        name: 'John Doe',
        bio: '',
        image: '',
        social: Social(),
        eventUIDS: [],
      ),
    ];

    test('initial state is correct', () {
      expect(viewModel.viewState.value, ViewState.isLoading);
      expect(viewModel.agendaDays.value, isEmpty);
      expect(viewModel.speakers.value, isEmpty);
      expect(viewModel.errorMessage, isEmpty);
    });

    test('setup calls loadAgendaDays', () async {
      // Arrange
      when(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(any),
      ).thenAnswer((_) async => Result.ok(agendaDays));
      when(
        mockAgendaUseCase.getSpeakersForEventId(any),
      ).thenAnswer((_) async => Result.ok(speakers));

      // Act
      await viewModel.setup(eventId);

      // Assert
      verify(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
      ).called(1);
    });

    group('loadAgendaDays', () {
      test('success - loads agenda and speakers', () async {
        // Arrange
        when(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).thenAnswer((_) async => Result.ok(agendaDays));
        when(
          mockAgendaUseCase.getSpeakersForEventId(eventId),
        ).thenAnswer((_) async => Result.ok(speakers));

        // Act
        await viewModel.loadAgendaDays(eventId);

        // Assert
        expect(viewModel.viewState.value, ViewState.loadFinished);
        expect(viewModel.agendaDays.value, agendaDays);
        expect(viewModel.speakers.value, speakers);
        verify(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).called(1);
        verify(mockAgendaUseCase.getSpeakersForEventId(eventId)).called(1);
      });

      test('failure - on getAgendaDayByEventIdFiltered', () async {
        // Arrange
        const error = 'Failed to load agenda';
        when(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException(error)));

        // Act
        final result = await viewModel.loadAgendaDays(eventId);

        // Assert
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, error);
        expect(result, isA<Error>());
      });

      test('failure - on getSpeakersForEventId', () async {
        // Arrange
        const error = 'Failed to load speakers';
        when(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).thenAnswer((_) async => Result.ok(agendaDays));
        when(
          mockAgendaUseCase.getSpeakersForEventId(eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException(error)));

        // Act
        await viewModel.loadAgendaDays(eventId);

        // Assert
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, error);
      });
    });

    group('saveSpeaker', () {
      final speaker = Speaker(
        uid: 'speaker2',
        name: 'Jane Doe',
        bio: '',
        image: '',
        social: Social(),
        eventUIDS: [],
      );

      test('success - saves speaker', () async {
        // Arrange
        when(
          mockAgendaUseCase.saveSpeaker(speaker, eventId),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await viewModel.saveSpeaker(speaker, eventId);

        // Assert
        expect(viewModel.viewState.value, ViewState.loadFinished);
        expect(result, isA<Ok>());
      });

      test('failure - on saveSpeaker', () async {
        // Arrange
        const error = 'Failed to save speaker';
        when(
          mockAgendaUseCase.saveSpeaker(speaker, eventId),
        ).thenAnswer((_) async => const Result.error(NetworkException(error)));

        // Act
        final result = await viewModel.saveSpeaker(speaker, eventId);

        // Assert
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, error);
        expect(result, isA<Error>());
      });
    });

    group('removeSessionAndReloadAgenda', () {
      const sessionId = 'session1';

      test('success - removes session and reloads agenda', () async {
        // Arrange
        when(
          mockAgendaUseCase.deleteSession(
            sessionId,
            agendaDayUID: anyNamed('agendaDayUID'),
          ),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).thenAnswer((_) async => Result.ok(agendaDays));
        when(
          mockAgendaUseCase.getSpeakersForEventId(eventId),
        ).thenAnswer((_) async => Result.ok(speakers));

        // Act
        await viewModel.removeSessionAndReloadAgenda(sessionId, eventId);

        // Assert
        verify(
          mockAgendaUseCase.deleteSession(
            sessionId,
            agendaDayUID: anyNamed('agendaDayUID'),
          ),
        ).called(1);
        verify(
          mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
        ).called(1);
      });

      test('failure - on deleteSession', () async {
        // Arrange
        const error = 'Failed to delete session';
        when(
          mockAgendaUseCase.deleteSession(
            sessionId,
            agendaDayUID: anyNamed('agendaDayUID'),
          ),
        ).thenAnswer((_) async => const Result.error(NetworkException(error)));

        // Act
        final result = await viewModel.removeSessionAndReloadAgenda(
          sessionId,
          eventId,
        );

        // Assert
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, error);
        expect(result, isA<Error>());
        verifyNever(mockAgendaUseCase.getAgendaDayByEventIdFiltered(any));
      });
    });

    test('checkToken calls use case', () async {
      // Arrange
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);

      // Act
      final result = await viewModel.checkToken();

      // Assert
      expect(result, isTrue);
      verify(mockCheckTokenSavedUseCase.checkToken()).called(1);
    });
  });
}
