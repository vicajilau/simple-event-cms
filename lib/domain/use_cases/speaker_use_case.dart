import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SpeakerUseCase {
  Future<List<Speaker>> getComposedSpeakers();
  Future<Speaker?> getSpeakerById(String id);
  void saveSpeaker(Speaker speaker);
}

class SpeakerUseCaseImp implements SpeakerUseCase {
  @override
  Future<List<Speaker>> getComposedSpeakers() {
    SecRepository repository = getIt<SecRepository>();
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
    // TODO: implement saveEvent
  }
}
