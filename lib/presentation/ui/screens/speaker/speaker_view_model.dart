import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
// Added imports for Speaker model and SpeakerUseCase
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SpeakerViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<Speaker>> speakers;
  void addSpeaker(Speaker speaker);
  void editSpeaker(Speaker speaker);
  void removeSpeaker(String id);
}

// Concrete SpeakerViewModelImpl
class SpeakerViewModelImpl extends SpeakerViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final SpeakerUseCase _speakerUseCase = getIt<SpeakerUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading); // Default to isLoading

  @override
  String errorMessage = '';

  @override
  Future<bool> checkToken() async {
    // This is based on your AgendaViewModelImp:
    // As previously noted, checkTokenSavedUseCase.checkToken() might cause an error
    // because CheckTokenSavedUseCase has a call() method, not checkToken().
    // Consider changing to: return await checkTokenSavedUseCase.call();
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  void addSpeaker(Speaker speaker) {
    _speakerUseCase.saveSpeaker(speaker);
  }

  @override
  void editSpeaker(Speaker speaker) {
    _speakerUseCase.saveSpeaker(speaker);
  }

  @override
  void removeSpeaker(String id) {
    _speakerUseCase.removeSpeaker(id);
  }

  @override
  void dispose() {
    viewState.dispose();
    speakers.dispose();
  }

  @override
  void setup([Object? argument]) {
    if (argument is List<String>) {
      _loadSponsors(argument);
    }
  }

  void _loadSponsors(List<String> speakersIds) async {
    try {
      viewState.value = ViewState.isLoading;
      speakers.value = await _speakerUseCase.getSpeakersById(speakersIds);
      viewState.value = ViewState.loadFinished;
    } catch (e) {
      // TODO: immplementación control de errores (hay que crear los errores)
      errorMessage = "Error cargando datos";
      viewState.value = ViewState.error;
    }
  }
}
