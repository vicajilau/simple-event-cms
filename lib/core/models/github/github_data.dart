import 'dart:convert';

class GithubData {
  final String? token;
  final String? repo;
  String branch = "feature/refactor_code";

  GithubData({
    this.token,
    this.repo,
    this.branch = "feature/refactor_code",
  });

  factory GithubData.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubData(
      token: json["token"],
      repo: json["repo"],
      branch: json["branch"],
    );
  }

  String toJson() =>
      jsonEncode({"token": token, "repo": repo, "branch": branch});
}
