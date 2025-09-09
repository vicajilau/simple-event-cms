import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sec/ui/screens/login_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp provides the Navigator
      title: 'Login con GitHub',
      home: MyHomePage(), // Use a separate widget for the home screen
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login con GitHub')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Iniciar sesión con GitHub'),
              onPressed: () {
                Navigator.push( // Now this context has a Navigator
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ),
          SizedBox(height: 20), // Espacio entre los botones
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push( // And this context also has a Navigator
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Modo Invitado'),
            ),
          ),
        ],
      ),
    );
  }
}
