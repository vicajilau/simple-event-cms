import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SpeakerUseCase {
  Future<List<Speaker>> getComposedSpeakers();
  Future<Speaker?> getSpeakerById(String id);
  void saveSpeaker(Speaker speaker);
  void removeSpeaker(String speakerId);
}

class SpeakerUseCaseImp implements SpeakerUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<List<Speaker>> getComposedSpeakers() {
    return repository.loadESpeakers();
  }

  @override
  Future<Speaker?> getSpeakerById(String id) async {
    return await getComposedSpeakers().then((speakers) {
      speakers.firstWhere((event) => event.uid == id);
      return null;
    });
  }

  @override
  void saveSpeaker(Speaker speaker) {
    repository.saveSpeaker(speaker);
  }

  @override
  void removeSpeaker(String speakerId) {
    repository.removeSpeaker(speakerId);
  }
}
