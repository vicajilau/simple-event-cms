import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';


abstract class AgendaFormViewModel implements ViewModelCommon {
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void addAgenda(Agenda agenda,String eventId);
  Future<Track?> getTrackById(String trackId);
  Future<AgendaDay?> getAgendaDayById(String agendaDayId);
  void addSession(String agendaId,String agendaDayId,String trackId,Session session);
}


class AgendaFormViewModelImpl extends AgendaFormViewModel {

  final CheckTokenSavedUseCase checkTokenSavedUseCase =
  getIt<CheckTokenSavedUseCase>();
  final AgendaUseCase agendaUseCase = getIt<AgendaUseCase>();


  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

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
  Future<Track> getTrackById(String trackId) async {
    return await agendaUseCase.getTrackById(trackId);
  }

  @override
  Future<AgendaDay> getAgendaDayById(String agendaDayId) async {
    return await agendaUseCase.getAgendaDayById(agendaDayId);
  }


  @override
  void dispose() {
  }
}
