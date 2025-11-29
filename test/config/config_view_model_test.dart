
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockConfigUseCase mockConfigUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  late ConfigViewModelImpl viewModel;

  setUp(() {
    mockConfigUseCase = MockConfigUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();
    getIt.registerSingleton<ConfigUseCase>(mockConfigUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);
    viewModel = ConfigViewModelImpl();
    provideDummy<Result<void>>(const Result.ok(null));

  });
  tearDown(() async { // ADDED
    await getIt.reset(); // ADDED
  }); // ADDED
  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'read') {
      return '{"token":"token_mocked","projectName":"simple-event-cms"}';
    }
    return null;
  });

  group('ConfigViewModel', () {
    final config = Config(
      configName: 'test',
      primaryColorOrganization: 'test',
      secondaryColorOrganization: 'test',
      githubUser: 'test',
      projectName: 'test',
      branch: 'test',
    );

    test('updateConfig success', () async {
      when(mockConfigUseCase.updateConfig(config)).thenAnswer((_) async => const Result.ok(null));

      final result = await viewModel.updateConfig(config);

      expect(result, isTrue);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('updateConfig error', () async {
      when(mockConfigUseCase.updateConfig(config)).thenAnswer((_) async => const Result.error(NetworkException('error')));

      final result = await viewModel.updateConfig(config);

      expect(result, isFalse);
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'error');
    });

    test('checkToken returns true', () async {
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => true);

      final result = await viewModel.checkToken();

      expect(result, isTrue);
    });

    test('checkToken returns false', () async {
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => false);

      final result = await viewModel.checkToken();

      expect(result, isFalse);
    });
  });
}
