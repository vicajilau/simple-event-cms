import 'package:sec/core/models/github/github_model.dart';

import '../config/paths_github.dart';

class Organization extends GitHubModel {
  final String organizationName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;

  Organization({
    required this.organizationName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    super.pathUrl = PathsGithub.ORGANIZATION_PATH,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    organizationName: json["organizationName"],
    primaryColorOrganization: json["primaryColorOrganization"],
    secondaryColorOrganization: json["secondaryColorOrganization"],
    pathUrl: json["baseUrlOrganization"],
  );
}
