import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bienvenido al Panel de Administración',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión con GitHub'),
              onPressed: () {
                context.go('/admin/login');
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver a Eventos'),
              onPressed: () {
                context.go('/');
              },
            ),
          ),
        ],
      ),
    );
  }
}
