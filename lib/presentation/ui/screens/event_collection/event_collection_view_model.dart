import 'package:flutter/foundation.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../../core/models/github/github_data.dart';
import '../../../../core/routing/app_router.dart';
import '../../../view_model_common.dart';

abstract class EventCollectionViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Event>> eventsToShow;
  abstract EventFilter currentFilter;
  void onEventFilterChanged(EventFilter value);
  Future<void> loadEvents();
  Future<void> addEvent(Event event);
  Future<Event?> getEventById(String eventId);
  Future<Result<void>> editEvent(Event event);
  Future<void> deleteEvent(Event event);
  Future<void> updateConfig(Config config);
}

class EventCollectionViewModelImp extends EventCollectionViewModel {
  EventUseCase useCase = getIt<EventUseCase>();
  CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final config = getIt<Config>();

  @override
  final ValueNotifier<List<Event>> eventsToShow = ValueNotifier<List<Event>>(
    [],
  );

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  EventFilter currentFilter = EventFilter.all;

  List<Event> _allEvents = [];
  DateTime? lastEventsFetchTime;

  @override
  Future<void> setup([Object? argument]) async {
    await SecureInfo.saveGithubKey(GithubData(projectName: config.projectName));
    await loadEvents();
  }

  @override
  Future<void> loadEvents() async {
    viewState.value = ViewState.isLoading;
    if (await _shouldSkipFetch()) {
      viewState.value = ViewState.loadFinished;
      await _handleSingleEventNavigation();
      return;
    }

    final eventsResult = await useCase.getEvents();
    switch (eventsResult) {
      case Ok<List<Event>>():
        lastEventsFetchTime = DateTime.now();
        _allEvents = eventsResult.value.toList(growable: true);
        _updateEventsToShow();
        viewState.value = ViewState.loadFinished;
        await _handleSingleEventNavigation();
      case Error():
        setErrorKey(eventsResult.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  void onEventFilterChanged(EventFilter value) {
    currentFilter = value;
    _applyFilters();
  }

  @override
  Future<void> addEvent(Event event) async {
    _allEvents.removeWhere((element) => element.uid == event.uid);
    _allEvents.add(event);
    _updateEventsToShow();
  }

  @override
  Future<Result<void>> editEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents[index] = event;
      _updateEventsToShow();

      viewState.value = ViewState.isLoading;
      final result = await useCase.saveEvent(event);
      viewState.value = ViewState.loadFinished;
      return result;
    }
    return Result.error(GithubException('Event not found'));
  }

  @override
  Future<void> deleteEvent(Event event) async {
    int index = _allEvents.indexWhere((element) => element.uid == event.uid);
    if (index != -1) {
      _allEvents.removeAt(index);
      _applyFilters();

      viewState.value = ViewState.isLoading;
      final result = await useCase.removeEvent(event);
      switch (result) {
        case Ok<void>():
          viewState.value = ViewState.loadFinished;
        case Error():
          viewState.value = ViewState.error;
          setErrorKey(result.error);
      }
    }
  }

  void _updateEventsToShow() async {
    _sortEvents();
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    viewState.value = ViewState.isLoading;
    final now = DateTime.now();
    List<Event> eventsFiltered = [..._allEvents];
    switch (currentFilter) {
      case EventFilter.all:
        // Show all events
        eventsFiltered = _allEvents;
        break;
      case EventFilter.past:
        eventsFiltered =
            eventsFiltered.where((event) {
              final startDate = DateTime.parse(event.eventDates.startDate);
              return startDate.isBefore(now);
            }).toList()..sort((a, b) {
              final aDate = DateTime.parse(a.eventDates.startDate);
              final bDate = DateTime.parse(b.eventDates.startDate);
              return aDate.compareTo(bDate);
            });
        break;
      case EventFilter.current:
        eventsFiltered =
            eventsFiltered.where((event) {
              final startDate = DateTime.parse(event.eventDates.startDate);
              return startDate.isAfter(now);
            }).toList()..sort((a, b) {
              final aDate = DateTime.parse(a.eventDates.startDate);
              final bDate = DateTime.parse(b.eventDates.startDate);
              return aDate.compareTo(bDate);
            });
        break;
    }
    eventsToShow.value = eventsFiltered;
    viewState.value = ViewState.loadFinished;
  }

  void _sortEvents() {
    _allEvents.sort((a, b) {
      final aDate = DateTime.parse(a.eventDates.startDate);
      final bDate = DateTime.parse(b.eventDates.startDate);
      return aDate.compareTo(bDate);
    });
  }

  @override
  void dispose() {
    eventsToShow.dispose();
    viewState.dispose();
  }

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    viewState.value = ViewState.isLoading;
    final event = _allEvents.where((event) => event.uid == eventId).firstOrNull;
    if (await _shouldSkipFetch() && event?.uid.isNotEmpty == true) {
      viewState.value = ViewState.loadFinished;
      return event;
    }

    final result = await useCase.getEventById(eventId);
    switch (result) {
      case Ok<Event?>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return null;
    }
  }

  Future<bool> _shouldSkipFetch() async {
    final gitHubService = await SecureInfo.getGithubKey();
    final isTokenNull = gitHubService.token == null;
    final isCacheValid =
        lastEventsFetchTime != null &&
        DateTime.now().difference(lastEventsFetchTime!) <
            const Duration(minutes: 5);

    return isCacheValid && _allEvents.isNotEmpty && isTokenNull;
  }

  Future<void> _handleSingleEventNavigation() async {
    final gitHubService = await SecureInfo.getGithubKey();
    final isTokenNull = gitHubService.token == null;

    var positionEventToView = eventsToShow.value.indexWhere(
      (event) => event.uid == config.eventForcedToViewUID,
    );
    if ((eventsToShow.value.length == 1 || positionEventToView != -1) &&
        isTokenNull &&
        eventsToShow.value.indexWhere((event) => event.isVisible == true) !=
            -1) {
      Event eventToGo;
      if (positionEventToView != -1) {
        eventToGo = eventsToShow.value[positionEventToView];
      } else {
        eventToGo = eventsToShow.value.firstWhere(
          (event) => event.isVisible == true,
        );
      }

      await AppRouter.router.pushNamed(
        AppRouter.eventDetailName,
        pathParameters: {
          'eventId': eventToGo.uid,
          'location': eventToGo.location ?? "",
          'onlyOneEvent': "true",
        },
      );
    }
  }

  @override
  Future<void> updateConfig(Config config) async {
    final result = await useCase.updateConfig(config);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return;
    }
  }
}
