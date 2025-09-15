import 'package:sec/core/models/github/github_model.dart';

import '../config/paths_github.dart';

class Organization extends GitHubModel {
  final String organizationName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;
  final String baseUrl;

  Organization({
    super.uid = "unique-id-organization",
    required this.organizationName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    required this.baseUrl,
    super.pathUrl = PathsGithub.organizationPath,
    super.updateMessage = PathsGithub.organizationUpdateMessage,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    organizationName: json["organizationName"],
    primaryColorOrganization: json["primaryColorOrganization"],
    secondaryColorOrganization: json["secondaryColorOrganization"],
    baseUrl: json["baseUrlOrganization"],
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      "organizationName": organizationName,
      "primaryColorOrganization": primaryColorOrganization,
      "secondaryColorOrganization": secondaryColorOrganization,
      "baseUrlOrganization": baseUrl,
    };
  }
}
