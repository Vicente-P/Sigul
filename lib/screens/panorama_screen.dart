import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:sigul/core/app_colors.dart';

class PanoramaScreen extends StatefulWidget {
  const PanoramaScreen({super.key});

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen> {
  final List<Map<String, String>> locations = [
    {'name': 'Entrada Ingeniería', 'image': 'assets/images/panorama01.webp'},
    {'name': 'Cielo estrellado', 'image': 'assets/images/panorama02.webp'},
    {'name': 'Edificio A', 'image': 'assets/images/panorama03.webp'},
    {'name': 'Edificio B', 'image': 'assets/images/panorama04.webp'},
    {'name': 'Edificio C', 'image': 'assets/images/panorama05.webp'},
    {'name': 'Aula Magna', 'image': 'assets/images/panorama06.webp'},
    {'name': 'Edificio M', 'image': 'assets/images/panorama07.webp'},
    {'name': 'Biblioteca Central', 'image': 'assets/images/panorama08.webp'},
    {'name': 'Edificio P', 'image': 'assets/images/panorama09.webp'},
    {'name': 'Gimnasio', 'image': 'assets/images/panorama10.webp'},
  ];

  late String _selectedImage;
  late String _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedImage = locations[0]['image']!;
    _selectedName = locations[0]['name']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Recorrido Virtual 360°',
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
        children: [
          const SizedBox(height: 12),

          // Indicador de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecciona una ubicación',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Dropdown estilizado con AppColors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedImage,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  items: locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc['image'],
                      child: Text(
                        loc['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selectedLoc = locations.firstWhere(
                      (loc) => loc['image'] == value,
                    );
                    setState(() {
                      _selectedImage = selectedLoc['image']!;
                      _selectedName = selectedLoc['name']!;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Título dinámico
          Text(
            _selectedName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Imagen panorámica con marco y sombra
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: PanoramaViewer(
                    child: Image.asset(
                      _selectedImage,
                      fit: BoxFit.cover,
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
}
