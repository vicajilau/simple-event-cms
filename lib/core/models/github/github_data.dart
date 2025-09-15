import 'dart:convert';

class GithubData {
  final String token;
  final String repo;
  String branch = "develop";

  GithubData({
    required this.token,
    required this.repo,
    this.branch = "develop",
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
