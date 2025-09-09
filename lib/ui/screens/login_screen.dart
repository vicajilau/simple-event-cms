import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:sec/core/core.dart';
import 'package:sec/event_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí puedes agregar la lógica de autenticación
      // Por ejemplo, verificar el email y la contraseña con un backend
      var github = GitHub(auth: Authentication.basic(_email, _password));
      // Navegar a otra pantalla o mostrar un mensaje de éxito/error
      if(github.auth.isToken){
        final config = await ConfigLoader.loadConfig();
        final organization = await ConfigLoader.loadOrganization();
        final dataLoader = DataLoader(config, organization);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventApp(
              config: config,
              dataLoader: dataLoader,
              organization: organization,
            ),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Por favor, ingresa tu email' : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Por favor, ingresa tu contraseña' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
