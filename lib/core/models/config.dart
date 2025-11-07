import '../config/paths_github.dart';
import 'github/github_model.dart';

class Config extends GitHubModel {
  final String configName;
  final String primaryColorOrganization;
  final String secondaryColorOrganization;
  final String githubUser;
  final String projectName;
  final String branch;
  String? eventForcedToViewUID;

  Config({
    super.uid = "0",
    required this.configName,
    required this.primaryColorOrganization,
    required this.secondaryColorOrganization,
    required this.githubUser,
    required this.projectName,
    required this.branch,
    this.eventForcedToViewUID,
    super.pathUrl = PathsGithub.configPath,
    super.updateMessage = PathsGithub.configUpdateMessage,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      configName: json['configName'],
      primaryColorOrganization: json['primaryColorOrganization'],
      secondaryColorOrganization: json['secondaryColorOrganization'],
      githubUser: json['github_user'],
      projectName: json['project_name'],
      branch: json['branch'],
      eventForcedToViewUID: json['eventForcedToViewUID'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'configName': configName,
      'primaryColorOrganization': primaryColorOrganization,
      'secondaryColorOrganization': secondaryColorOrganization,
      'github_user': githubUser,
      'project_name': projectName,
      'branch': branch,
      'eventForcedToViewUID': eventForcedToViewUID,
    };
  }
}
