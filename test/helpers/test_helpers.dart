import 'package:get_it/get_it.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';

// We assume your mocks are generated in 'test/mocks.mocks.dart'.
// Adjust the path if your project structure is different.
import '../mocks.mocks.dart';

final getIt = GetIt.instance;

/// Registers all dependencies for testing purposes, using mock implementations.
void setupTestDependencies() {
  // Ensure a clean slate before each test
  getIt.reset();

  // Mocks for Repositories
  getIt.registerLazySingleton<SecRepository>(() => MockSecRepository());
  getIt.registerLazySingleton<TokenRepository>(() => MockTokenRepository());

  // Mocks for UseCases
  getIt.registerLazySingleton<CheckTokenSavedUseCase>(() => MockCheckTokenSavedUseCase());
  getIt.registerLazySingleton<EventUseCase>(() => MockEventUseCase());
  getIt.registerLazySingleton<AgendaUseCase>(() => MockAgendaUseCase());
  getIt.registerLazySingleton<SpeakerUseCase>(() => MockSpeakerUseCase());
  getIt.registerLazySingleton<SponsorUseCase>(() => MockSponsorUseCase());
  getIt.registerLazySingleton<ConfigUseCase>(() => MockConfigUseCase());

  // Mocks for ViewModels
  getIt.registerLazySingleton<EventCollectionViewModel>(() => MockEventCollectionViewModel());
  getIt.registerLazySingleton<AgendaViewModel>(() => MockAgendaViewModel());
  getIt.registerLazySingleton<ConfigViewModel>(() => MockConfigViewModel());
  getIt.registerLazySingleton<SpeakerViewModel>(() => MockSpeakerViewModel());
  getIt.registerLazySingleton<SponsorViewModel>(() => MockSponsorViewModel());
  getIt.registerLazySingleton<OnLiveViewModel>(() => MockOnLiveViewModel());
  getIt.registerLazySingleton<EventDetailViewModel>(() => MockEventDetailViewModel());
  getIt.registerLazySingleton<EventFormViewModel>(() => MockEventFormViewModel());
  getIt.registerLazySingleton<AgendaFormViewModel>(() => MockAgendaFormViewModel());

  // Real implementations for simple classes
  getIt.registerLazySingleton<CheckOrg>(() => CheckOrg());

  // Register a default mock config. You can override this in your tests if needed.
  getIt.registerSingleton<Config>(
    Config(
      configName: 'Test Config',
      projectName: 'test-project',
      githubUser: 'test-user',
      branch: 'main',
      primaryColorOrganization: '#FFFFFF',
      secondaryColorOrganization: '#000000',
    ),
  );
}
