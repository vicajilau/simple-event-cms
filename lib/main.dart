import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/event_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias
  await setupDependencies();

  runApp(const EventApp());
}
