import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/models/event.dart';
import '../../../../core/utils/result.dart';

abstract class EventFormViewModel extends ViewModelCommon {
  Future<bool> onSubmit(Event event);
  Future<void> removeTrack(String trackUID);
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
  Future<void> setup([Object? argument]) async {}

  @override
  Future<bool> onSubmit(Event event) async {
    viewState.value = ViewState.isLoading;
    final result = await eventFormUseCase.prepareAgendaDays(event);
    switch (result) {
      case Ok<void>():
        var resultEvent = await eventFormUseCase.saveEvent(event);
        switch (resultEvent) {
          case Ok<void>():
            viewState.value = ViewState.loadFinished;
            return true;
          case Error():
            setErrorKey(resultEvent.error);
            debugPrint(
              'error located into onSubmit()  in saveevent: ${resultEvent.error.message}',
            );
            viewState.value = ViewState.error;
            return false;
        }
      case Error():
        setErrorKey(result.error);
        debugPrint(
          'error located into onSubmit()  in prepareAgendaDays: ${result.error.message}',
        );
        viewState.value = ViewState.error;
        return false;
    }
  }

  @override
  Future<void> removeTrack(String trackUID) async {
    viewState.value = ViewState.isLoading;
    var result = await eventFormUseCase.removeTrack(trackUID);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }
}
