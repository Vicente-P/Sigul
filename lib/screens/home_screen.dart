import 'package:flutter/material.dart';
import 'package:sigul/screens/calendar_screen.dart';
import 'package:sigul/screens/map_screen.dart';
import 'package:sigul/screens/panorama_screen.dart';
import 'package:sigul/screens/ramos_screen.dart';
import '../core/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary,
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
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        const Spacer(),
                        Container(
                          height: 65,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'SIGUL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'Busca un edificio/sala...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                          hintText: 'Search...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTabButton('Mapa', isSelected: true),
                      const SizedBox(width: 20),
                      _buildTabButton('Horarios', isSelected: false),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Mapa',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CampusMapScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/mapa.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.lightPrimary,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map, size: 50, color: AppColors.darkPrimary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mapa del Campus',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkPrimary,
                                    ),
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

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Lugares recurrentes',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildBuildingButtonWithImage(
                          'Edificio A',
                          '4 pisos',
                          'assets/images/edificio_a.jpg',
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: _buildBuildingButtonWithImage(
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
    );
  }

  // Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.darkPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 55,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'SIGUL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sistema Integrado de Gestión',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  'Universitaria de listados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.map, 'Mapa', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CampusMapScreen()),
            );
          }),
          _buildDrawerItem(Icons.calendar_today, 'Horarios', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }),
          _buildDrawerItem(Icons.book, 'Asignaturas', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RamosScreen()),
            );
          }),
          _buildDrawerItem(Icons.apartment, 'Edificios', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PanoramaScreen()),
            );
          }),
          _buildDrawerItem(
            Icons.info,
            'Acerca de',
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkPrimary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildTabButton(String text, {bool isSelected = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (text == 'Mapa') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CampusMapScreen()),
            );
          } else if (text == 'Horarios') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPrimary : AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuildingButtonWithImage(
    String title,
    String description,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PanoramaScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPrimary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
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
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
