class Sponsor {
  /// Unique identifier of the sponsor
  final String uid;

  /// Name of the sponsor
  final String name;

  /// Sponsorship level or category (e.g., Silver Sponsor)
  final String type;

  /// URL to the sponsor's logo image
  final String logo;

  /// Official website of the sponsor
  final String website;

  /// Creates a new Sponsor instance
  Sponsor({
    required this.uid,
    required this.name,
    required this.type,
    required this.logo,
    required this.website,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
    uid: json["UID"],
    name: json["name"],
    type: json["type"],
    logo: json["logo"],
    website: json["website"],
  );

  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "type": type,
    "logo": logo,
    "website": website,
  };
}
