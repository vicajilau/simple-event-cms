import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SpeakerUseCase {
  Future<List<Speaker>> getSpeakersById(List<String> ids);
  void saveSpeaker(Speaker speaker);
  void removeSpeaker(String speakerId);
}

class SpeakerUseCaseImp implements SpeakerUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<List<Speaker>> getSpeakersById(List<String> ids) async {
    final speakers = await repository.loadESpeakers();

    final filteredSpeakers = speakers
        .where((sponsor) => ids.contains(sponsor.uid))
        .toList();

    return filteredSpeakers;
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
