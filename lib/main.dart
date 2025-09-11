import 'package:flutter/material.dart';
import 'package:sec/ui/screens/login/login_screen.dart';

import 'core/config/config_loader.dart';
import 'core/services/load/data_loader.dart';
import 'event_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login con GitHub',
      home: MyHomePage(), // Use a separate widget for the home screen
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
                Navigator.push(
                  // Now this context has a Navigator
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ),
          SizedBox(height: 20), // Espacio entre los botones
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final config = await ConfigLoader.loadConfig();
                final organization = await ConfigLoader.loadOrganization();
                final dataLoader = DataLoader(
                  config,
                  organization,
                ); // Pasa la instancia de github
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EventApp(
                        config: config,
                        dataLoader: dataLoader,
                        organization: organization,
                      ),
                    ),
                  );
                }
              },
              child: Text('Modo Invitado'),
            ),
          ),
        ],
      ),
    );
  }
}
