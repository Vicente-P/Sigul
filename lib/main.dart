import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sigul/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CL', null); // Inicializa para Chile
  Intl.defaultLocale = 'es_CL'; // Usa español de Chile por defecto
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGUL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          bodyLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      home: Scaffold(
        body: const HomeScreen(),
      ),
    );
  }
}
