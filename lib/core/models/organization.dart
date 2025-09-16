import 'package:sec/core/models/github/github_model.dart';

import '../config/paths_github.dart';

class Organization extends GitHubModel {
  final String organizationName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;
  final String github_user;
  final String project_name;
  final String year;

  Organization({
    super.uid = "unique-id-organization",
    required this.organizationName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    required this.github_user,
    required this.project_name,
    required this.year,
    super.pathUrl = PathsGithub.organizationPath,
    super.updateMessage = PathsGithub.organizationUpdateMessage,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    organizationName: json["organizationName"],
    primaryColorOrganization: json["primaryColorOrganization"],
    secondaryColorOrganization: json["secondaryColorOrganization"],
    github_user: json["github_user"],
    project_name: json["project_name"],
    year: json["year"],
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      "organizationName": organizationName,
      "primaryColorOrganization": primaryColorOrganization,
      "secondaryColorOrganization": secondaryColorOrganization,
      "github_user": github_user,
      "project_name": project_name,
      "year": year,
    };
  }
}
