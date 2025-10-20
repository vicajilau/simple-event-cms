import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class AgendaViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<AgendaDay>> agendaDays;
  Future<void> saveSpeaker(Speaker speaker, String eventId);
  void removeSession(String sessionId);
  Future<List<Speaker>> getSpeakersForEventId(String eventId);
}

class AgendaViewModelImp extends AgendaViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  ValueNotifier<List<AgendaDay>> agendaDays = ValueNotifier([]);

  final AgendaUseCase agendaUseCase = getIt<AgendaUseCase>();

  @override
  ErrorType errorType = ErrorType.none;

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      _loadAgendaDays(argument);
    }
  }

  void _loadAgendaDays(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getAgendaDayByEventIdFiltered(eventId);
    switch (result) {
      case Ok<List<AgendaDay>>():
        agendaDays.value = result.value.toList();
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  Future<void> saveSpeaker(Speaker speaker, String eventId) async {
    await agendaUseCase.saveSpeaker(speaker, eventId);
  }
  @override
  void removeSession(String sessionId) {
    agendaUseCase.deleteSessionFromAgendaDay(sessionId);
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getSpeakersForEventId(eventId);
    switch (result) {
      case Ok<List<Speaker>>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return [];
    }
  }
}
