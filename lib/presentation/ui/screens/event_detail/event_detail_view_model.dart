import 'package:flutter/foundation.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class EventDetailViewModel extends ViewModelCommon {
  ValueNotifier<bool> notShowReturnArrow = ValueNotifier(false);
  ValueNotifier<String> eventTitle = ValueNotifier('');
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
  String errorMessage = '';

  @override
  void dispose() {}

  @override
  Future<void> setup([Object? argument]) async {
    if (argument is String) {
      loadEventData(argument);
    }
  }

  @override
  Future<void> loadEventData(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await useCase.getEvents();
    var githubService = await SecureInfo.getGithubKey();
    var config = getIt<Config>();

    switch (result) {
      case Ok<List<Event>>():
        notShowReturnArrow.value =
            (result.value.length == 1 ||
                result.value.indexWhere(
                      (eventItem) =>
                          eventItem.uid == config.eventForcedToViewUID,
                    ) !=
                    -1) &&
            githubService.token == null;
        if (result.value.isEmpty) {
          setErrorKey(NetworkException("there aren,t any events to show"));
          viewState.value = ViewState.error;
        } else {
          event = result.value.firstWhere(
            (e) => e.uid == eventId,
            orElse: () => result.value.first, // Fallback at the first event
          );
          eventTitle.value = event!.eventName;
          viewState.value = ViewState.loadFinished;
        }
      case Error():
        notShowReturnArrow.value = false;
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
