import '../config/paths_github.dart';
import 'github/github_model.dart';

class Speaker extends GitHubModel {
  /// Full name of the speaker
  final String name;

  /// Short biography or description of the speaker
  final String bio;

  /// URL to the speaker's profile image
  final String? image;

  /// Social media links of the speaker
  final Social social;

  String eventUID;

  /// Creates a new Speaker instance
  Speaker({
    required super.uid,
    required this.name,
    required this.bio,
    required this.image,
    required this.social,
    required this.eventUID,
    super.pathUrl = PathsGithub.speakerPath,
    super.updateMessage = PathsGithub.speakerUpdateMessage,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) => Speaker(
    uid: json["UID"].toString(),
    name: json["name"],
    bio: json["bio"],
    image: json["image"],
    eventUID: json["eventUID"],
    social: Social.fromJson(json["social"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "bio": bio,
    "image": image,
    "social": social.toJson(),
    "eventUID": eventUID,
  };
}

class Social {
  final String? linkedin;
  final String? website;
  final String? twitter;
  final String? github;

  Social({this.linkedin, this.website, this.twitter, this.github});

  factory Social.fromJson(Map<String, dynamic> json) => Social(
    linkedin: json["linkedin"],
    twitter: json["twitter"],
    website: json["website"],
    github: json["github"],
  );

  Map<String, dynamic> toJson() => {
    "linkedin": linkedin,
    "twitter": twitter,
    "website": website,
    "github": github,
  };
}
