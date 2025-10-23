import 'package:sec/core/models/organization.dart';

import '../../core/di/dependency_injection.dart';
import '../repositories/sec_repository.dart';

abstract class OrganizationUseCase {
  Future<void> updateOrganization(Organization organization);
}
class OrganizationUseCaseImp implements OrganizationUseCase {

  SecRepository repository = getIt<SecRepository>();

  @override
  Future<void> updateOrganization(Organization organization) async {
    await repository.saveOrganization(organization);
  }

}