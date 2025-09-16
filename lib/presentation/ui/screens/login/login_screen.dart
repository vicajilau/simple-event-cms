import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:go_router/go_router.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/core.dart';
import 'package:sec/core/models/github/github_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _token = '';

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí puedes agregar la lógica de autenticación
      try {
        var github = GitHub(auth: Authentication.withToken(_token));
        final user = await github.users.getCurrentUser();

        // Si la autenticación es exitosa y no hay excepción:
        if (user.login != null) {
          await SecureInfo.saveGithubKey(
            GithubData(
              token: github.auth.token.toString(),
              repo: await ConfigLoader.loadBaseUrl(),
            ),
          );
          // Verifica si hay autenticación básica o token
          if (context.mounted) {
            // Redirigir a la pantalla de eventos después del login exitoso
            context.go('/');
          }
        } else {
          // Este bloque podría no ser alcanzado si la autenticación falla antes
          _showErrorSnackbar('Fallo de autenticación desconocido.');
        }
      } catch (e) {
        // Captura excepciones comunes de autenticación o de red
        // ignore: use_build_context_synchronously
        _showErrorSnackbar(
          'Credenciales incorrectas o problema de red. Por favor, verifica tu email y contraseña.',
        );
        debugPrint('Error de autenticación: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Token'),
                validator: (value) => value!.isEmpty
                    ? 'Por favor, ingresa un token de github valido'
                    : null,
                onSaved: (value) => _token = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
