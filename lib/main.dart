import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:sec/event_app.dart';

import 'core/config/config_loader.dart';
import 'core/services/load/data_loader.dart';

void main() {
  usePathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    initialRoute: '/',
    onGenerateRoute: (settings) {
      final uri = Uri.parse(settings.name ?? "");
      if (uri.path == "/auth/callback" &&
          uri.queryParameters.containsKey("code")) {
        final code = uri.queryParameters["code"];
        print("Código recibido: $code");
        print("query recibida: ${uri.queryParameters}");
        print("contentText recibido: ${uri.data?.contentText}");
        print("el code aparece como: ${settings.name}");
        return MaterialPageRoute(
          builder: (_) => GitHubCallbackPage(code: code),
        );
      }
      return MaterialPageRoute(builder: (_) => GitHubLoginPage());
    },
  );
}

class GitHubLoginPage extends StatelessWidget {
  final clientId = 'Ov23livw2uLsu4413DzN';
  final redirectUri =
      'http://localhost:3000/auth/callback'; // Asegúrate de que esté registrado en GitHub

  Future<void> loginWithGitHub() async {
    try {
      final authUrl = Uri.https("github.com", "/login/oauth/authorize", {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
      }).toString();
      html.window.location.href = authUrl;
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
  final redirectUri = 'http://localhost:3000/auth/callback';

  @override
  void initState() {
    super.initState();
    _handleGitHubCallback();
  }

  Future<void> _handleGitHubCallback() async {
    try {
      String? codeToUse = widget.code;

      if (codeToUse == null)
        throw Exception("No se recibió el código de autorización");

      final response = await http.post(
        Uri.parse('https://github.com/login/device/code'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'device_code': codeToUse,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
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
      setState(() async {
        username = user['login'];
        if (username != null) {
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
            : CircularProgressIndicator(),
      ),
    );
  }
}
