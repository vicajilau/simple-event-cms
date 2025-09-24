import 'package:flutter/foundation.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class EventDetailViewModel implements ViewModelCommon {
  String eventTitle();
  String get agendaId => '';
  List<String> get sponsorsId => [];
  List<String> get speakersId => [];
}

class EventDetailViewModelImp extends EventDetailViewModel {
  final EventUseCase useCase = getIt<EventUseCase>();
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  Event? event;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

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
      _loadEventData(argument);
    }
  }

  @override
  String eventTitle() {
    return event?.eventName ?? '';
  }

  Future<void> _loadEventData(String eventId) async {
    try {
      viewState.value = ViewState.isLoading;
      final events = await useCase.getComposedEvents();

      event = events.firstWhere(
        (e) => e.uid == eventId,
        orElse: () => events.first, // Fallback al primer evento
      );

      _agendaId = event?.agendaUID ?? '';
      _speakersId = event?.speakersUID ?? [];
      _sponsorsId = event?.sponsorsUID ?? [];

      viewState.value = ViewState.loadFinished;
    } catch (e) {
      // TODO: immplementación control de errores (hay que crear los errores)
      errorMessage = "Error cargando datos";
      viewState.value = ViewState.error;
    }
  }

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }
}
