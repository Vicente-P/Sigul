import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/asignatura.dart';
import '../models/evaluacion.dart';
import '../services/asignatura_service.dart';
import '../core/app_colors.dart';

class NotasScreen extends StatefulWidget {
  final Asignatura asignatura;

  const NotasScreen({super.key, required this.asignatura});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final AsignaturaService _asignaturaService = AsignaturaService();
  late Asignatura _currentAsignatura;

  @override
  void initState() {
    super.initState();
    _currentAsignatura = widget.asignatura;
  }

  void _mostrarDialogoAgregarNota() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController calificacionController =
        TextEditingController();
    final TextEditingController ponderacionController = TextEditingController();
    String tipoSeleccionado = 'Certamen';
    DateTime? fechaSeleccionada;

    final List<String> tiposEvaluacion = [
      'Certamen',
      'Control',
      'Proyecto',
      'Tarea',
      'Laboratorio',
      'Prueba',
      'Examen',
      'Trabajo',
      'Otro',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Agregar Evaluación',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo de evaluación',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(
                          Icons.category,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: tiposEvaluacion.map((String tipo) {
                        return DropdownMenuItem(value: tipo, child: Text(tipo));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() => tipoSeleccionado = value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre (opcional)',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Ej: Certamen 1, Control 2',
                        prefixIcon: Icon(Icons.edit, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: calificacionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calificación (0-100) *',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Ej: 85',
                        prefixIcon: Icon(Icons.grade, color: AppColors.primary),
                        suffixText: 'pts',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: ponderacionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ponderación (opcional)',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Ej: 30',
                        prefixIcon: Icon(
                          Icons.percent,
                          color: AppColors.primary,
                        ),
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        fechaSeleccionada == null
                            ? 'Fecha (opcional)'
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).format(fechaSeleccionada!),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (fecha != null) {
                          setStateDialog(() => fechaSeleccionada = fecha);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.divider),
                      ),
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
                  onPressed: () {
                    _agregarNota(
                      tipoSeleccionado,
                      nombreController.text.trim(),
                      calificacionController.text.trim(),
                      ponderacionController.text.trim(),
                      fechaSeleccionada,
                    );
                    Navigator.of(context).pop();
                  },
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
      },
    );
  }

  void _agregarNota(
    String tipo,
    String nombre,
    String calificacionStr,
    String ponderacionStr,
    DateTime? fecha,
  ) async {
    if (calificacionStr.isEmpty) {
      _mostrarError('Por favor ingresa la calificación');
      return;
    }

    double? calificacion = double.tryParse(calificacionStr);
    if (calificacion == null || !Evaluacion.isValidCalificacion(calificacion)) {
      _mostrarError('La calificación debe ser un número entre 0 y 100');
      return;
    }

    double? ponderacion;
    if (ponderacionStr.isNotEmpty) {
      ponderacion = double.tryParse(ponderacionStr);
      if (ponderacion == null || !Evaluacion.isValidPonderacion(ponderacion)) {
        _mostrarError('La ponderación debe ser un número entre 1 y 100');
        return;
      }
    }

    Evaluacion nuevaEvaluacion = Evaluacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: tipo,
      calificacion: calificacion,
      ponderacion: ponderacion,
      nombre: nombre.isEmpty ? null : nombre,
      fecha: fecha,
    );

    List<Evaluacion> evaluacionesActualizadas = List.from(
      _currentAsignatura.evaluaciones,
    )..add(nuevaEvaluacion);

    _currentAsignatura = _currentAsignatura.copyWith(
      evaluaciones: evaluacionesActualizadas,
    );

    await _asignaturaService.actualizarAsignatura(_currentAsignatura);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evaluación agregada correctamente'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _eliminarNota(String evaluacionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro que deseas eliminar esta evaluación?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Evaluacion> evaluacionesActualizadas = _currentAsignatura
                    .evaluaciones
                    .where((e) => e.id != evaluacionId)
                    .toList();

                _currentAsignatura = _currentAsignatura.copyWith(
                  evaluaciones: evaluacionesActualizadas,
                );

                await _asignaturaService.actualizarAsignatura(
                  _currentAsignatura,
                );

                setState(() {});

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Evaluación eliminada'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
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

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Color _getColorCalificacion(double calificacion) {
    if (calificacion >= 90) return Colors.green;
    if (calificacion >= 70) return Colors.blue;
    if (calificacion >= 50) return Colors.orange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final promedio = _currentAsignatura.promedioNotas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _currentAsignatura.nombre,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentAsignatura.sigla,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (promedio != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getColorCalificacion(promedio),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message:
                              'Promedio ponderado:\nSuma de (calificación × ponderación) / Suma de ponderaciones\nSi no hay ponderaciones, se calcula el promedio simple.',
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: _getColorCalificacion(promedio),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Promedio: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          promedio.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getColorCalificacion(promedio),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: _currentAsignatura.evaluaciones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: AppColors.divider,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay evaluaciones registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca el botón + para agregar una evaluación',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.divider,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _currentAsignatura.evaluaciones.length,
                    itemBuilder: (context, index) {
                      final evaluacion = _currentAsignatura.evaluaciones[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getColorCalificacion(
                              evaluacion.calificacion,
                            ),
                            child: Text(
                              evaluacion.calificacion.toStringAsFixed(0),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  evaluacion.nombre ?? evaluacion.tipo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (evaluacion.ponderacion != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${evaluacion.ponderacion!.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              if (evaluacion.nombre != null)
                                Text(
                                  evaluacion.tipo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (evaluacion.fecha != null)
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(evaluacion.fecha!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: AppColors.error),
                            onPressed: () => _eliminarNota(evaluacion.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarNota,
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
