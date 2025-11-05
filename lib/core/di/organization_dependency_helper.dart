import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/organization.dart';

void setOrganization(Organization org) {
  if (getIt.isRegistered<Organization>()) {
    getIt.unregister<Organization>();
  }
  getIt.registerSingleton<Organization>(org);
}
