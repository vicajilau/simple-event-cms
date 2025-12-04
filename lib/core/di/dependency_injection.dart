import 'package:get_it/get_it.dart';
import 'package:sec/core/config/config_loader.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/repositories/sec_repository_imp.dart';
import 'package:sec/data/repositories/token_repository_impl.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
// Imports for new ViewModels
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';

import '../../presentation/ui/screens/agenda/agenda_view_model.dart';
import '../../presentation/ui/screens/config/config_viewmodel.dart';

final GetIt getIt = GetIt.instance;

/// Configures all application dependencies
Future<void> setupDependencies() async {
  // Register helper
  getIt.registerSingleton<CheckOrg>(CheckOrg());

  // only charges (ConfigLoader will do setOrganization)
  await ConfigLoader.loadOrganization();

  // Core services
  getIt.registerLazySingleton<DataLoaderManager>(() => DataLoaderManager());

  // Repositories
  getIt.registerLazySingleton<SecRepository>(() => SecRepositoryImp());
  getIt.registerLazySingleton<TokenRepository>(() => TokenRepositoryImpl());
  getIt.registerLazySingleton<CheckTokenSavedUseCase>(
    () => CheckTokenSavedUseCaseImpl(),
  );

  // Use Cases
  getIt.registerLazySingleton<EventUseCase>(() => EventUseCaseImp());
  getIt.registerLazySingleton<AgendaUseCase>(() => AgendaUseCaseImpl());
  getIt.registerLazySingleton<SpeakerUseCase>(() => SpeakerUseCaseImp());
  getIt.registerLazySingleton<SponsorUseCase>(() => SponsorUseCaseImp());
  getIt.registerLazySingleton<ConfigUseCase>(() => ConfigUseCaseImp());

  // Event ViewModel
  getIt.registerLazySingleton<EventCollectionViewModel>(
    () => EventCollectionViewModelImp(),
  );
  getIt.registerLazySingleton<AgendaViewModel>(() => AgendaViewModelImp());
  getIt.registerLazySingleton<ConfigViewModel>(() => ConfigViewModelImpl());
  getIt.registerLazySingleton<SpeakerViewModel>(() => SpeakerViewModelImpl());
  getIt.registerLazySingleton<SponsorViewModel>(() => SponsorViewModelImpl());
  getIt.registerLazySingleton<OnLiveViewModel>(() => OnLiveViewModelImpl());
  getIt.registerLazySingleton<EventDetailViewModel>(
    () => EventDetailViewModelImp(),
  );
  getIt.registerLazySingleton<EventFormViewModel>(
    () => EventFormViewModelImpl(),
  );
  getIt.registerLazySingleton<AgendaFormViewModel>(
    () => AgendaFormViewModelImpl(),
  );
}

/// Clears all registered dependencies
Future<void> resetDependencies() async {
  await getIt.reset();
}
