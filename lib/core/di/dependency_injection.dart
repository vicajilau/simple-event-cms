import 'package:get_it/get_it.dart';
import 'package:sec/core/config/config_loader.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/repositories/sec_repository_imp.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';

final GetIt getIt = GetIt.instance;

/// Configura todas las dependencias de la aplicación
Future<void> setupDependencies() async {

  // Registrar configuración global
  getIt.registerSingleton<Organization>(await ConfigLoader.loadOrganization());

  // Core services
  getIt.registerLazySingleton<DataLoader>(
    () => DataLoader(),
  );

  // Repositories
  getIt.registerLazySingleton<SecRepository>(
    () => SecRepositoryImp(),
  );

  // Use Cases
  getIt.registerLazySingleton<EventUseCase>(
    () => EventUseCaseImp(),
  );

  // Event ViewModel
  getIt.registerLazySingleton<EventCollectionViewModel>(
    () => EventCollectionViewModelImp(),
  );
  // Event Detail ViewModel
  getIt.registerLazySingleton<EventDetailViewModel>(
    () => EventDetailViewModelImp(),
  );
}

/// Limpia todas las dependencias registradas
Future<void> resetDependencies() async {
  await getIt.reset();
}
