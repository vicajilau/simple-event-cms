import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
// Added imports for Speaker model and SpeakerUseCase
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SpeakerViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Speaker>> speakers;
  void addSpeaker(Speaker speaker, String parentId);
  void editSpeaker(Speaker speaker, String parentId);
  void removeSpeaker(String id);
}

class SpeakerViewModelImpl extends SpeakerViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final SpeakerUseCase _speakerUseCase = getIt<SpeakerUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  ErrorType errorType = ErrorType.none;

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  void addSpeaker(Speaker speaker, String parentId) {
    speakers.value = [...speakers.value, speaker];
    _speakerUseCase.saveSpeaker(speaker, parentId);
  }

  @override
  void editSpeaker(Speaker speaker, String parentId) {
    final index = speakers.value.indexWhere((s) => s.uid == speaker.uid);
    List<Speaker> currentSpeakers = [...speakers.value];
    if (index != -1) {
      currentSpeakers[index] = speaker;
      speakers.value = currentSpeakers;
      _speakerUseCase.saveSpeaker(speaker, parentId);
    }
  }

  @override
  void removeSpeaker(String id) {
    List<Speaker> currentSpeakers = [...speakers.value];
    currentSpeakers.removeWhere((s) => s.uid == id);
    speakers.value = currentSpeakers;
    _speakerUseCase.removeSpeaker(id);
  }

  @override
  void dispose() {
    viewState.dispose();
    speakers.dispose();
  }

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      _loadSpeakers(argument);
    }
  }

  void _loadSpeakers(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await _speakerUseCase.getSpeakersById(eventId);
    switch (result) {
      case Ok<List<Speaker>>():
        speakers.value = result.value;
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }
}
