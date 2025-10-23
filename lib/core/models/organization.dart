
import '../config/paths_github.dart';
import 'github/github_model.dart';

class Organization  extends GitHubModel {
  final String organizationName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;
  final String githubUser;
  final String projectName;
  final String year;
  final String branch;

  Organization({
    super.uid = "0",
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

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      organizationName: json['organizationName'],
      primaryColorOrganization: json['primaryColorOrganization'],
      secondaryColorOrganization: json['secondaryColorOrganization'],
      githubUser: json['github_user'],
      projectName: json['project_name'],
      year: json['year'],
      branch: json['branch'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'primaryColorOrganization': primaryColorOrganization,
      'secondaryColorOrganization': secondaryColorOrganization,
      'github_user': githubUser,
      'project_name': projectName,
      'year': year,
      'branch': branch,
    };
  }
}
