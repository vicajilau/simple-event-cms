import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for event date-related operations
/// Provides localized date formatting and day name extraction
class EventDateUtils {
  /// Gets the localized day name from a date string
  ///
  /// [dateString] The date in ISO format (YYYY-MM-DD)
  /// [context] The build context for localization
  /// Returns the localized day name (e.g., "Monday", "Lunes", "Lundi")
  static String getDayName(String dateString, BuildContext context) {
    try {
      final date = DateTime.parse(dateString);
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat('EEEE', locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to English if parsing fails
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE', 'en');
      return formatter.format(date);
    }
  }

  /// Gets the localized short day name from a date string
  ///
  /// [dateString] The date in ISO format (YYYY-MM-DD)
  /// [context] The build context for localization
  /// Returns the short localized day name (e.g., "Mon", "Lun")
  static String getShortDayName(String dateString, BuildContext context) {
    try {
      final date = DateTime.parse(dateString);
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat('EEE', locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to English if parsing fails
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEE', 'en');
      return formatter.format(date);
    }
  }

  /// Gets the localized date in a readable format
  ///
  /// [dateString] The date in ISO format (YYYY-MM-DD)
  /// [context] The build context for localization
  /// Returns the formatted date (e.g., "March 15, 2025", "15 de marzo de 2025")
  static String getFormattedDate(String dateString, BuildContext context) {
    try {
      final date = DateTime.parse(dateString);
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat('MMMM d, y', locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to English if parsing fails
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('MMMM d, y', 'en');
      return formatter.format(date);
    }
  }

  /// Gets the localized short date format
  ///
  /// [dateString] The date in ISO format (YYYY-MM-DD)
  /// [context] The build context for localization
  /// Returns the short formatted date (e.g., "Mar 15", "15 Mar")
  static String getShortFormattedDate(String dateString, BuildContext context) {
    try {
      final date = DateTime.parse(dateString);
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat('MMM d', locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to English if parsing fails
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('MMM d', 'en');
      return formatter.format(date);
    }
  }
}
