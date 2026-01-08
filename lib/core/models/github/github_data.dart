import 'dart:convert';

class GithubData {
  final String? _token;
  final String? _projectName;

  GithubData({String? token, String? projectName})
      : _token = token,
        _projectName = projectName;

  factory GithubData.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return GithubData(
      token: json["token"],
      projectName: json["projectName"],
    );
  }

  String toJson() => jsonEncode({
    "token": _token,
    "projectName": _projectName,
  });

  String? getToken() {
    return _token;
  }
  String? getProjectName() {
    return _projectName;
  }
}
