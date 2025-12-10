import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

// Generate mocks for the use case
@GenerateMocks([CheckTokenSavedUseCase])
void main() {
  // Antes de que los tests se ejecuten, inicializa Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  late OnLiveViewModelImpl viewModel;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;

  setUp(() {
    // Crea una instancia del mock
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    // Resetea GetIt para asegurar un estado limpio
    getIt.reset();

    // Registra el mock en el contenedor de dependencias
    getIt.registerLazySingleton<CheckTokenSavedUseCase>(() => mockCheckTokenSavedUseCase);

    // Crea la instancia del ViewModel que vamos a probar
    viewModel = OnLiveViewModelImpl();
  });

  tearDown(() {
    // Limpia las dependencias después de cada test
    getIt.reset();
  });

  group('OnLiveViewModel', () {
    test('initial state is isLoading', () {
      // Assert
      expect(viewModel.viewState.value, ViewState.isLoading);
    });

    test('setup() should change state to loadFinished', () async {
      // Act
      await viewModel.setup();

      // Assert
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('checkToken should return true when use case returns true', () async {
      // Arrange
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => true);

      // Act
      final result = await viewModel.checkToken();

      // Assert
      expect(result, isTrue);
      // Verifica que el método del use case fue llamado
      verify(mockCheckTokenSavedUseCase.checkToken());
    });

    test('checkToken should return false when use case returns false', () async {
      // Arrange
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => false);

      // Act
      final result = await viewModel.checkToken();

      // Assert
      expect(result, isFalse);
      // Verifica que el método del use case fue llamado
      verify(mockCheckTokenSavedUseCase.checkToken());
    });
  });
}
