import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mbtiles/mbtiles.dart';
import 'dart:io';

// --- Paquetes para GraphHopper ---
import 'package:http/http.dart' as http; // Para la API
import 'dart:convert'; // Para decodificar el JSON
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Para la ruta

// Asumo que este archivo existe en tu proyecto
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/screens/panorama_screen.dart';

// --- 1. Modelo de datos para los edificios ---
class Building {
  final String name;
  final LatLng coordinates;
  final String imagePath;

  Building({
    required this.name,
    required this.coordinates,
    required this.imagePath,
  });
}

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  _CampusMapScreenState createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  MbTilesTileProvider? tileProvider;
  bool isLoading = true;
  late BuildContext scaffoldContext;
  final MapController _mapController = MapController();

  // --- Lista centralizada de edificios ---
  final List<Building> allBuildings = [
    Building(
      name: "Edificio C",
      coordinates: LatLng(-33.036052, -71.594652),
      imagePath: 'assets/images/edificio_c.webp',
    ),
    Building(
      name: "Biblioteca Central",
      coordinates: LatLng(-33.034915, -71.595057),
      imagePath: 'assets/images/panorama05.webp',
    ),
    Building(
      name: "Edificio P",
      coordinates: LatLng(-33.036638, -71.594279),
      imagePath: 'assets/images/edificio_p_entrada.webp',
    ),
    Building(
      name: "Edificio M",
      coordinates: LatLng(-33.034918, -71.593000),
      imagePath: 'assets/images/panorama07.webp',
    ),
    Building(
      name: "Edificio F",
      coordinates: LatLng(-33.034778, -71.596696),
      imagePath: 'assets/images/entrada_edificio_f2_f3.webp',
    ),
    Building(
      name: "Edificio A",
      coordinates: LatLng(-33.034846, -71.595537),
      imagePath: 'assets/images/panorama09.webp',
    ),
    Building(
      name: "Edificio B",
      coordinates: LatLng(-33.035400, -71.595258),
      imagePath: 'assets/images/piscina_edificio_b.webp',
    ),
    Building(
      name: "Edificio R",
      coordinates: LatLng(-33.035737, -71.593046),
      imagePath: 'assets/images/panorama03.webp',
    ),
    
  ];

  // --- variables de estado para Rutas ---

  Building? _startBuilding;
  Building? _endBuilding;

  List<LatLng> _routePoints = [];
  List<String> _routeInstructions = [];
  bool _isFetchingRoute = false;

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
    _mapController.dispose();
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PanoramaScreen(
                      initialBuilding: name,
                    ),
                  ),
                );
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

  void _clearStartBuilding() {
    setState(() {
      _startBuilding = null;
    });
  }

  void _clearEndBuilding() {
    setState(() {
      _endBuilding = null;
    });
  }

  void _clearRoute() {
    // Usamos setState para que la UI se actualice
    setState(() {
      _startBuilding = null;
      _endBuilding = null;
      _routePoints = [];
      _routeInstructions = [];
    });
  }

  // --- Función para obtener ruta con GRAPH HOPPER ---
  Future<void> _getRoute() async {
    if (_startBuilding == null || _endBuilding == null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona inicio y destino.')),
      );
      return;
    }

    setState(() {
      _isFetchingRoute = true;
      _routePoints = [];
      _routeInstructions = [];
    });

    // ! PON TU API KEY DE GRAPH HOPPER AQUÍ
    const String graphHopperApiKey = '92fabb48-b419-429c-ac98-9f3f6a0bdecf';

    // Coordenadas de inicio y fin
    final start = _startBuilding!.coordinates;
    final end = _endBuilding!.coordinates;

    // Construir la URL de la API de GraphHopper
    final String url =
        'https://graphhopper.com/api/1/route'
        '?point=${start.latitude},${start.longitude}'
        '&point=${end.latitude},${end.longitude}'
        '&profile=foot' // Perfil de peatón (usa 'foot', no 'foot-walking')
        '&instructions=true' // Pedimos las instrucciones
        '&points_encoded=true' // Pedimos la polilínea codificada
        '&locale=es' // Instrucciones en español
        '&key=$graphHopperApiKey';

    try {
      // 1. Hacer la llamada HTTP
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);

        // 2. Extraer la polilínea codificada
        // La respuesta de GH tiene una lista de "paths", usamos el primero [0]
        final String encodedPolyline = jsonBody['paths'][0]['points'];

        // 3. Decodificar la polilínea
        final List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
          encodedPolyline,
        );

        // Convertir de List<PointLatLng> a List<LatLng>
        final List<LatLng> points = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // 4. Extraer las instrucciones
        final List instructionsData = jsonBody['paths'][0]['instructions'];
        final List<String> instructions = instructionsData
            .map((item) => item['text'] as String)
            .toList();

        setState(() {
          _routePoints = points;
          _routeInstructions = instructions;
        });

        // Mover el mapa para que se vea la ruta completa
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_routePoints),
            padding: EdgeInsets.all(50.0),
          ),
        );
      } else {
        // Si la API falla (ej. clave incorrecta, sin ruta)
        debugPrint('Error de GraphHopper: ${response.body}');
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Error al obtener la ruta desde GraphHopper.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error en la llamada de red: $e');
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Error de conexión al buscar la ruta.')),
      );
    } finally {
      setState(() => _isFetchingRoute = false); // Ocultar carga
    }
  }

  // --- 5. Método Build Modificado ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus UTFSM'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        centerTitle: true,
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

          // --- Usamos un Stack para superponer el Panel ---
          return Stack(
            children: [
              // --- EL MAPA ---
              FlutterMap(
                mapController: _mapController,
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
                  ColoredBox(color: AppColors.textSecondary),
                  TileLayer(tileProvider: tileProvider!),

                  // --- Capa de la RUTA (Polilínea) ---
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blueAccent,
                        strokeWidth: 5,
                      ),
                    ],
                  ),

                  // --- Capa de MARCADORES (Inicio y Fin) ---
                  MarkerLayer(
                    markers: [
                      // Marcador de INICIO
                      if (_startBuilding != null)
                        Marker(
                          point: _startBuilding!.coordinates,
                          child: GestureDetector(
                            onTap: () => _showBuildingInfo(
                              _startBuilding!.name,
                              _startBuilding!.imagePath,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.green, // Color para inicio
                              size: 40,
                            ),
                          ),
                        ),
                      // Marcador de FIN
                      if (_endBuilding != null)
                        Marker(
                          point: _endBuilding!.coordinates,
                          child: GestureDetector(
                            onTap: () => _showBuildingInfo(
                              _endBuilding!.name,
                              _endBuilding!.imagePath,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red, // Color para fin
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // --- Panel de Selección (Inicio, Destino, Botón) ---
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dropdown de INICIO con botón de limpiar
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Building>(
                                value: _startBuilding,
                                isExpanded: true,
                                hint: Text("Selecciona punto de inicio..."),
                                items: allBuildings
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _startBuilding = val),
                                dropdownColor: AppColors.background,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Botón para limpiar INICIO
                          if (_startBuilding != null)
                            IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              tooltip: 'Limpiar inicio',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.lightAccent,
                                foregroundColor: AppColors.accent,
                                fixedSize: Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: _clearStartBuilding,
                            ),
                        ],
                      ),

                      Divider(height: 1, color: AppColors.textSecondary),

                      // Dropdown de DESTINO con botón de limpiar
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Building>(
                                value: _endBuilding,
                                isExpanded: true,
                                hint: Text("Selecciona punto de destino..."),
                                items: allBuildings
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _endBuilding = val),
                                dropdownColor: AppColors.background,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Botón para limpiar DESTINO
                          if (_endBuilding != null)
                            IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              tooltip: 'Limpiar destino',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.lightAccent,
                                foregroundColor: AppColors.accent,
                                fixedSize: Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: _clearEndBuilding,
                            ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Botón para BUSCAR RUTA
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: _isFetchingRoute
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.route, size: 20),
                              label: Text(
                                _isFetchingRoute
                                    ? 'Buscando...'
                                    : 'Obtener Ruta',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.background,
                                minimumSize: Size(double.infinity, 44),
                              ),
                              onPressed: _isFetchingRoute ? null : _getRoute,
                            ),
                          ),
                          SizedBox(width: 10),
                          // --- BOTÓN DE LIMPIAR TODO ---
                          IconButton(
                            icon: Icon(Icons.clear_all),
                            tooltip: 'Limpiar todo',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.lightAccent,
                              foregroundColor: AppColors.accent,
                              fixedSize: Size(44, 44),
                            ),
                            onPressed: _clearRoute,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- Panel deslizable de INSTRUCCIONES ---
              if (_routeInstructions.isNotEmpty)
                DraggableScrollableSheet(
                  initialChildSize: 0.15,
                  minChildSize: 0.1,
                  maxChildSize: 0.5,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _routeInstructions.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Column(
                                children: [
                                  // "Handle" para deslizar
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Instrucciones",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListTile(
                            leading: Text(
                              "$index.",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(_routeInstructions[index - 1]),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}