import 'package:flutter/material.dart';
import 'package:sigul/screens/calendar_screen.dart';
import 'package:sigul/screens/map_screen.dart';
import 'package:sigul/screens/panorama_screen.dart';
import 'package:sigul/screens/ramos_screen.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/models/building_model.dart';
import 'building_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  List<String> _sugerenciasSalas = [];
  bool _mostrarSugerencias = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toUpperCase();
    
    if (query.isEmpty) {
      setState(() {
        _mostrarSugerencias = false;
        _sugerenciasSalas = [];
      });
      return;
    }

    final edificios = BuildingData.getAllBuildings();
    List<String> sugerencias = [];
    
    for (var edificio in edificios) {
      final nombreEdificio = edificio.name.toUpperCase();
      if (nombreEdificio.contains(query) || 
          query.contains(nombreEdificio.replaceAll('EDIFICIO ', ''))) {
        sugerencias.add(edificio.name);
      }
    }
    
    List<String> todasLasSalas = [];
    for (var edificio in edificios) {
      todasLasSalas.addAll(edificio.salas);
    }
    
    final salasCoincidentes = todasLasSalas
        .where((sala) => sala.toUpperCase().contains(query))
        .toList();
    
    sugerencias.addAll(salasCoincidentes);
    sugerencias = sugerencias.take(10).toList();

    setState(() {
      _sugerenciasSalas = sugerencias;
      _mostrarSugerencias = sugerencias.isNotEmpty;
    });
  }

  void _navegarASala(String seleccion) {
    final edificios = BuildingData.getAllBuildings();
    var edificioEncontrado = edificios.firstWhere(
      (e) => e.name == seleccion,
      orElse: () => Building(
        name: '',
        description: '',
        image: '',
        pointsOfInterest: [],
        salas: [],
      ),
    );
    
    if (edificioEncontrado.name.isNotEmpty) {
      setState(() {
        _mostrarSugerencias = false;
        _searchController.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaScreen(
            initialBuilding: edificioEncontrado.name,
            showDetailsInitially: true,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mostrando detalles de ${edificioEncontrado.name}'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final edificio = BuildingData.buscarEdificioPorSala(seleccion);
    
    if (edificio != null) {
      setState(() {
        _mostrarSugerencias = false;
        _searchController.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanoramaScreen(
            initialBuilding: edificio.name,
            showDetailsInitially: true,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sala $seleccion encontrada en ${edificio.name}'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontró: $seleccion'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              _navigateToScreen(index, context);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white, 
            selectedIconTheme: IconThemeData(color: AppColors.darkPrimary), 
            selectedLabelTextStyle: TextStyle(color: AppColors.darkPrimary), 
            unselectedIconTheme: IconThemeData(color: AppColors.textSecondary), 
            unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondary), 
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: Text('Mapa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Horarios'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: Text('Asignaturas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment),
                label: Text('Edificios'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Center(
                            child: Container(
                              height: 65,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'SIGUL',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.only(left: 24.0, top: 8.0),
                          child: Text(
                            'Busca un edificio/sala...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                                    hintText: 'Buscar edificio o sala (ej: Edificio P, P201)...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear, color: Colors.grey),
                                            onPressed: () {
                                              _searchController.clear();
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              
                              if (_mostrarSugerencias && _sugerenciasSalas.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(maxHeight: 200),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    itemCount: _sugerenciasSalas.length,
                                    separatorBuilder: (context, index) => Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final sala = _sugerenciasSalas[index];
                                      final edificio = BuildingData.buscarEdificioPorSala(sala);
                                      
                                      return ListTile(
                                        leading: Icon(
                                          Icons.meeting_room,
                                          color: AppColors.primary,
                                        ),
                                        title: Text(
                                          sala,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          edificio?.name ?? 'Edificio desconocido',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        onTap: () => _navegarASala(sala),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mapa del Campus',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CampusMapScreen()),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColors.lightPrimary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/mapa.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.lightPrimary,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.map, size: 60, color: AppColors.primary),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Mapa del Campus',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        FilledButton.tonal(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const CampusMapScreen()),
                                            );
                                          },
                                          child: const Text('Ver mapa completo'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Lugares recurrentes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildBuildingCardM3(
                                'Edificio C',
                                '2 pisos',
                                'assets/images/edificio_c.jpg',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildBuildingCardM3(
                                'Edificio P',
                                '4 pisos',
                                'assets/images/edificio_p.png',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CampusMapScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RamosScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PanoramaScreen()));
        break;
    }
  }

  Widget _buildBuildingCardM3(
    String title,
    String description,
    String imagePath,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PanoramaScreen(initialBuilding: title), 
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14, 
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}