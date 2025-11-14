import 'dart:convert';

class GithubData {
  final String? token;
  final String? projectName;

  GithubData({this.token, this.projectName});

  factory GithubData.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubData(token: json["token"], projectName: json["projectName"]);
  }

  String toJson() => jsonEncode({"token": token, "projectName": projectName});
}
