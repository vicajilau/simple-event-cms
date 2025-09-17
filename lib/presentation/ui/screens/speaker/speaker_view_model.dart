import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
// Added imports for Speaker model and SpeakerUseCase
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SpeakersViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<Speaker>> speakers;
  void addSpeaker(Speaker speaker);
  void editSpeaker(Speaker speaker);
  void removeSpeaker(String id);
}

// Abstract SpeakerViewModel
abstract class SpeakerViewModel implements SpeakersViewModel {
  // New abstract method to fetch a speaker
  Future<Speaker?> fetchSpeakerById(String speakerUID);
  // Add any speaker-specific abstract methods or properties here if needed in the future
}

// Concrete SpeakerViewModelImpl
class SpeakerViewModelImpl extends SpeakerViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  // Added SpeakerUseCase field
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

  // Implementation for the new method
  @override
  Future<Speaker?> fetchSpeakerById(String speakerUID) async {
    viewState.value = ViewState.isLoading;
    errorMessage = '';
    try {
      final speaker = await _speakerUseCase.getSpeakerById(speakerUID);
      if (speaker == null) {
        errorMessage = 'Speaker not found'; // Or a localized message
        viewState.value = ViewState.error;
        return null;
      }
      viewState.value = ViewState.loadFinished;
      return speaker;
    } catch (e) {
      errorMessage =
          'Error fetching speaker: ${e.toString()}'; // Or a more user-friendly message
      viewState.value = ViewState.error;
      return null;
    }
  }

  @override
  void dispose() {
    // Add any specific disposal logic for SpeakerViewModel here
    viewState.dispose(); // It's good practice to dispose ValueNotifiers
  }

  @override
  void setup([Object? argument]) {
    // Add any specific setup logic for SpeakerViewModel here
    // If you need to load a speaker immediately when the ViewModel is set up,
    // you could call fetchSpeakerById here, perhaps if 'argument' is the speakerUID.
  }
}
