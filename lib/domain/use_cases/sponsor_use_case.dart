import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class SponsorUseCase {
  Future<List<Sponsor>> getComposedSponsors();
  Future<Sponsor?> getSponsorById(String id);
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
  Future<Sponsor?> getSponsorById(String id) async {
    return await getComposedSponsors().then((sponsors) {
      sponsors.firstWhere((event) => event.uid == id);
      return null;
    });
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
