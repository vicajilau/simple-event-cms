import 'package:sec/core/models/organization.dart';
import 'package:sec/core/utils/result.dart';

import '../../core/di/dependency_injection.dart';
import '../repositories/sec_repository.dart';

abstract class OrganizationUseCase {
  Future<Result<void>> updateOrganization(Organization organization);
}
class OrganizationUseCaseImp implements OrganizationUseCase {

  SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<void>> updateOrganization(Organization organization) async {
    return await repository.saveOrganization(organization);
  }

}