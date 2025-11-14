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
  Future<void> addSpeaker(Speaker speaker, String parentId);
  Future<void> editSpeaker(Speaker speaker, String parentId);
  Future<void> removeSpeaker(String id, String eventUID);
}

class SpeakerViewModelImpl extends SpeakerViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final SpeakerUseCase _speakerUseCase = getIt<SpeakerUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  Future<void> addSpeaker(Speaker speaker, String parentId) async {
    speakers.value = [...speakers.value, speaker];
    _speakerUseCase.saveSpeaker(speaker, parentId);
  }

  @override
  Future<void> editSpeaker(Speaker speaker, String parentId) async {
    final index = speakers.value.indexWhere((s) => s.uid == speaker.uid);
    List<Speaker> currentSpeakers = [...speakers.value];
    if (index != -1) {
      currentSpeakers[index] = speaker;
      speakers.value = currentSpeakers;
      _speakerUseCase.saveSpeaker(speaker, parentId);
    }
  }

  @override
  Future<void> removeSpeaker(String id, String eventUID) async {
    final result = await _speakerUseCase.removeSpeaker(id, eventUID);
    switch (result) {
      case Ok<void>():
        List<Speaker> currentSpeakers = [...speakers.value];
        currentSpeakers.removeWhere((s) => s.uid == id);
        speakers.value = currentSpeakers;
        viewState.value = ViewState.loadFinished;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  void dispose() {
    viewState.dispose();
    speakers.dispose();
  }

  @override
  Future<void> setup([Object? argument]) async {
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
