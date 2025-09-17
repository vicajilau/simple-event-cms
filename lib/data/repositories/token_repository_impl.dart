import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/domain/repositories/token_repository.dart';

class TokenRepositoryImpl implements TokenRepository {
  @override
  Future<bool> isTokenSaved() async {
    try {
      final GithubData githubData = await SecureInfo.getGithubKey();
      // Check if the token exists and is not empty
      return githubData.token != null && githubData.token!.isNotEmpty;
    } catch (e) {
      // If there's any error reading from secure storage or parsing,
      // assume token is not saved or is invalid.
      print('Error checking token: $e');
      return false;
    }
  }
}
