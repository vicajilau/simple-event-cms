import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sec/core/utils/time_utils.dart'; // Adjust the import path if necessary

void main() {
  group('TimeUtils', () {
    // Group of tests for the parseTime method
    group('parseTime', () {
      test('should return correct TimeOfDay for a valid time string', () {
        // Arrange
        const timeString = '14:30';

        // Act
        final result = TimeUtils.parseTime(timeString);

        // Assert
        expect(result, isA<TimeOfDay>());
        expect(result, equals(const TimeOfDay(hour: 14, minute: 30)));
      });

      test('should return null when the time string is null', () {
        // Arrange
        const String? timeString = null;

        // Act
        final result = TimeUtils.parseTime(timeString);

        // Assert
        expect(result, isNull);
      });

      test('should return null when the time string is empty', () {
        // Arrange
        const timeString = '';

        // Act
        final result = TimeUtils.parseTime(timeString);

        // Assert
        expect(result, isNull);
      });

      test('should return null for a malformed time string (incorrect parts)',
              () {
            // Arrange
            const timeString = '14:30:00'; // Has 3 parts, not 2

            // Act
            final result = TimeUtils.parseTime(timeString);

            // Assert
            expect(result, isNull);
          });

      test('should return null for a malformed time string (non-integer hour)',
              () {
            // Arrange
            const timeString = 'fourteen:30';

            // Act
            final result = TimeUtils.parseTime(timeString);

            // Assert
            expect(result, isNull);
          });

      test(
          'should return null for a malformed time string (non-integer minute)',
              () {
            // Arrange
            const timeString = '14:thirty';

            // Act
            final result = TimeUtils.parseTime(timeString);

            // Assert
            expect(result, isNull);
          });
    });

    // Group of tests for the parseStartTimeToMinutes method
    group('parseStartTimeToMinutes', () {
      test(
          'should return the correct total minutes from a valid time range string',
              () {
            // Arrange
            const timeRange = '09:45 - 10:30';

            // Act
            final result = TimeUtils.parseStartTimeToMinutes(timeRange);

            // Assert
            // 9 hours * 60 minutes/hour + 45 minutes = 540 + 45 = 585
            expect(result, 585);
          });

      test('should correctly parse a time range with extra whitespace', () {
        // Arrange
        const timeRange = '  11:15  -  12:00  ';

        // Act
        final result = TimeUtils.parseStartTimeToMinutes(timeRange);

        // Assert
        // 11 * 60 + 15 = 660 + 15 = 675
        expect(result, 675);
      });

      test('should correctly parse a time range with only a start time', () {
        // Arrange
        const timeRange = '13:05';

        // Act
        final result = TimeUtils.parseStartTimeToMinutes(timeRange);

        // Assert
        // 13 * 60 + 5 = 780 + 5 = 785
        expect(result, 785);
      });
    });
  });
}
