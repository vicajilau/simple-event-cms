import 'package:flutter/foundation.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class EventDetailViewModel extends ViewModelCommon {
  String eventTitle();
  Future<void> loadEventData(String eventId);
}

class EventDetailViewModelImp extends EventDetailViewModel {
  final EventUseCase useCase = getIt<EventUseCase>();
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  Event? event;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  ErrorType errorType = ErrorType.none;


  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      loadEventData(argument);
    }
  }

  @override
  String eventTitle() {
    return event?.eventName ?? '';
  }

  @override
  Future<void> loadEventData(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await useCase.getEvents();

    switch (result) {
      case Ok<List<Event>>():
        if(result.value.isEmpty){
          setErrorKey(NetworkException("there aren,t any events to show"));
          viewState.value = ViewState.error;
        }else{
          event = result.value.firstWhere(
                (e) => e.uid == eventId,
            orElse: () => result.value.first, // Fallback al primer evento
          );

          viewState.value = ViewState.loadFinished;
        }
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  Future<bool> checkToken() async {
    final bool tokenSaved = await checkTokenSavedUseCase.checkToken();
    return tokenSaved;
  }
}
