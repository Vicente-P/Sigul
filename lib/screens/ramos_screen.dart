import 'package:flutter/material.dart';
import '../models/asignatura.dart';
import '../services/asignatura_service.dart';
import '../core/app_colors.dart';
import 'asignatura_detail_screen.dart';

class RamosScreen extends StatefulWidget {
  const RamosScreen({super.key});

  @override
  State<RamosScreen> createState() => _RamosScreenState();
}

class _RamosScreenState extends State<RamosScreen> {
  final AsignaturaService _asignaturaService = AsignaturaService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _siglaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _siglaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoAgregarAsignatura() {
    _nombreController.clear();
    _siglaController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Agregar Asignatura',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la asignatura',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _siglaController,
                  decoration: InputDecoration(
                    labelText: 'Sigla (Ej: INF-343)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: _agregarAsignatura,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _agregarAsignatura() {
    String nombre = _nombreController.text.trim();
    String sigla = _siglaController.text.trim().toUpperCase();

    if (nombre.isEmpty) {
      _mostrarError('Por favor ingresa el nombre de la asignatura');
      return;
    }

    if (sigla.isEmpty) {
      _mostrarError('Por favor ingresa la sigla de la asignatura');
      return;
    }

    if (!Asignatura.isValidSigla(sigla)) {
      _mostrarError(
        'La sigla debe tener el formato: XXX-000 (3 letras, guión, 3 números)',
      );
      return;
    }

    if (_asignaturaService.existeSigla(sigla)) {
      _mostrarError('Ya existe una asignatura con esa sigla');
      return;
    }

    Asignatura nuevaAsignatura = Asignatura(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      sigla: sigla,
    );

    _asignaturaService.agregarAsignatura(nuevaAsignatura);
    Navigator.of(context).pop();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asignatura agregada correctamente'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _confirmarEliminarAsignatura(Asignatura asignatura) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro que deseas eliminar la asignatura "${asignatura.nombre}" (${asignatura.sigla})?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _asignaturaService.eliminarAsignatura(asignatura.id);
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Asignatura eliminada'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navegarADetalles(Asignatura asignatura) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignaturaDetailScreen(asignatura: asignatura),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _mostrarOpcionesAsignatura(Asignatura asignatura) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primary),
                title: Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  _navegarADetalles(asignatura);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.accent),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _navegarADetalles(asignatura);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar asignatura'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminarAsignatura(asignatura);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAsignaturaCard(Asignatura asignatura) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navegarADetalles(asignatura),
        onLongPress: () => _mostrarOpcionesAsignatura(asignatura),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asignatura.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        asignatura.sigla,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                    ),
                    if (asignatura.nombreProfesor != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Profesor: ${asignatura.nombreProfesor}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (asignatura.diaHoraClase != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Clase: ${asignatura.diaHoraClase}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (value) {
                  switch (value) {
                    case 'details':
                      _navegarADetalles(asignatura);
                      break;
                    case 'delete':
                      _confirmarEliminarAsignatura(asignatura);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Asignatura> asignaturas = _asignaturaService.asignaturas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mis Asignaturas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: asignaturas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: AppColors.divider,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay asignaturas registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca el botón + para agregar tu primera asignatura',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.divider,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Luego podrás tocar cada asignatura para ver y editar su información',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.divider,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Toca una asignatura para ver sus detalles',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: asignaturas.length,
                    itemBuilder: (context, index) {
                      return _buildAsignaturaCard(asignaturas[index]);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarAsignatura,
        backgroundColor: AppColors.accent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
