import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/widgets/event_filter_button.dart';
import 'package:sec/presentation/view_model_common.dart';
import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockEventUseCase mockEventUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  late EventCollectionViewModelImp viewModel;

  setUp(() async {
    getIt.reset();
    mockEventUseCase = MockEventUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();
    getIt.registerSingleton<EventUseCase>(mockEventUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
    final configString = await rootBundle.loadString(
      'events/config/config.json',
    );
    final configJson = jsonDecode(configString) as Map<String, dynamic>;
    getIt.registerSingleton<Config>(Config.fromJson(configJson));
    provideDummy<Result<List<Event>>>(const Result.ok([]));
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<Event?>>(const Result.ok(null));

    viewModel = EventCollectionViewModelImp();
  });
  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          if (methodCall.arguments['key'] == 'read') {
            return '{"token":"token_mocked","projectName":"simple-event-cms"}';
          } else if (methodCall.arguments['key'] == 'github_key') {
            return 'some_github_key';
          }
        }
        return null;
      });

  final testEvent = Event(
    uid: "event_UID_TEST",
    eventName: "Test Event",
    tracks: [],
    year: "2025",
    primaryColor: "#00000",
    secondaryColor: "#00000",
    eventDates: EventDates(
      uid: "eventDates_UID",
      startDate: DateTime.now()
          .add(const Duration(days: 365))
          .toIso8601String(),
      endDate: DateTime.now().add(const Duration(days: 370)).toIso8601String(),
      timezone: "Europe/Madrid",
    ),
    isVisible: true,
  );
  final testEvent2 = Event(
    uid: "event_UID_TEST2",
    eventName: "Test Event",
    tracks: [],
    year: "2025",
    primaryColor: "#00000",
    secondaryColor: "#00000",
    eventDates: EventDates(
      uid: "eventDates_UID",
      startDate: DateTime.now()
          .add(const Duration(days: 365))
          .toIso8601String(),
      endDate: DateTime.now().add(const Duration(days: 370)).toIso8601String(),
      timezone: "Europe/Madrid",
    ),
    isVisible: true,
  );

  group('EventCollectionViewModel', () {
    test('loadEvents success', () async {
      when(mockEventUseCase.getEvents()).thenAnswer(
        (_) async =>
            Result.ok([testEvent, testEvent2]),
      );

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);


      await viewModel.loadEvents();
      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(
        viewModel.eventsToShow.value,
        [testEvent, testEvent2],
      );
    });

    test('loadEvents failure', () async {
      when(
        mockEventUseCase.getEvents(),
      ).thenAnswer((_) async => const Result.error(NetworkException('error')));
      await viewModel.loadEvents();
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'error');
    });

    test('onEventFilterChanged', () async {
      final now = DateTime.now();
      final pastEvent = testEvent.copyWith(
        uid: 'past',
        eventDates: EventDates(
          uid: "eventDates_UID_1",
          startDate: now.subtract(const Duration(days: 1)).toIso8601String(),
          endDate: now.subtract(const Duration(days: 1)).toIso8601String(),
          timezone: "Europe/Madrid",
        ),
      );
      final futureEvent = testEvent.copyWith(
        uid: 'future',
        eventDates: EventDates(
          uid: "eventDates_UID_2",
          startDate: now.add(const Duration(days: 1)).toIso8601String(),
          endDate: now.add(const Duration(days: 1)).toIso8601String(),
          timezone: "Europe/Madrid",
        ),
      );
      when(
        mockEventUseCase.getEvents(),
      ).thenAnswer((_) async => Result.ok([pastEvent, futureEvent]));
      await viewModel.loadEvents();
      viewModel.onEventFilterChanged(EventFilter.past);
      await Future.delayed(Duration.zero);
      expect(viewModel.eventsToShow.value, [pastEvent]);

      viewModel.onEventFilterChanged(EventFilter.current);
      await Future.delayed(Duration.zero);
      expect(viewModel.eventsToShow.value, [futureEvent]);

      viewModel.onEventFilterChanged(EventFilter.all);
      await Future.delayed(Duration.zero);
      expect(viewModel.eventsToShow.value.length, 2);
    });

    test('addEvent', () async {
      await viewModel.addEvent(testEvent);
      expect(viewModel.eventsToShow.value, [testEvent]);
    });

    test('editEvent success', () async {
      await viewModel.addEvent(testEvent);
      final editedEvent = testEvent.copyWith(eventName: 'edited');
      when(
        mockEventUseCase.saveEvent(editedEvent),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.editEvent(editedEvent);

      expect(viewModel.eventsToShow.value.first.eventName, 'edited');
    });

    test('editEvent failure', () async {
      final result = await viewModel.editEvent(testEvent);
      expect(result, isA<Error>());
    });

    test('deleteEvent success', () async {
      await viewModel.addEvent(testEvent);
      when(
        mockEventUseCase.removeEvent(testEvent),
      ).thenAnswer((_) async => const Result.ok(null));

      await viewModel.deleteEvent(testEvent);

      expect(viewModel.eventsToShow.value, isEmpty);
    });

    test('deleteEvent failure', () async {
      await viewModel.addEvent(testEvent);
      when(
        mockEventUseCase.removeEvent(testEvent),
      ).thenAnswer((_) async => const Result.error(NetworkException('error')));

      await viewModel.deleteEvent(testEvent);

      expect(viewModel.viewState.value, ViewState.error);
    });

    test('getEventById from cache', () async {
      viewModel.lastEventsFetchTime = DateTime.now();
      await viewModel.addEvent(testEvent);
      final result = await viewModel.getEventById(testEvent.uid);
      expect(result, testEvent);
      verifyNever(mockEventUseCase.getEventById(any));
    });

    test('getEventById from useCase', () async {
      when(
        mockEventUseCase.getEventById(testEvent.uid),
      ).thenAnswer((_) async => Result.ok(testEvent));
      final result = await viewModel.getEventById(testEvent.uid);
      expect(result, testEvent);
    });

    test('getEventById failure', () async {
      when(
        mockEventUseCase.getEventById(testEvent.uid),
      ).thenAnswer((_) async => const Result.error(NetworkException('error')));
      final result = await viewModel.getEventById(testEvent.uid);
      expect(result, isNull);
      expect(viewModel.viewState.value, ViewState.error);
    });

    test('updateConfig success', () async {
      final config = getIt<Config>();
      when(
        mockEventUseCase.updateConfig(config),
      ).thenAnswer((_) async => const Result.ok(null));
      await viewModel.updateConfig(config);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('updateConfig failure', () async {
      final config = getIt<Config>();
      when(
        mockEventUseCase.updateConfig(config),
      ).thenAnswer((_) async => const Result.error(NetworkException('error')));
      await viewModel.updateConfig(config);
      expect(viewModel.viewState.value, ViewState.error);
    });

    test('checkToken', () async {
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);
      final result = await viewModel.checkToken();
      expect(result, isTrue);
    });
  });
}
