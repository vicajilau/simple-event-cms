import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SpeakerUseCase {
  Future<Result<List<Speaker>>> getSpeakersById(List<String> ids);
  void saveSpeaker(Speaker speaker, String parentId);
  void removeSpeaker(String speakerId);
}

class SpeakerUseCaseImp implements SpeakerUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Speaker>>> getSpeakersById(List<String> ids) async {
    final result = await repository.loadESpeakers();

    switch (result) {
      case Ok<List<Speaker>>():
        final filteredSpeakers = result.value
            .where((sponsor) => ids.contains(sponsor.uid))
            .toList();

        return Result.ok(filteredSpeakers);
      case Error<List<Speaker>>():
        return Result.error(result.error);
    }
  }

  @override
  void saveSpeaker(Speaker speaker, String parentId) {
    repository.saveSpeaker(speaker, parentId);
  }

  @override
  void removeSpeaker(String speakerId) {
    repository.removeSpeaker(speakerId);
  }
}
