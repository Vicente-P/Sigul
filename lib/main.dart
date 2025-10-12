import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sigul App'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
        ),
        backgroundColor: AppColors.background,
        body: HomeScreen(),
      ),
    );
  }
}
