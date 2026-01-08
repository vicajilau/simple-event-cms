import 'package:flutter/cupertino.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/domain/repositories/token_repository.dart';

import '../../core/di/dependency_injection.dart';

class TokenRepositoryImpl implements TokenRepository {
  @override
  Future<bool> isTokenSaved() async {
    SecureInfo secureInfo = getIt<SecureInfo>();
    try {
      final GithubData githubData = await secureInfo.getGithubKey();
      // Check if the token exists and is not empty
      return githubData.getToken() != null && githubData.getToken()!.isNotEmpty;
    } catch (e) {
      // If there's any error reading from secure storage or parsing,
      // assume token is not saved or is invalid.
      debugPrint('Error checking token: $e');
      return false;
    }
  }
}
