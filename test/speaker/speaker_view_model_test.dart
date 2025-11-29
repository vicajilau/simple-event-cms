import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../mocks.mocks.dart';

void main() {
  late SpeakerViewModelImpl viewModel;
  late MockSpeakerUseCase mockSpeakerUseCase;
  late MockCheckTokenSavedUseCase mockCheckTokenSavedUseCase;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<void>>(const Result.ok(null));
    provideDummy<Result<List<Speaker>>>(const Result.ok([]));
  });
  setUp(() {
    getIt.reset();
    mockSpeakerUseCase = MockSpeakerUseCase();
    mockCheckTokenSavedUseCase = MockCheckTokenSavedUseCase();

    getIt.registerSingleton<SpeakerUseCase>(mockSpeakerUseCase);
    getIt.registerSingleton<CheckTokenSavedUseCase>(mockCheckTokenSavedUseCase);

    viewModel = SpeakerViewModelImpl();
  });

  group('SpeakerViewModelImpl', () {
    final speaker = Speaker(
      uid: '1',
      name: 'John Doe',
      bio: 'Bio',
      social: Social(),
      eventUIDS: ['event1'],
      image: '',
    );
    const eventId = 'event1';

    test('setup loads speakers successfully', () async {
      when(
        mockSpeakerUseCase.getSpeakersById(eventId),
      ).thenAnswer((_) async => Result.ok([speaker]));

      await viewModel.setup(eventId);

      expect(viewModel.viewState.value, ViewState.loadFinished);
      expect(viewModel.speakers.value, [speaker]);
    });

    test('setup handles error when loading speakers', () async {
      when(
        mockSpeakerUseCase.getSpeakersById(eventId),
      ).thenAnswer((_) async => Result.error(NetworkException(('Failed to load'))));

      await viewModel.setup(eventId);

      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Failed to load');
    });

    test('addSpeaker adds a speaker', () async {
      when(
        mockSpeakerUseCase.saveSpeaker(speaker, eventId),
      ).thenAnswer((_) async => Result.ok(null));
      await viewModel.addSpeaker(speaker, eventId);
      expect(viewModel.speakers.value.contains(speaker), isTrue);
      verify(mockSpeakerUseCase.saveSpeaker(speaker, eventId)).called(1);
    });

    test('editSpeaker edits a speaker', () async {
      final updatedSpeaker = speaker.copyWith(name: 'Jane Doe');
      viewModel.speakers.value = [speaker];
      when(
        mockSpeakerUseCase.saveSpeaker(updatedSpeaker, eventId),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.editSpeaker(updatedSpeaker, eventId);

      expect(viewModel.speakers.value.first.name, 'Jane Doe');
      verify(mockSpeakerUseCase.saveSpeaker(updatedSpeaker, eventId)).called(1);
    });

    test('removeSpeaker successfully removes a speaker', () async {
      viewModel.speakers.value = [speaker];
      when(
        mockSpeakerUseCase.removeSpeaker(speaker.uid, eventId),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.removeSpeaker(speaker.uid, eventId);

      expect(viewModel.speakers.value.isEmpty, isTrue);
      expect(viewModel.viewState.value, ViewState.loadFinished);
    });

    test('removeSpeaker handles error', () async {
      when(
        mockSpeakerUseCase.removeSpeaker(speaker.uid, eventId),
      ).thenAnswer((_) async => Result.error(NetworkException('Remove failed')));

      await viewModel.removeSpeaker(speaker.uid, eventId);

      expect(viewModel.speakers.value.isNotEmpty, false);
      expect(viewModel.viewState.value, ViewState.error);
      expect(viewModel.errorMessage, 'Remove failed');
    });

    test('checkToken returns correct value', () async {
      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => true);
      expect(await viewModel.checkToken(), isTrue);

      when(
        mockCheckTokenSavedUseCase.checkToken(),
      ).thenAnswer((_) async => false);
      expect(await viewModel.checkToken(), isFalse);
    });
  });
}
