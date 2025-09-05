import 'package:flutter/material.dart';

class TimeUtils {
  static TimeOfDay? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static int parseStartTimeToMinutes(String timeRange) {
    final start = timeRange.split(' - ').first.trim();
    final parts = start.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
