import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class AgendaViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<AgendaDay>> agendaDays;
  abstract final ValueNotifier<List<Speaker>> speakers;
  Future<Result<void>> saveSpeaker(Speaker speaker, String eventId);
  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId);
  Future<Result<void>> loadAgendaDays(String eventId);
  Future<Result<void>> removeSessionAndReloadAgenda(
    String sessionId,
    String eventId, {
    String? agendaDayUID,
  });
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
  String errorMessage = '';

  @override
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  void dispose() {}

  @override
  Future<void> setup([Object? argument]) async {
    if (argument is String) {
      loadAgendaDays(argument);
    }
  }

  @override
  Future<Result<void>> loadAgendaDays(String eventId) async {
    viewState.value = ViewState.isLoading;

    final result = await agendaUseCase.getAgendaDayByEventIdFiltered(eventId);
    switch (result) {
      case Ok<List<AgendaDay>>():
        agendaDays.value = result.value
            .where(
              (agendaDay) =>
                  agendaDay.eventsUID.contains(eventId) &&
                  agendaDay.resolvedTracks != null &&
                  agendaDay.resolvedTracks!.isNotEmpty &&
                  agendaDay.resolvedTracks!
                      .expand((track) => track.resolvedSessions)
                      .isNotEmpty &&
                  agendaDay.resolvedTracks!
                      .expand((track) => track.resolvedSessions)
                      .toList()
                      .where(
                        (session) =>
                            session.agendaDayUID == agendaDay.uid &&
                            session.eventUID == eventId,
                      )
                      .toList()
                      .isNotEmpty,
            )
            .toList(growable: true);
        final resultSpeakers = await agendaUseCase.getSpeakersForEventId(
          eventId,
        );
        switch (resultSpeakers) {
          case Ok<List<Speaker>>():
            viewState.value = ViewState.loadFinished;
            speakers.value = resultSpeakers.value;
          case Error():
            viewState.value = ViewState.error;
            setErrorKey(resultSpeakers.error);
        }
        return result;
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return result;
    }
  }

  @override
  Future<Result<void>> saveSpeaker(Speaker speaker, String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.saveSpeaker(speaker, eventId);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return result;
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return result;
    }
  }

  @override
  Future<Result<List<Speaker>>> getSpeakersForEventId(String eventId) async {
    return await agendaUseCase.getSpeakersForEventId(eventId);
  }

  @override
  Future<Result<void>> removeSessionAndReloadAgenda(
    String sessionId,
    String eventId, {
    String? agendaDayUID,
  }) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.deleteSession(
      sessionId,
      agendaDayUID: agendaDayUID,
    );
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return await loadAgendaDays(eventId);
      case Error():
        viewState.value = ViewState.error;
        setErrorKey(result.error);
        return result;
    }
  }
}
