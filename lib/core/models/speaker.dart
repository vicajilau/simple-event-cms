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

  List<String> eventUIDS;

  /// Creates a new Speaker instance
  Speaker({
    required super.uid,
    required this.name,
    required this.bio,
    required this.image,
    required this.social,
    required this.eventUIDS,
    super.pathUrl = PathsGithub.eventPath,
    super.updateMessage = PathsGithub.eventUpdateMessage,
  });

  Speaker copyWith({
    String? uid,
    String? name,
    String? bio,
    String? image,
    Social? social,
    List<String>? eventUIDS,
    String? pathUrl,
    String? updateMessage,
  }) =>
      Speaker(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        bio: bio ?? this.bio,
        image: image ?? this.image,
        social: social ?? this.social,
        eventUIDS: eventUIDS ?? this.eventUIDS,
        pathUrl: pathUrl ?? this.pathUrl,
        updateMessage: updateMessage ?? this.updateMessage,
      );

  factory Speaker.fromJson(Map<String, dynamic> json) => Speaker(
    uid: json["UID"].toString(),
    name: json["name"],
    bio: json["bio"],
    image: json["image"],
    eventUIDS: (json['eventUIDS'] as List<dynamic>)
        .map<String>((eventUID) => eventUID['UID'].toString())
        .toSet()
        .toList(),
    social: Social.fromJson(json["social"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "UID": uid,
    "name": name,
    "bio": bio,
    "image": image,
    "social": social.toJson(),
    "eventUIDS": eventUIDS.map((uid) => {'UID': uid}).toList(),
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
