import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';

class BuildingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> building;

  const BuildingDetailScreen({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(building['name']),
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                building['image'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.business, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              building['description'],
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.layers, color: AppColors.darkPrimary),
                title: const Text(
                  'Pisos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${building['floors']}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: AppColors.darkPrimary,
                ),
                title: const Text(
                  'Horario',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('08:00 - 20:00 (aprox.)'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi, color: AppColors.darkPrimary),
                title: const Text(
                  'Servicios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('WiFi, Aire acondicionado, Ascensores'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
