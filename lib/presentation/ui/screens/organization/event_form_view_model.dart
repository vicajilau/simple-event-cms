import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/models/event.dart';

abstract class EventFormViewModel extends ViewModelCommon {
  Future<void> onSubmit(Event event);
  Future<void> removeTrack(String trackUID,String eventUID);
}

class EventFormViewModelImpl extends EventFormViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final eventFormUseCase = getIt<EventUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  ErrorType errorType = ErrorType.none;

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {}

  @override
  Future<void> onSubmit(Event event) async {
    await eventFormUseCase.prepareAgendaDays(event);
    await eventFormUseCase.saveEvent(event);
  }

  @override
  Future<void> removeTrack(String trackUID,String eventUID) async {
    await eventFormUseCase.removeTrack(trackUID,eventUID);
  }
}
