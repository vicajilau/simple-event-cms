import 'package:sec/core/models/github/github_model.dart';

import '../config/paths_github.dart';

class Organization extends GitHubModel {
  String organizationName;
  String primaryColorOrganization;
  String secondaryColorOrganization;
  String githubUser;
  String projectName = "simple-event-cms";
  String year;
  String branch = "main";

  Organization({
    super.uid = "unique-id-organization",
    required this.organizationName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    required this.githubUser,
    required this.projectName,
    required this.year,
    required this.branch,
    super.pathUrl = PathsGithub.organizationPath,
    super.updateMessage = PathsGithub.organizationUpdateMessage,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    organizationName: json["organizationName"],
    primaryColorOrganization: json["primaryColorOrganization"],
    secondaryColorOrganization: json["secondaryColorOrganization"],
    githubUser: json["github_user"],
    projectName: json["project_name"],
    branch: json["branch"],
    year: json["year"],
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      "organizationName": organizationName,
      "primaryColorOrganization": primaryColorOrganization,
      "secondaryColorOrganization": secondaryColorOrganization,
      "github_user": githubUser,
      "project_name": projectName,
      "year": year,
      "branch": branch,
    };
  }
}
