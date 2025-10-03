import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../../core/utils/result.dart';


abstract class AgendaFormViewModel extends ViewModelCommon {
  Future<Event?> loadEvent(String eventId);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void addAgenda(Agenda agenda,String eventId);
  Future<Agenda?> getAgenda(String agendaId);
  Future<Track?> getTrackById(String trackId);
  Future<AgendaDay?> getAgendaDayById(String agendaDayId);
  Future<List<AgendaDay>?> getAgendaDayByListId(List<String> agendaDayIds);
  Future<List<Track>?> getTracksByListId(List<String> trackIds);
  Future<List<Session>?> getSessionsByListId(List<String> sessionIds);
  void addSession(String agendaId,String agendaDayId,String trackId,Session session);
}


class AgendaFormViewModelImpl extends AgendaFormViewModel {

  final CheckTokenSavedUseCase checkTokenSavedUseCase =
  getIt<CheckTokenSavedUseCase>();
  final AgendaUseCase agendaUseCase = getIt<AgendaUseCase>();


  @override
  ErrorType errorType = ErrorType.none;


  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);


  @override
  void setup([Object? argument]) {
    if (argument is String) {
    }
  }

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    agendaUseCase.saveAgendaDayById(agendaDay, agendaId);
  }

  @override
  void addAgenda(Agenda agenda,String eventId) {
    agendaUseCase.saveAgenda(agenda, eventId);
  }
  @override
  void addSession(String agendaId,String agendaDayId,String trackId,Session session) {
    agendaUseCase.addSessionIntoAgenda(agendaId,agendaDayId,trackId,session);
  }

  @override
  Future<Track?> getTrackById(String trackId) async {
    final result = await agendaUseCase.getTrackById(trackId);
    switch (result) {
      case Ok<Track>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<AgendaDay?> getAgendaDayById(String agendaDayId) async {
    final result = await agendaUseCase.getAgendaDayById(agendaDayId);
    switch (result) {
      case Ok<AgendaDay>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }


  @override
  void dispose() {
  }

  @override
  Future<Event?> loadEvent(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.loadEvent(eventId);

    switch (result) {
      case Ok<Event>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return null;
    }
  }

  @override
  Future<List<AgendaDay>?> getAgendaDayByListId(List<String> agendaDayIds) async {
    final result = await agendaUseCase.getAgendaDayByListId(agendaDayIds);
    switch (result) {
      case Ok<List<AgendaDay>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<List<Session>?> getSessionsByListId(List<String> sessionIds) async {
    final result = await agendaUseCase.getSessionsByListId(sessionIds);
    switch (result) {
      case Ok<List<Session>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<List<Track>?> getTracksByListId(List<String> trackIds) async {
    final result = await agendaUseCase.getTracksByListId(trackIds);
    switch (result) {
      case Ok<List<Track>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<Agenda?> getAgenda(String agendaId) async {
    final result =  await agendaUseCase.getAgendaById(agendaId);
    switch (result) {
      case Ok<Agenda>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }



}
