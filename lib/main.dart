import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => GitHubLoginPage(),
      '/auth/callback': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String?;
        print("Código recibido: $args");
        return GitHubCallbackPage(code: args);
      },
    },
  );
}

class GitHubLoginPage extends StatelessWidget {
  final clientId = 'Ov23livw2uLsu4413DzN';
  final clientSecret = '940b8ddfa8119cb26baf0f39ffa661335e8384d5';
  final redirectUri =
      'http://localhost:3000/#/auth/callback'; // Asegúrate de que esté registrado en GitHub
  var codeGithub = null; // Asegúrate de que esté registrado en GitHub

  Future<void> loginWithGitHub() async {
    final authUrl =
        'https://github.com/login/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri';
    try {
      codeGithub = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: "myapp",
      );
    } catch (e) {
      print("Error durante la autenticación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login con GitHub')),
      body: Center(
        child: ElevatedButton(
          onPressed: loginWithGitHub,
          child: Text('Iniciar sesión con GitHub'),
        ),
      ),
    );
  }
}

class GitHubCallbackPage extends StatefulWidget {
  final String? code;

  const GitHubCallbackPage({Key? key, this.code}) : super(key: key);

  @override
  State<GitHubCallbackPage> createState() => _GitHubCallbackPageState();
}

class _GitHubCallbackPageState extends State<GitHubCallbackPage> {
  String? username;
  String? error;

  final clientId = 'Ov23livw2uLsu4413DzN';
  final clientSecret = '940b8ddfa8119cb26baf0f39ffa661335e8384d5';
  final redirectUri = 'http://localhost:3000/#/auth/callback';

  @override
  void initState() {
    super.initState();
    _handleGitHubCallback();
  }

  Future<void> _handleGitHubCallback() async {
    try {
      String? codeToUse;
      if (widget.code != null) {
        codeToUse = Uri.parse(widget.code!).queryParameters['code'];
      }
      if (codeToUse == null)
        throw Exception("No se recibió el código de autorización");

      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': codeToUse,
          'redirect_uri': redirectUri,
        },
      );

      final accessToken = json.decode(response.body)['access_token'];
      if (accessToken == null)
        throw Exception("No se recibió el token de acceso");

      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final user = json.decode(userResponse.body);
      setState(() {
        username = user['login'];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Callback')),
      body: Center(
        child: error != null
            ? Text('Error: $error')
            : username != null
            ? Text('Usuario logueado: $username')
            : CircularProgressIndicator(),
      ),
    );
  }
}
