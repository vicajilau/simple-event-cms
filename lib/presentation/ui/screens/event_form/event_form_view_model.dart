import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/models/event.dart';
import '../../../../core/utils/result.dart';

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
  Future<void> onSubmit(Event event) async {
    viewState.value = ViewState.isLoading;
    final result = await eventFormUseCase.prepareAgendaDays(event);
    switch (result) {
      case Ok<void>():
        await eventFormUseCase.saveEvent(event);
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  Future<void> removeTrack(String trackUID,String eventUID) async {
    var result = await eventFormUseCase.removeTrack(trackUID,eventUID);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }
}
