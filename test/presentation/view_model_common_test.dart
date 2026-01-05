import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/data/exceptions/exceptions.dart';
import 'package:sec/presentation/view_model_common.dart';

// --- Mocks and Concrete Implementations ---

// A concrete implementation of the abstract ViewModelCommon class for testing purposes.
class TestViewModel extends ViewModelCommon {
  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.loadFinished);

  @override
  String errorMessage = ""; // Initialize with an empty string

  // The following methods are abstract and don't need a real implementation for this test.
  @override
  Future<void> setup([Object? argument]) async {
    // No-op
  }

  @override
  void dispose() {
    viewState.dispose();
  }

  @override
  Future<bool> checkToken() async {
    return false;
  }
}

// --- Test Suite ---

void main() {
  group('ViewModelCommon', () {
    // Declare a variable for our testable view model instance.
    late TestViewModel viewModel;

    // The setUp function runs before each test, ensuring a fresh instance.
    setUp(() {
      viewModel = TestViewModel();
    });

    group('setErrorKey', () {
      test('should set errorMessage to the exception message when exception is not null', () {
        // Arrange
        // Create a mock exception with a specific error message.
        final mockException = GithubException('This is a test error message.');

        // Act
        // Call the method we want to test.
        viewModel.setErrorKey(mockException);

        // Assert
        // Verify that the errorMessage property was updated correctly.
        expect(viewModel.errorMessage, 'This is a test error message.');
      });

      test('should set errorMessage to an empty string when exception is null', () {
        // Arrange
        // Set an initial error message to ensure the method is actually changing it.
        viewModel.errorMessage = 'An existing error message';

        // Act
        // Call the method with a null argument.
        viewModel.setErrorKey(null);

        // Assert
        // Verify that the errorMessage property was cleared.
        expect(viewModel.errorMessage, "");
      });
    });

    // Although abstract, we can add a simple test for dispose to ensure it runs without error.
    test('dispose should run without throwing an error', () {
      // Arrange (viewModel is created in setUp)

      // Act & Assert
      // We expect that calling dispose does not throw any exceptions.
      expect(() => viewModel.dispose(), returnsNormally);
    });
  });
}
