import 'package:sec/core/models/github/github_model.dart';

import '../config/paths_github.dart';

class Sponsor extends GitHubModel {
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
    required super.uid,
    required this.name,
    required this.type,
    required this.logo,
    required this.website,
    super.pathUrl = PathsGithub.sponsorPath,
    super.updateMessage = PathsGithub.sponsorUpdateMessage,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
    uid: json["UID"].toString(),
    name: json["name"],
    type: json["type"],
    logo: json["logo"],
    website: json["website"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "type": type,
    "logo": logo,
    "website": website,
  };
}
