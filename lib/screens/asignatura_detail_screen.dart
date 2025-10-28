import 'package:flutter/material.dart';
import '../models/asignatura.dart';
import '../services/asignatura_service.dart';
import '../core/app_colors.dart';

class AsignaturaDetailScreen extends StatefulWidget {
  final Asignatura asignatura;

  const AsignaturaDetailScreen({
    super.key,
    required this.asignatura,
  });

  @override
  State<AsignaturaDetailScreen> createState() => _AsignaturaDetailScreenState();
}

class _AsignaturaDetailScreenState extends State<AsignaturaDetailScreen> {
  final AsignaturaService _asignaturaService = AsignaturaService();
  late Asignatura _currentAsignatura;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentAsignatura = widget.asignatura;
  }

  void _actualizarCampo(String campo, String? valor) {
    setState(() {
      _hasChanges = true;
      switch (campo) {
        case 'nombre':
          _currentAsignatura = _currentAsignatura.copyWith(nombre: valor);
          break;
        case 'sigla':
          _currentAsignatura = _currentAsignatura.copyWith(sigla: valor);
          break;
        case 'nombreProfesor':
          _currentAsignatura = _currentAsignatura.copyWith(nombreProfesor: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'diaHoraClase':
          _currentAsignatura = _currentAsignatura.copyWith(diaHoraClase: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'emailProfesor':
          _currentAsignatura = _currentAsignatura.copyWith(emailProfesor: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'horarioAtencionProfesor':
          _currentAsignatura = _currentAsignatura.copyWith(horarioAtencionProfesor: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'nombresAyudantes':
          _currentAsignatura = _currentAsignatura.copyWith(nombresAyudantes: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'diaHoraAyudantia':
          _currentAsignatura = _currentAsignatura.copyWith(diaHoraAyudantia: valor?.isEmpty ?? true ? null : valor);
          break;
        case 'emailAyudantes':
          _currentAsignatura = _currentAsignatura.copyWith(emailAyudantes: valor?.isEmpty ?? true ? null : valor);
          break;
      }
    });
  }

  void _guardarCambios() {
    _asignaturaService.actualizarAsignatura(_currentAsignatura);
    setState(() {
      _hasChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambios guardados correctamente'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context, true);
  }

  void _mostrarDialogoEdicion({
    required String titulo,
    required String campo,
    required String? valorActual,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool esRequerido = false,
  }) {
    final TextEditingController controller = TextEditingController(text: valorActual ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar $titulo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: titulo + (esRequerido ? ' *' : ''),
              hintText: hintText,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.divider),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String valor = controller.text.trim();
                
                // Validaciones específicas
                if (esRequerido && valor.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Este campo es requerido'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (campo == 'sigla' && valor.isNotEmpty && !Asignatura.isValidSigla(valor.toUpperCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La sigla debe tener el formato: XXX-000'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (campo == 'sigla' && valor.isNotEmpty && _asignaturaService.existeSigla(valor.toUpperCase(), excludeId: _currentAsignatura.id)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ya existe una asignatura con esa sigla'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                _actualizarCampo(campo, campo == 'sigla' ? valor.toUpperCase() : valor);
                controller.dispose();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField({
    required String titulo,
    required String campo,
    required String? valor,
    required IconData icono,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool esRequerido = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Icon(icono, color: AppColors.primary),
        title: Text(
          titulo + (esRequerido ? ' *' : ''),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: valor != null && valor.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  valor,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : Text(
                'No especificado',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.divider,
                ),
              ),
        trailing: Icon(Icons.edit, color: AppColors.accent),
        onTap: () => _mostrarDialogoEdicion(
          titulo: titulo,
          campo: campo,
          valorActual: valor,
          hintText: hintText,
          keyboardType: keyboardType,
          esRequerido: esRequerido,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Detalles de Asignatura',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _guardarCambios,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Información Básica', Icons.info_outline),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildEditableField(
                    titulo: 'Nombre de la asignatura',
                    campo: 'nombre',
                    valor: _currentAsignatura.nombre,
                    icono: Icons.school,
                    hintText: 'Ej: Programación Orientada a Objetos',
                    esRequerido: true,
                  ),
                  _buildEditableField(
                    titulo: 'Sigla',
                    campo: 'sigla',
                    valor: _currentAsignatura.sigla,
                    icono: Icons.tag,
                    hintText: 'Ej: INF-343',
                    esRequerido: true,
                  ),
                ],
              ),
            ),

            _buildSectionHeader('Información del Profesor', Icons.person),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildEditableField(
                    titulo: 'Nombre del profesor',
                    campo: 'nombreProfesor',
                    valor: _currentAsignatura.nombreProfesor,
                    icono: Icons.person_outline,
                    hintText: 'Ej: Dr. Juan Pérez',
                  ),
                  _buildEditableField(
                    titulo: 'Día y hora de clase',
                    campo: 'diaHoraClase',
                    valor: _currentAsignatura.diaHoraClase,
                    icono: Icons.schedule,
                    hintText: 'Ej: Lunes y Miércoles 10:00-11:30',
                  ),
                  _buildEditableField(
                    titulo: 'Email del profesor',
                    campo: 'emailProfesor',
                    valor: _currentAsignatura.emailProfesor,
                    icono: Icons.email,
                    hintText: 'Ej: profesor@universidad.cl',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildEditableField(
                    titulo: 'Horario de atención',
                    campo: 'horarioAtencionProfesor',
                    valor: _currentAsignatura.horarioAtencionProfesor,
                    icono: Icons.access_time,
                    hintText: 'Ej: Martes 14:00-16:00',
                  ),
                ],
              ),
            ),

            _buildSectionHeader('Información de Ayudantes', Icons.group),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildEditableField(
                    titulo: 'Nombres de ayudantes',
                    campo: 'nombresAyudantes',
                    valor: _currentAsignatura.nombresAyudantes,
                    icono: Icons.people_outline,
                    hintText: 'Ej: María García, Carlos López',
                  ),
                  _buildEditableField(
                    titulo: 'Día y hora de ayudantía',
                    campo: 'diaHoraAyudantia',
                    valor: _currentAsignatura.diaHoraAyudantia,
                    icono: Icons.schedule_outlined,
                    hintText: 'Ej: Viernes 15:00-16:30',
                  ),
                  _buildEditableField(
                    titulo: 'Email de ayudantes',
                    campo: 'emailAyudantes',
                    valor: _currentAsignatura.emailAyudantes,
                    icono: Icons.email_outlined,
                    hintText: 'Ej: ayudantes@universidad.cl',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _guardarCambios,
              backgroundColor: AppColors.primary,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}