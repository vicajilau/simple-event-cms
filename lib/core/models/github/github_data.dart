import 'dart:convert';

class GithubData {
  final String? token;
  final String? repo;
  final String? projectName;
  String branch = "feature/sessions_update";

  GithubData({
    this.token,
    this.repo,
    this.projectName,
    this.branch = "feature/sessions_update",
  });

  factory GithubData.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubData(
      token: json["token"],
      repo: json["repo"],
      projectName: json["projectName"],
      branch: json["branch"],
    );
  }

  String toJson() => jsonEncode({
    "token": token,
    "repo": repo,
    "projectName": projectName,
    "branch": branch,
  });
}
