import 'package:flutter/material.dart';
import 'package:github/github.dart' hide Organization;
import 'package:go_router/go_router.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final Organization organization = getIt<Organization>();
  String _projectName = '';
  String _token = '';

  Future<void> _submit(BuildContext context) async {
    final location = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Here you can add the authentication logic
      try {
        var github = GitHub(auth: Authentication.withToken(_token));
        final user = await github.users.getCurrentUser();

        // Verify if the project exists in the user's repositories
        final repositories = github.repositories.listUserRepositories(
          user.login!,
        );
        bool projectExists = false;
        await for (var repo in repositories) {
          if (repo.name == _projectName) {
            projectExists = true;
            break; // Exit the loop once the project is found
          }
        }

        // If authentication is successful and there is no exception:
        if (user.login != null && projectExists) {
          await SecureInfo.saveGithubKey(
            GithubData(
              token: github.auth.token.toString(),
              projectName: _projectName,
              branch: organization.branch
            ),
          );
          // Check if there is basic authentication or token
          if (context.mounted) {
            // Redirect to the events screen after successful login
            context.go('/');
          }
        } else {
          // This block might not be reached if authentication fails earlier
          if (user.login == null) {
            _showErrorSnackbar(location.unknownAuthError);
          } else if (!projectExists) {
            _showErrorSnackbar(
              location.projectNotFoundError.toString().replaceFirst('{projectName}', _projectName),
            );
          }
        }
      } catch (e) {
        // Catch common authentication or network exceptions
        // ignore: use_build_context_synchronously
        _showErrorSnackbar(
          location.authNetworkError,
        );
        debugPrint('Error de autenticación: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
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
    return Scaffold(
      appBar: AppBar(title: Text(location.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: location.projectNameLabel),
                validator: (value) =>
                    value!.isEmpty ? location.projectNameHint : null,
                onSaved: (value) => _projectName = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: location.tokenLabel),
                validator: (value) =>
                    value!.isEmpty ? location.tokenHint : null,
                onSaved: (value) => _token = value!,
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
    );
  }
}
