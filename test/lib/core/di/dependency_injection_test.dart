
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection', () {
    setUp(() async {
      await resetDependencies();
    });

    test('should register all dependencies', () async {
      // Act
      await setupDependencies();

      // Assert
      expect(getIt.isRegistered<SecureInfo>(), isTrue);
      expect(getIt.isRegistered<DataLoaderManager>(), isTrue);
      expect(getIt.isRegistered<SecRepository>(), isTrue);
      expect(getIt.isRegistered<TokenRepository>(), isTrue);
      expect(getIt.isRegistered<CheckTokenSavedUseCase>(), isTrue);
      expect(getIt.isRegistered<EventUseCase>(), isTrue);
      expect(getIt.isRegistered<AgendaUseCase>(), isTrue);
      expect(getIt.isRegistered<SpeakerUseCase>(), isTrue);
      expect(getIt.isRegistered<SponsorUseCase>(), isTrue);
      expect(getIt.isRegistered<ConfigUseCase>(), isTrue);
      expect(getIt.isRegistered<EventCollectionViewModel>(), isTrue);
      expect(getIt.isRegistered<AgendaViewModel>(), isTrue);
      expect(getIt.isRegistered<ConfigViewModel>(), isTrue);
      expect(getIt.isRegistered<SpeakerViewModel>(), isTrue);
      expect(getIt.isRegistered<SponsorViewModel>(), isTrue);
      expect(getIt.isRegistered<OnLiveViewModel>(), isTrue);
      expect(getIt.isRegistered<EventDetailViewModel>(), isTrue);
      expect(getIt.isRegistered<EventFormViewModel>(), isTrue);
    });

    test('should reset all dependencies', () async {
      // Arrange
      await setupDependencies();

      // Verify that a dependency is registered before reset
      expect(getIt.isRegistered<DataLoaderManager>(), isTrue);

      // Act
      await resetDependencies();

      // Assert
      expect(getIt.isRegistered<DataLoaderManager>(), isFalse);
      expect(getIt.isRegistered<SecRepository>(), isFalse);
    });
  });
}
