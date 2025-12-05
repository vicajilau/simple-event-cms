import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/event_dates.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  late MockEventUseCase mockEventUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  late EventDetailViewModelImp viewModel;

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

    viewModel = EventDetailViewModelImp();
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

  group("EventDetailViewModelTest", () {
    test("loadEventData empty", () async {
      when(mockEventUseCase.getEvents()).thenAnswer((_) async => Result.ok([]));

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);

      await viewModel.loadEventData("event_UID_TEST");
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, "there aren,t any events to show");
    });

    test("loadEventData success", () async {
      when(
        mockEventUseCase.getEvents(),
      ).thenAnswer((_) async => Result.ok([testEvent, testEvent2]));

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);

      await viewModel.loadEventData("event_UID_TEST");
      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(viewModel.event, testEvent);
    });

    test("loadEventData failure", () async {
      when(mockEventUseCase.getEvents()).thenAnswer(
        (_) async => Result.error(GithubException("Event not found")),
      );

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);

      await viewModel.loadEventData("event_UID_TEST");
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, "Event not found");
    });
  });
}
