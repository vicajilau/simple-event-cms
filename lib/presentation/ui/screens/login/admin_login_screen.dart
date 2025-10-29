import 'package:flutter/material.dart';
import 'package:github/github.dart' hide Organization;
import 'package:go_router/go_router.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';

class AdminLoginScreen extends StatelessWidget {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Organization organization = getIt<Organization>();
  final ValueNotifier<String> _token = ValueNotifier('');
  final void Function() onLoginSuccess;

  AdminLoginScreen(this.onLoginSuccess, {super.key});

  Future<void> _submit(BuildContext context) async {
    final location = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Here you can add the authentication logic
      try {
        var github = GitHub(auth: Authentication.withToken(_token.value));
        final user = await github.users.getCurrentUser();

        // If authentication is successful and there is no exception:
        if (user.login != null) {
          await SecureInfo.saveGithubKey(
            GithubData(
              token: github.auth.token.toString(),
              projectName: organization.projectName,
            ),
          );
          // Check if there is basic authentication or token
          if (context.mounted) {
            // Close the dialog that contains this view
            onLoginSuccess();
            context.pop();
          }
        } else {
          // This block might not be reached if authentication fails earlier
          if (user.login == null && context.mounted) {
            _showErrorSnackbar(location.unknownAuthError,context);
          }
        }
      } catch (e) {
        // Catch common authentication or network exceptions
        // ignore: use_build_context_synchronously
        _showErrorSnackbar(location.authNetworkError,context);
        debugPrint('Error de autenticación: $e');
      }
    }
  }

  void _showErrorSnackbar(String message, BuildContext context) {
    final location = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: location.closeButton,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 300, // Limita la anchura del TextFormField
                  child: TextFormField(
                    obscuringCharacter: '*',
                    obscureText: true,
                    decoration: InputDecoration(labelText: location.tokenLabel),
                    validator: (value) =>
                    value!.isEmpty ? location.tokenHint : null,
                    onSaved: (value) => _token.value = value!,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _submit(context),
                  child: Text(location.loginTitle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
