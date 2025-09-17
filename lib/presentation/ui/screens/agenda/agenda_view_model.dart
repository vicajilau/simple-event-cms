import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class AgendaViewModel implements ViewModelCommon {
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void editSession(Session session, String agendaId, String dayId);
  void deleteSession(String sessionId, String agendaId, String dayId);
}

class AgendaViewModelImp extends AgendaViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);
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
  void setup([Object? argument]) {}

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    agendaUseCase.saveAgendaDayById(agendaDay, agendaId);
  }

  @override
  void editSession(Session session, String agendaId, String dayId) {
    agendaUseCase.editSession(agendaId, dayId, session);
  }

  @override
  void deleteSession(String sessionId, String agendaId, String dayId) {
    agendaUseCase.deleteSession(agendaId, dayId, sessionId);
  }
}
