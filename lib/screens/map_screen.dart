import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mbtiles/mbtiles.dart';
import 'dart:io';

import 'package:sigul/core/app_colors.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  _CampusMapScreenState createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  MbTilesTileProvider? tileProvider;
  bool isLoading = true;
  late BuildContext scaffoldContext;

  @override
  void initState() {
    super.initState();
    _initTileProvider();
  }

  Future<void> _initTileProvider() async {
    // se obtiene el mbtiles para el mapa
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/mapa_zona2.mbtiles';
      final file = File(path);

      if (!await file.exists()) {
        debugPrint('Copiando MBTiles...');
        final byteData = await rootBundle.load(
          'assets/tiles/mapa_zona2.mbtiles',
        );
        await file.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
        debugPrint('Copia completada');
      }

      final mbtiles = MBTiles(mbtilesPath: path);
      tileProvider = MbTilesTileProvider(mbtiles: mbtiles);
    } catch (e) {
      debugPrint('Error inicializando MBTiles: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    tileProvider?.dispose();
    super.dispose();
  }

  // esto es para mostrar la info del edificio
  void _showBuildingInfo(String name, String imagePath) {
    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: AppColors.textPrimary, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            ClipRRect(
              child: Image.asset(
                imagePath,
                width: 300,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 300,
                  height: 160,
                  color: AppColors.textSecondary,
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  scaffoldContext,
                ).showSnackBar(SnackBar(content: Text("Detalles de $name")));
              },
              icon: Icon(Icons.info_outline, size: 18),
              label: Text("Ver más detalles"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus UTFSM'),
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.background,
      ),
      body: Builder(
        builder: (BuildContext innerContext) {
          scaffoldContext = innerContext;

          if (isLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Cargando mapa..."),
                ],
              ),
            );
          }

          if (tileProvider == null) {
            return Center(child: Text('Error al cargar el mapa.'));
          }

          // se muestra el mapa
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-33.035866, -71.594947),
              initialZoom: 17.0,
              minZoom: 15.0,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  LatLng(-33.039466, -71.599387),
                  LatLng(-33.032266, -71.590507),
                ),
              ),
            ),
            children: [
              ColoredBox(color: AppColors.textSecondary!),
              TileLayer(tileProvider: tileProvider!),

              // marcadores
              MarkerLayer(
                markers: [
                  //edifico c
                  Marker(
                    point: LatLng(-33.036052, -71.594652),
                    width: 32,
                    height: 32,
                    child: GestureDetector(
                      onTap: () {
                        _showBuildingInfo(
                          "Edificio C",
                          'assets/images/edificio_c.webp',
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  // edificio biblioteca
                  Marker(
                    point: LatLng(-33.034915, -71.595057),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Biblioteca Central",
                        'assets/images/panorama05.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  // edificio P
                  Marker(
                    point: LatLng(-33.036638, -71.594279),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio P",
                        'assets/images/edificio_p_entrada.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  //edificio M
                  Marker(
                    point: LatLng(-33.034918, -71.593000),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio M",
                        'assets/images/panorama07.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  //Edificio F
                  Marker(
                    point: LatLng(-33.034778, -71.596696),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio F",
                        'assets/images/entrada_edificio_f2_f3.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  //edificio A
                  Marker(
                    point: LatLng(-33.034846, -71.595537),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio A",
                        'assets/images/panorama09.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  //Edificio B
                  Marker(
                    point: LatLng(-33.035400, -71.595258),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio B",
                        'assets/images/piscina_edificio_b.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  //Edificio R
                  Marker(
                    point: LatLng(-33.035737, -71.593046),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBuildingInfo(
                        "Edificio R",
                        'assets/images/panorama03.webp',
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                        shadows: [
                          Shadow(color: AppColors.textPrimary, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
