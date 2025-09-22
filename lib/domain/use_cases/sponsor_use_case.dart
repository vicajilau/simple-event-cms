import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SponsorUseCase {
  Future<List<Sponsor>> getComposedSponsors();
  Future<List<Sponsor>> getSponsorByIds(List<String> ids);
  void saveSponsor(Sponsor sponsor);
  void removeSponsor(String sponsorId);
}

class SponsorUseCaseImp implements SponsorUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<List<Sponsor>> getComposedSponsors() {
    return repository.loadSponsors();
  }

  @override
  Future<List<Sponsor>> getSponsorByIds(List<String> ids) async {
    final allSponsors = await getComposedSponsors();
    final filteredSponsors = allSponsors
        .where((sponsor) => ids.contains(sponsor.uid))
        .toList();

    return filteredSponsors;
  }

  @override
  void saveSponsor(Sponsor sponsor) {
    repository.saveSponsor(sponsor);
  }

  @override
  void removeSponsor(String sponsorId) {
    repository.removeSponsor(sponsorId);
  }
}
