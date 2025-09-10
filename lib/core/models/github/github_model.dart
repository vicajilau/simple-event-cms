abstract class GitHubModel {
  final String pathUrl;
  final String updateMessage;

  GitHubModel({required this.pathUrl, required this.updateMessage});

  Map<String, dynamic> toJson();
}
