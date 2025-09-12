import 'package:intl/intl.dart';

/// Represents the date information for an event_collection
/// Contains start date, end date, and timezone information
class EventDates {
  /// The start date of the event_collection in ISO format (YYYY-MM-DD)
  final String startDate;

  /// The end date of the event_collection in ISO format (YYYY-MM-DD)
  final String endDate;

  /// The timezone of the event_collection (e.g., "Europe/Madrid", "America/New_York")
  final String timezone;

  /// Creates a new EventDates instance
  EventDates({
    required this.startDate,
    required this.endDate,
    required this.timezone,
  });

  /// Creates an EventDates from JSON data
  /// All date fields are required and must be in ISO format
  factory EventDates.fromJson(Map<String, dynamic> json) {
    return EventDates(
      startDate: json['startDate'],
      endDate: json['endDate'],
      timezone: json['timezone'],
    );
  }

  /// Converts this EventDates instance to a JSON object
  Map<String, dynamic> toJson() {
    return {'startDate': startDate, 'endDate': endDate, 'timezone': timezone};
  }

  List<String> getFormattedDaysInDateRange() {
    final List<String> formattedDays = [];
    final DateTime startDateConverted = DateTime.parse(startDate);
    final DateTime endDateConverted = DateTime.parse(endDate);

    DateTime currentDate = DateTime(
      startDateConverted.year,
      startDateConverted.month,
      startDateConverted.day,
    );
    final DateTime normalizedEndDate = DateTime(
      endDateConverted.year,
      endDateConverted.month,
      endDateConverted.day,
    );

    if (currentDate.isAfter(normalizedEndDate)) {
      return [];
    }

    final DateFormat outputFormatter = DateFormat('yyyy-MM-dd');

    while (!currentDate.isAfter(normalizedEndDate)) {
      formattedDays.add(outputFormatter.format(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return formattedDays;
  }
}

/// Represents venue information for an event_collection
/// Contains location details where the event_collection will take place
class Venue {
  /// The name of the venue (e.g., "Convention Center", "Palacio de Congresos")
  final String name;

  /// The complete address of the venue
  final String address;

  /// The city where the venue is located
  final String city;

  /// Creates a new Venue instance
  Venue({required this.name, required this.address, required this.city});

  /// Creates a Venue from JSON data
  /// All location fields are required for proper venue identification
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'],
      address: json['address'],
      city: json['city'],
    );
  }

  /// Converts this Venue instance to a JSON object
  Map<String, dynamic> toJson() {
    return {'name': name, 'address': address, 'city': city};
  }
}
