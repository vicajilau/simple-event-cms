import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:github/github.dart' hide Organization;
import 'package:go_router/go_router.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';

class AdminLoginScreen extends StatefulWidget {
  final void Function() onLoginSuccess;

  const AdminLoginScreen(this.onLoginSuccess, {super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Config config = getIt<Config>();
  final ValueNotifier<String> _token = ValueNotifier('');

  final ValueNotifier<bool> _obscureText = ValueNotifier(true);

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
              projectName: config.projectName,
            ),
          );
          // Check if there is basic authentication or token
          if (context.mounted) {
            // Close the dialog that contains this view
            widget.onLoginSuccess();
            context.pop();
          }
        } else {
          // This block might not be reached if authentication fails earlier
          if (user.login == null && context.mounted) {
            _showErrorSnackbar(location.unknownAuthError, context);
          }
        }
      } catch (e) {
        // Catch common authentication or network exceptions
        // ignore: use_build_context_synchronously
        _showErrorSnackbar(location.authNetworkError, context);
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
        Container(
          width: 350, // Limita la anchura del Container
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // Color del borde
              width: 1.5, // Ancho del borde
            ),
            borderRadius: BorderRadius.circular(
              23.0,
            ), // Opcional: para bordes redondeados
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    location.enterGithubTokenTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: IntrinsicWidth(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _obscureText,
                        builder: (context, isObscure, child) {
                          return TextFormField(
                            obscuringCharacter: '*',
                            obscureText: isObscure,
                            decoration: InputDecoration(
                              hintText: location.tokenHintLabel,
                              hintStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15.0,
                                ), // Radio para bordes redondeados
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              prefixIcon: IconButton(
                                icon: FaIcon(
                                  isObscure
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _obscureText.value = !isObscure,
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? location.tokenHint : null,
                            onSaved: (value) => _token.value = value!,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.github,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            location.loginTitle,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
