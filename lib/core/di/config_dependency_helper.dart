import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';

void setOrganization(Config org) {
  if (getIt.isRegistered<Config>()) {
    getIt.unregister<Config>();
  }
  getIt.registerSingleton<Config>(org);
}
