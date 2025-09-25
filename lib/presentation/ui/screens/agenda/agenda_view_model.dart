import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class AgendaViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<AgendaDay>> agendaDays;
  List<String> get days => [];
  List<String> get rooms => [];
  List<String> get speakers => [];
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void addSession(Agenda agenda);
  void editSession(Agenda agenda);
  void removeSession(String id);
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
  List<String> days = [];

  @override
  List<String> rooms = [];

  @override
  List<String> speakers = [];

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
      days = agenda?.days.map((day) => day.date).toList() ?? [];
      rooms =
          agenda?.days
              .map((day) => day.tracks.map((track) => track.name).toList())
              .expand((element) => element)
              .toList() ??
          [];
      final allSpeakers = agenda?.days
          .expand((day) => day.tracks)
          .expand((track) => track.sessions)
          .map((session) => session.speaker)
          .where((speaker) => speaker.isNotEmpty)
          .toSet()
          .toList();
      speakers = allSpeakers ?? [];
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
  void addSession(Agenda agenda) {
    // TODO: implement addSession
  }

  @override
  void editSession(Agenda agenda) {
    // TODO: implement editSession
  }

  @override
  void removeSession(String id) {
    // TODO: implement removeSession
  }
}
