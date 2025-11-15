import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/models/building_model.dart';
import 'package:sigul/screens/building_data.dart';

class PanoramaScreen extends StatefulWidget {
  final String? initialBuilding;
  const PanoramaScreen({super.key, this.initialBuilding});

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen> {
  final List<Map<String, String>> locations = [
    {'name': 'Entrada Ingeniería', 'image': 'assets/images/panorama01.webp'},
    {'name': 'Piscina', 'image': 'assets/images/panorama_piscina.webp'},
    {'name': 'Edificio A', 'image': 'assets/images/panorama03.webp'},
    {'name': 'Edificio B', 'image': 'assets/images/panorama04.webp'},
    {'name': 'Edificio C', 'image': 'assets/images/panorama_c.webp'},
    {'name': 'Patio los Ceibos', 'image': 'assets/images/panorama_patio.webp'},
    {'name': 'Edificio F', 'image': 'assets/images/panorama_f.webp'},
    {'name': 'Biblioteca Central', 'image': 'assets/images/panorama08.webp'},
    {'name': 'Edificio P', 'image': 'assets/images/panorama_p.webp'},
    {'name': 'Gimnasio', 'image': 'assets/images/panorama10.webp'},
  ];

  late String _selectedImage;
  late String _selectedName;
  bool _showBuildingDetails = false;

  @override
  void initState() {
    super.initState();
    
    // Si viene un edificio específico, seleccionarlo
    if (widget.initialBuilding != null) {
      final selectedLoc = locations.firstWhere(
        (loc) => loc['name'] == widget.initialBuilding,
        orElse: () => locations[0],
      );
      _selectedImage = selectedLoc['image']!;
      _selectedName = selectedLoc['name']!;
    } else {
      // Comportamiento normal
      _selectedImage = locations[0]['image']!;
      _selectedName = locations[0]['name']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _showBuildingDetails ? 'Detalles del Edificio' : 'Recorrido Virtual 360°',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 4,
        actions: _showBuildingDetails 
            ? [
                // Botón para volver en modo detalles
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showBuildingDetails = false;
                    });
                  },
                ),
              ]
            : [
                // Botón para detalles en modo panorama
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showBuildingDetails = true;
                    });
                  },
                ),
              ],
      ),
      body: _showBuildingDetails 
          ? _buildBuildingDetails()
          : _buildPanoramaView(),
    );
  }

  // VISTA PANORAMA 360° 
  Widget _buildPanoramaView() {
    return Column(
      children: [
        const SizedBox(height: 12),

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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
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
                dropdownColor: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                items: locations.map((loc) {
                  return DropdownMenuItem<String>(
                    value: loc['image'],
                    child: Text(
                      loc['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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

        Text(
          _selectedName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
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
    );
  }

  // DETALLES DEL EDIFICIO
  Widget _buildBuildingDetails() {
    final building = BuildingData.getBuildingData(_selectedName);
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con imagen y nombre
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.asset(
                          building.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: AppColors.lightPrimary,
                            child: Icon(
                              Icons.business,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              building.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              building.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                
                if (building.pointsOfInterest.isNotEmpty) ...[
                  Text(
                    'Lugares de Interés',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de puntos de interés
                  ...building.pointsOfInterest.map((poi) => _buildPOICard(poi, context)),
                ],
              ],
            ),
          ),
        ),

        // Botón para volver al panorama
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.tonalIcon(
            onPressed: () {
              setState(() {
                _showBuildingDetails = false;
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al Panorama 360°'),
          ),
        ),
      ],
    );
  }

  // Widget para cada punto de interés
  Widget _buildPOICard(PointOfInterest poi, BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del POI 
            GestureDetector(
              onTap: () => _showImageDialog(context, poi),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.lightPrimary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    poi.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.place,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del POI
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    poi.floor,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    poi.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  







  
  //Dialog M3 para imagen ampliada
  void _showImageDialog(BuildContext context, PointOfInterest poi) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con nombre
            Card(
              color: AppColors.background,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.place, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        poi.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
            // Imagen ampliada
            GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Cerrar al tocar la imagen
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.black,
                  child: Image.asset(
                    poi.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.lightPrimary,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 60, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Imagen no disponible',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
