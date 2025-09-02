/// Represents the date information for an event
/// Contains start date, end date, and timezone information
class EventDates {
  /// The start date of the event in ISO format (YYYY-MM-DD)
  final String startDate;

  /// The end date of the event in ISO format (YYYY-MM-DD)
  final String endDate;

  /// The timezone of the event (e.g., "Europe/Madrid", "America/New_York")
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
}

/// Represents venue information for an event
/// Contains location details where the event will take place
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
