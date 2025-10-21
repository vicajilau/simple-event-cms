import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SponsorUseCase {
  Future<Result<List<Sponsor>>> getSponsorByIds(String eventId);
  void saveSponsor(Sponsor sponsor, String parentId);
  void removeSponsor(String sponsorId);
}

class SponsorUseCaseImp implements SponsorUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<List<Sponsor>>> getSponsorByIds(String eventId) async {
    final result = await repository.loadSponsors();

    switch (result) {
      case Ok<List<Sponsor>>():
        final filteredSponsors = result.value
            .where((sponsor) => eventId == sponsor.eventUID)
            .toList();
        return Result.ok(filteredSponsors);
      case Error<List<Sponsor>>():
        return Result.error(result.error);
    }
  }

  @override
  void saveSponsor(Sponsor sponsor, String parentId) {
    repository.saveSponsor(sponsor, parentId);
  }

  @override
  void removeSponsor(String sponsorId) {
    repository.removeSponsor(sponsorId);
  }
}
