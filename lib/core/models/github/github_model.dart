abstract class GitHubModel {
  /// Unique identifier of the speaker
  final String uid;
  final String pathUrl;
  final String updateMessage;

  GitHubModel({required this.uid, required this.pathUrl, required this.updateMessage});

  Map<String, dynamic> toJson();
}
