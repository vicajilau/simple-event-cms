import 'dart:convert';

class GithubData {
  final String? token;
  final String? repo;
  final String? projectName;

  GithubData({
    this.token,
    this.repo,
    this.projectName,
  });

  factory GithubData.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubData(
      token: json["token"],
      repo: json["repo"],
      projectName: json["projectName"],
    );
  }

  String toJson() => jsonEncode({
    "token": token,
    "repo": repo,
    "projectName": projectName,
  });
}
