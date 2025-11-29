import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/routing/check_org.dart';

void main() {
  group('CheckOrg', () {
    late CheckOrg checkOrg;

    setUp(() {
      checkOrg = CheckOrg();
    });

    test('initial hasError is false', () {
      expect(checkOrg.hasError, isFalse);
    });

    test('setError should update hasError', () {
      checkOrg.setError(true);
      expect(checkOrg.hasError, isTrue);

      checkOrg.setError(false);
      expect(checkOrg.hasError, isFalse);
    });
  });
}
