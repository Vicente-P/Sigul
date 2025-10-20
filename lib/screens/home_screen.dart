import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/core/text_styles.dart';
import 'package:sigul/screens/calendar_screen.dart';
import 'package:sigul/screens/ramos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text('Welcome to Sigul App')),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RamosScreen()),
                    );
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                  ),
                  child: Text("MIS ASIGNATURAS", style: TextStyles.bodyText),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    );
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                  ),
                  child: Text("CALCULAR HORARIOS", style: TextStyles.bodyText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
