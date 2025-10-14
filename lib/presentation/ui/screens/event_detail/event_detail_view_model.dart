import 'package:flutter/foundation.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class EventDetailViewModel extends ViewModelCommon {
  String eventTitle();
  String get agendaId => '';
  List<String> get sponsorsId => [];
  List<String> get speakersId => [];
  Future<void> loadEventData(String eventId);
}

class EventDetailViewModelImp extends EventDetailViewModel {
  final EventUseCase useCase = getIt<EventUseCase>();
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  Event? event;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  ErrorType errorType = ErrorType.none;

  String _agendaId = "";
  List<String> _sponsorsId = [], _speakersId = [];

  @override
  List<String> get sponsorsId => _sponsorsId;

  @override
  List<String> get speakersId => _speakersId;

  @override
  String get agendaId => _agendaId;

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      loadEventData(argument);
    }
  }

  @override
  String eventTitle() {
    return event?.eventName ?? '';
  }

  Future<void> loadEventData(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await useCase.getEvents();

    switch (result) {
      case Ok<List<Event>>():
        event = result.value.firstWhere(
          (e) => e.uid == eventId,
          orElse: () => result.value.first, // Fallback al primer evento
        );

        _agendaId = event?.agendaUID ?? '';
        _speakersId = event?.speakersUID ?? [];
        _sponsorsId = event?.sponsorsUID ?? [];

        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  Future<bool> checkToken() async {
    final bool tokenSaved = await checkTokenSavedUseCase.checkToken();
    return tokenSaved;
  }
}
