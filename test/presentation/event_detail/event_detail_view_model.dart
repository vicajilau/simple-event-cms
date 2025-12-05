import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../mocks.mocks.dart';

@GenerateMocks([EventUseCase, CheckTokenSavedUseCase, Config])
void main() {
  late EventDetailViewModelImp viewModel;
  late MockEventUseCase mockEventUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  late MockConfig mockConfig;

  setUp(() {
    getIt.reset();
    mockEventUseCase = MockEventUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();
    mockConfig = MockConfig();

    getIt.registerSingleton<EventUseCase>(mockEventUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
    getIt.registerSingleton<Config>(mockConfig);

    viewModel = EventDetailViewModelImp();

    // Mock SecureInfo static methods
  });

  final testEvents = [
    Event(uid: '1', eventName: 'Event 1', tracks: [], year: '', primaryColor: '', secondaryColor: '', eventDates: MockEventDates()),
    Event(uid: '2', eventName: 'Event 2', tracks: [], year: '', primaryColor: '', secondaryColor: '', eventDates: MockEventDates()),
  ];

  test('Initial state is isLoading', () {
    expect(viewModel.viewState.value, ViewState.isLoading);
  });

  group('loadEventData', () {
    test('Should load events and set state to loadFinished', () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok(testEvents));
      when(mockConfig.eventForcedToViewUID).thenReturn(null);

      await viewModel.loadEventData('1');

      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(viewModel.eventTitle.value, 'Event 1');
      expect(viewModel.event, testEvents.first);
      expect(viewModel.notShowReturnArrow.value, isFalse);
    });

    test('Should set error state when use case returns error', () async {
      final exception = NetworkException('Failed to load');
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.error(exception));

      await viewModel.loadEventData('1');

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, contains('Failed to load'));
    });

    test('Should set error state when there are no events', () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok([]));

      await viewModel.loadEventData('1');

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, contains('there aren,t any events to show'));
    });

     test('notShowReturnArrow should be true when there is only one event and no token', () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok([testEvents.first]));

      await viewModel.loadEventData('1');

      expect(viewModel.notShowReturnArrow.value, isTrue);
    });

    test('notShowReturnArrow should be true when event is forced and no token', () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok(testEvents));
      when(mockConfig.eventForcedToViewUID).thenReturn('1');

      await viewModel.loadEventData('1');

      expect(viewModel.notShowReturnArrow.value, isTrue);
    });

    test('notShowReturnArrow should be false when token exists', () async {
      SecureInfo.saveGithubKey(GithubData(token: "false_token",projectName: ""));
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok([testEvents.first]));

      await viewModel.loadEventData('1');

      expect(viewModel.notShowReturnArrow.value, isFalse);
    });
  });

  group('setup', () {
    test('Should call loadEventData when argument is a string', () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok(testEvents));
      when(mockConfig.eventForcedToViewUID).thenReturn(null);

      await viewModel.setup('1');

      verify(mockEventUseCase.getEvents()).called(1);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });
  });

  group('checkToken', () {
    test('Should return true when token is saved', () async {
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => true);

      final result = await viewModel.checkToken();

      expect(result, isTrue);
    });

    test('Should return false when token is not saved', () async {
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => false);

      final result = await viewModel.checkToken();

      expect(result, isFalse);
    });
  });
}
