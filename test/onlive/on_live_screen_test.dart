import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_screen.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';
import '../mocks.mocks.dart';

void main() {
  late MockOnLiveViewModel mockViewModel;
  late ValueNotifier<ViewState> viewStateNotifier;

  setUpAll(() async {
    // Configuración inicial para cada test
    mockViewModel = MockOnLiveViewModel();
    viewStateNotifier = ValueNotifier(ViewState.isLoading);

    // Configurar los stubs del mock
    when(mockViewModel.viewState).thenReturn(viewStateNotifier);
    when(mockViewModel.setup(any)).thenAnswer((_) async {}); // Mockear setup para no hacer nada

    getIt.registerSingleton<OnLiveViewModel>(mockViewModel);
  });

  // Función helper para montar el widget con todo lo necesario
  Future<void> pumpOnLiveScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'), // Usar un locale fijo
        home: OnLiveScreen(
          data: OnLiveData(youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        ),
      ),
    );
  }

  group('OnLiveScreen Widget Tests', () {
    testWidgets('should display loading indicator when state is isLoading', (WidgetTester tester) async {
      // Arrange: El estado inicial ya es isLoading
      await pumpOnLiveScreen(tester);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget); // Título de la AppBar
    });
  });
}
