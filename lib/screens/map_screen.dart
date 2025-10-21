import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mapa del Campus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Explora el campus y toca los puntos marcados para obtener información.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 1.0,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(100),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/plano_universidad.webp',
                            fit: BoxFit.contain,
                          ),
                        ),

                        Positioned(
                          left: 190,
                          top: 280,
                          child: _buildMarker(
                            context,
                            title: 'Edificio C',
                            description:
                                'Aquí se encuentran las salas de Ingeniería y laboratorios.',
                            color: Colors.red,
                          ),
                        ),
                        Positioned(
                          left: 155,
                          top: 350,
                          child: _buildMarker(
                            context,
                            title: 'Biblioteca Central',
                            description:
                                'Espacio de estudio, préstamo de libros y zona de descanso.',
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          left: 70,
                          top: 310,
                          child: _buildMarker(
                            context,
                            title: 'Edificio M',
                            description:
                                'Aquí se encuentran las salas de Ingeniería.',
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMarker(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
  }) {
    final Color darkerColor = _getDarkerShade(color);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: AppColors.primary),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          Icon(Icons.location_on, color: color, size: 38),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: darkerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDarkerShade(Color color) {
    if (color is MaterialColor) {
      return color.shade700;
    }
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.8).round(),
      (color.green * 0.8).round(),
      (color.blue * 0.8).round(),
    );
  }
}
