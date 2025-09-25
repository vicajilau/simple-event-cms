import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class AgendaViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<AgendaDay>> agendaDays;
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  //TODO NEED TO REVIEW
  void addTrack(Agenda agenda);
  void addSession(String agendaId,String agendaDayId,String trackId,Session session);
  void editSession(String agendaId,String agendaDayId,String trackId,Session session);
  void removeSession(String agendaId,String agendaDayId,String trackId,Session session);
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
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      _loadAgenda(argument);
    }
  }

  void _loadAgenda(String agendaId) async {
    try {
      viewState.value = ViewState.isLoading;
      final agenda = await agendaUseCase.getAgendaById(agendaId);
      agendaDays.value = agenda?.days ?? [];
      viewState.value = ViewState.loadFinished;
    } catch (e) {
      errorMessage = e.toString();
      viewState.value = ViewState.error;
      // TODO: implement error control
    }
  }

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    agendaUseCase.saveAgendaDayById(agendaDay, agendaId);
  }
  @override
  void addTrack(Agenda agenda) {
    // TODO: implement addSession
  }
  @override
  void addSession(String agendaId,String agendaDayId,String trackId,Session session) {
    agendaUseCase.addSessionToAgendaDay(agendaId,agendaDayId,trackId,session);
  }

  @override
  void editSession(String agendaId,String agendaDayId,String trackId,Session session) {
    agendaUseCase.editSessionInAgendaDay(agendaId,agendaDayId,trackId,session);
  }

  @override
  void removeSession(String agendaId,String agendaDayId,String trackId,Session session) {
    agendaUseCase.deleteSessionFromAgendaDay(agendaId,agendaDayId,trackId,session);
  }
}

