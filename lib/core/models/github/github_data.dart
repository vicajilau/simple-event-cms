import 'dart:convert';

class GithubData {
  final String? token;
  final String? repo;
  final String? projectName;
  final String? branch;

  GithubData({
    this.token,
    this.repo,
    this.projectName,
    this.branch,
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
