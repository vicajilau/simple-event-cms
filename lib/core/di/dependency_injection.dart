import 'package:get_it/get_it.dart';
import 'package:sec/core/config/config_loader.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/repositories/sec_repository_imp.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';

import '../../presentation/view_models/event_collection_view_model.dart';

final GetIt getIt = GetIt.instance;

/// Configura todas las dependencias de la aplicación
Future<void> setupDependencies() async {
  // Cargar configuración inicial
  final config = await ConfigLoader.loadConfig();
  final organization = await ConfigLoader.loadOrganization();

  // Registrar configuración global
  getIt.registerSingleton<List<Event>>(config);
  getIt.registerSingleton<Organization>(organization);

  // Core services
  getIt.registerLazySingleton<DataLoader>(
    () => DataLoader(getIt<List<Event>>(), getIt<Organization>()),
  );

  // Repositories
  getIt.registerLazySingleton<SecRepository>(
    () => SecRepositoryImp(dataLoader: getIt<DataLoader>()),
  );

  // Use Cases
  getIt.registerLazySingleton<EventUseCase>(
    () => EventUseCaseImp(repository: getIt<SecRepository>()),
  );

  // Event ViewModel
  getIt.registerFactory<EventCollectionViewModel>(
    () => EventCollectionViewModelImp(useCase: getIt<EventUseCase>()),
  );
}

/// Limpia todas las dependencias registradas
Future<void> resetDependencies() async {
  await getIt.reset();
}
