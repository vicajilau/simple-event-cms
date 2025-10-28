import 'package:flutter/material.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/github/github_data.dart';

class AuthService extends ChangeNotifier {
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  AuthService() {
    _loadAdminState();
  }

  Future<void> _loadAdminState() async {
    final githubData = await SecureInfo.getGithubKey();
    // Si tenemos token y proyecto, consideramos admin
    _isAdmin =
        githubData.token?.isNotEmpty == true &&
        githubData.projectName?.isNotEmpty == true;
    notifyListeners();
  }

  Future<void> logout() async {
    // Borrar datos de SecureStorage
    _isAdmin = false;
    notifyListeners();
    await SecureInfo.saveGithubKey(GithubData(token: '', projectName: ''));
  }

  Future<void> login(GithubData githubData) async {
    await SecureInfo.saveGithubKey(githubData);
    _isAdmin = true;
    notifyListeners();
  }
}
