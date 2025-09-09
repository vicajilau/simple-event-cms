import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sec/ui/screens/login_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login con GitHub',
      home: Scaffold(
        appBar: AppBar(title: Text('Login con GitHub')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () => LoginPage(),
                child: Text('Iniciar sesión con GitHub'),
              ),
            ),
            SizedBox(height: 20), // Espacio entre los botones
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para el modo invitado
                  print('Modo invitado seleccionado');
                },
                child: Text('Modo Invitado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}