import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/event_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar URLs limpias sin hash para Flutter web
  usePathUrlStrategy();

  // Inicializar dependencias
  await setupDependencies();

  // Inicializar dependencias
  AppRouter.init();

  runApp(const EventApp());
}
