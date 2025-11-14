import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SpeakerUseCase {
  Future<Result<List<Speaker>>> getSpeakersById(String eventId);
  Future<Result<void>> saveSpeaker(Speaker speaker, String parentId);
  Future<Result<void>> removeSpeaker(String speakerId, String eventUID);
}

class SpeakerUseCaseImp implements SpeakerUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Speaker>>> getSpeakersById(String eventId) async {
    final result = await repository.loadESpeakers();

    switch (result) {
      case Ok<List<Speaker>>():
        final filteredSpeakers = result.value
            .where((speaker) => speaker.eventUIDS.contains(eventId))
            .toList();

        return Result.ok(filteredSpeakers);
      case Error<List<Speaker>>():
        return Result.error(result.error);
    }
  }

  @override
  Future<Result<void>> saveSpeaker(Speaker speaker, String parentId) async {
    final result = await repository.saveSpeaker(speaker, parentId);
    switch (result) {
      case Ok<void>():
        return result;
      case Error<void>():
        return Result.error(result.error);
    }
  }

  @override
  Future<Result<void>> removeSpeaker(String speakerId, String eventUID) async {
    final result = await repository.removeSpeaker(speakerId, eventUID);
    switch (result) {
      case Ok<void>():
        return result;
      case Error<void>():
        return Result.error(result.error);
    }
  }
}
