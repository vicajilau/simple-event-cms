import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/data/exceptions/exceptions.dart';

// Creamos una excepción de prueba que herede de CustomException
class TestException extends CustomException {
  const TestException(String message) : super(message);
}

void main() {
  group('Result Class Tests', () {

    group('Ok', () {
      test('should create an Ok instance with the correct value', () {
        const value = 'Success string';
        const result = Result<String>.ok(value);

        expect(result, isA<Ok<String>>());
        expect((result as Ok).value, value);
      });

      test('toString() should return the expected format', () {
        const value = 42;
        const result = Result<int>.ok(value);

        expect(result.toString(), 'Result<int>.ok(42)');
      });

      test('should work with complex objects', () {
        final mapValue = {'id': 1};
        final result = Result<Map<String, int>>.ok(mapValue);

        expect((result as Ok).value['id'], 1);
      });
    });

    group('Error', () {
      test('should create an Error instance with the correct CustomException', () {
        final exception = TestException('Something went wrong');
        final result = Result<String>.error(exception);

        expect(result, isA<Error<String>>());
        expect((result as Error).error, exception);
        expect((result as Error).error.message, 'Something went wrong');
      });

      test('toString() should return the expected format', () {
        final exception = TestException('Failure');
        final result = Result<int>.error(exception);

        // El formato depende de cómo sea el toString de TestException/CustomException
        expect(result.toString(), contains('Result<int>.error'));
        expect(result.toString(), contains('Failure'));
      });
    });

    group('Pattern Matching (Switch)', () {
      test('should match Ok pattern correctly', () {
        const result = Result<String>.ok('test');

        String? extractedValue;

        switch (result) {
          case Ok(:final value):
            extractedValue = value;
          case Error():
            extractedValue = 'failed';
        }

        expect(extractedValue, 'test');
      });

      test('should match Error pattern correctly', () {
        final result = Result<String>.error(TestException('error_msg'));

        String? errorMessage;

        switch (result) {
          case Ok():
            errorMessage = 'no error';
          case Error(:final error):
            errorMessage = error.message;
        }

        expect(errorMessage, 'error_msg');
      });
    });

    group('Type Safety', () {
      test('should maintain type integrity', () {
        const Result<int> result = Result.ok(10);

        // Esto debería compilar y ser verdadero
        expect(result, isA<Result<int>>());
        expect(result, isNot(isA<Result<String>>()));
      });
    });
  });
}
