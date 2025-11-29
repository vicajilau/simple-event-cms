import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  late EventFormViewModelImpl viewModel;
  late MockEventUseCase mockEventUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;

  setUp(() {
    getIt.reset();
    mockEventUseCase = MockEventUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    getIt.registerSingleton<EventUseCase>(mockEventUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);

    viewModel = EventFormViewModelImpl();
    provideDummy<Result<void>>(const Result.ok(null));
  });

  group('EventFormViewModelImpl', () {
    final event = Event(
      uid: '1',
      eventName: 'Test Event',
      eventDates: EventDates(
        startDate: '2023-01-01',
        endDate: '2023-01-01',
        timezone: 'UTC',
        uid: 'EVENTDATE_UID',
      ),
      tracks: [],
      primaryColor: '',
      secondaryColor: '',
      isVisible: true,
      year: '',
    );

    test('onSubmit returns true on success', () async {
      when(
        mockEventUseCase.prepareAgendaDays(event),
      ).thenAnswer((_) async => Result.ok(null));
      when(mockEventUseCase.saveEvent(event)).thenAnswer((_) async => Result.ok(null));

      final result = await viewModel.onSubmit(event);

      expect(result, isTrue);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test(
      'onSubmit returns false and sets error state on prepareAgendaDays failure',
      () async {
        when(
          mockEventUseCase.prepareAgendaDays(event),
        ).thenAnswer((_) async => Result.error(NetworkException('Prepare error')));

        final result = await viewModel.onSubmit(event);

        expect(result, isFalse);
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, 'Prepare error');
      },
    );

    test(
      'onSubmit returns false and sets error state on saveEvent failure',
      () async {
        when(
          mockEventUseCase.prepareAgendaDays(event),
        ).thenAnswer((_) async => Result.ok(null));
        when(
          mockEventUseCase.saveEvent(event),
        ).thenAnswer((_) async => Result.error(NetworkException('Save error')));

        final result = await viewModel.onSubmit(event);

        expect(result, isFalse);
        expect(viewModel.viewState.value, ViewState.error);
        expect(viewModel.errorMessage, 'Save error');
      },
    );

    test('removeTrack succeeds', () async {
      when(
        mockEventUseCase.removeTrack('track1'),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.removeTrack('track1');

      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('removeTrack handles error', () async {
      when(
        mockEventUseCase.removeTrack('track1'),
      ).thenAnswer((_) async => Result.error(NetworkException('Remove error')));

      await viewModel.removeTrack('track1');

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Remove error');
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
