import 'dart:convert';

class GithubService {
  final String token;
  final String repo;
  String branch = "feature/prepare_clean_update_fata";

  GithubService({
    required this.token,
    required this.repo,
    this.branch = "main",
  });



  factory GithubService.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubService(
      token: json["token"],
      repo: json["repo"],
      branch: json["branch"],
    );
  }

  String toJson() =>
      jsonEncode({"token": token, "repo": repo, "branch": branch});
}
