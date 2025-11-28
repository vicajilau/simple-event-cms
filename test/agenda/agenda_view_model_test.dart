import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  late AgendaViewModelImp viewModel;
  late MockAgendaUseCase mockAgendaUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;

  setUpAll(() {
    // Mock static call
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<List<AgendaDay>>>(
      Result.ok([
        AgendaDay(
          uid: '2023-01-01',
          date: '2023-01-01',
          eventsUID: const ["event1"],
        ),
      ]),
    );
    provideDummy<Result<void>>(Result.ok(null));
    provideDummy<Result<List<Speaker>>>(
      Result.ok([
        Speaker(
          uid: '1',
          name: 'Speaker 1',
          bio: '',
          social: Social(),
          eventUIDS: ["event1"],
          image: '',
        ),
      ]),
    );
  });

  setUp(() {
    getIt.reset();
    mockAgendaUseCase = MockAgendaUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    getIt.registerSingleton<AgendaUseCase>(mockAgendaUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);

    viewModel = AgendaViewModelImp();
  });

  group('AgendaViewModelImp', () {
    const eventId = 'event1';
    final agendaDays = [
      AgendaDay(uid: '2023-01-01', date: '2023-01-01', eventsUID: [eventId]),
    ];
    final speakers = [
      Speaker(
        uid: '1',
        name: 'Speaker 1',
        bio: '',
        social: Social(),
        eventUIDS: [eventId],
        image: '',
      ),
    ];

    /*test('loadAgendaDays success', () async {
      when(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
      ).thenAnswer((_) async => Result.ok(agendaDays));
      when(
        mockAgendaUseCase.getSpeakersForEventId(eventId),
      ).thenAnswer((_) async => Result.ok(speakers));

      await viewModel.loadAgendaDays(eventId);

      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(viewModel.agendaDays.value, agendaDays);
      expect(viewModel.speakers.value, speakers);
    });*/

    test('loadAgendaDays failure on getting agenda', () async {
      when(mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId)).thenAnswer(
        (_) async => Result.error(NetworkException(('Agenda Error'))),
      );

      await viewModel.loadAgendaDays(eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Agenda Error');
    });

    test('loadAgendaDays failure on getting speakers', () async {
      when(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
      ).thenAnswer((_) async => Result.ok(agendaDays));
      when(mockAgendaUseCase.getSpeakersForEventId(eventId)).thenAnswer(
        (_) async => Result.error(NetworkException(('Speaker Error'))),
      );

      await viewModel.loadAgendaDays(eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Speaker Error');
    });

    test('saveSpeaker success', () async {
      final speaker = speakers.first;
      when(
        mockAgendaUseCase.saveSpeaker(speaker, eventId),
      ).thenAnswer((_) async => Result.ok(null));

      final result = await viewModel.saveSpeaker(speaker, eventId);

      expect(result, isA<Ok>());
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('saveSpeaker failure', () async {
      final speaker = speakers.first;
      when(
        mockAgendaUseCase.saveSpeaker(speaker, eventId),
      ).thenAnswer((_) async => Result.error(NetworkException(('Save Error'))));

      final result = await viewModel.saveSpeaker(speaker, eventId);

      expect(result, isA<Error>());
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Save Error');
    });

    test('removeSessionAndReloadAgenda success', () async {
      const sessionId = 'session1';
      when(
        mockAgendaUseCase.deleteSession(
          sessionId,
          agendaDayUID: anyNamed('agendaDayUID'),
        ),
      ).thenAnswer((_) async => Result.ok(null));
      when(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
      ).thenAnswer((_) async => Result.ok(agendaDays));
      when(
        mockAgendaUseCase.getSpeakersForEventId(eventId),
      ).thenAnswer((_) async => Result.ok(speakers));

      await viewModel.removeSessionAndReloadAgenda(sessionId, eventId);

      verify(
        mockAgendaUseCase.deleteSession(
          sessionId,
          agendaDayUID: anyNamed('agendaDayUID'),
        ),
      ).called(1);
      verify(
        mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId),
      ).called(1);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('removeSessionAndReloadAgenda failure', () async {
      const sessionId = 'session1';
      when(
        mockAgendaUseCase.deleteSession(
          sessionId,
          agendaDayUID: anyNamed('agendaDayUID'),
        ),
      ).thenAnswer((_) async => Result.error(NetworkException('Delete Error')));

      await viewModel.removeSessionAndReloadAgenda(sessionId, eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Delete Error');
      verifyNever(mockAgendaUseCase.getAgendaDayByEventIdFiltered(eventId));
    });

    test('checkToken returns correct value', () async {
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);
      expect(await viewModel.checkToken(), isTrue);

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => false);
      expect(await viewModel.checkToken(), isFalse);
    });
  });
}
