import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  late SponsorViewModelImpl viewModel;
  late MockSponsorUseCase mockSponsorUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
setUpAll(() {
  provideDummy<Result<void>>(Result.ok(null));
  provideDummy<Result<List<Sponsor>>>(Result.ok([]));
});
  setUp(() {
    getIt.reset();
    mockSponsorUseCase = MockSponsorUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    getIt.registerSingleton<SponsorUseCase>(mockSponsorUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);

    viewModel = SponsorViewModelImpl();
  });

  group('SponsorViewModelImpl', () {
    final sponsor = Sponsor(uid: '1', name: 'Test Sponsor', type: 'gold', logo: '', website: '', eventUID: 'event1');
    const eventId = 'event1';

    test('setup loads sponsors successfully', () async {
      when(mockSponsorUseCase.getSponsorByIds(eventId)).thenAnswer((_) async => Result.ok([sponsor]));

      await viewModel.setup(eventId);

      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(viewModel.sponsors.value, [sponsor]);
    });

    test('setup handles error when loading sponsors', () async {
      when(mockSponsorUseCase.getSponsorByIds(eventId)).thenAnswer((_) async => Result.error(NetworkException('Failed to load')));

      await viewModel.setup(eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Failed to load');
    });

    test('addSponsor successfully adds a sponsor', () async {
      when(mockSponsorUseCase.saveSponsor(sponsor, eventId)).thenAnswer((_) async => Result.ok(null));

      await viewModel.addSponsor(sponsor, eventId);

      expect(viewModel.sponsors.value.contains(sponsor), isTrue);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('addSponsor handles error', () async {
      when(mockSponsorUseCase.saveSponsor(sponsor, eventId)).thenAnswer((_) async => Result.error(NetworkException(('Save failed'))));

      await viewModel.addSponsor(sponsor, eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Save failed');
    });

    test('removeSponsor successfully removes a sponsor', () async {
      viewModel.sponsors.value = [sponsor];
      when(mockSponsorUseCase.removeSponsor(sponsor.uid)).thenAnswer((_) async => Result.ok(null));

      await viewModel.removeSponsor(sponsor.uid);

      expect(viewModel.sponsors.value.isEmpty, isTrue);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('removeSponsor handles error', () async {
      when(mockSponsorUseCase.removeSponsor(sponsor.uid)).thenAnswer((_) async => Result.error(NetworkException('Remove failed')));

      await viewModel.removeSponsor(sponsor.uid);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Remove failed');
    });

    test('checkToken returns correct value from use case', () async {
      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => true);
      var result = await viewModel.checkToken();
      expect(result, isTrue);

      when(mockCheckTokenSavedUseCase.checkToken()).thenAnswer((_) async => false);
      result = await viewModel.checkToken();
      expect(result, isFalse);
    });
  });
}
