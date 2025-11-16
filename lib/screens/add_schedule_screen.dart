import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';
import '../models/schedule.dart';
import '../models/asignatura.dart';
import '../services/asignatura_service.dart';
import '../services/notification_service.dart';

class AddScheduleScreen extends StatefulWidget {
  final String? initialDay;
  final Schedule? existingSchedule;

  const AddScheduleScreen({super.key, this.initialDay, this.existingSchedule});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final AsignaturaService _asignaturaService = AsignaturaService();

  Asignatura? selectedAsignatura;
  String professor = '';
  String room = '';
  late String day;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String repetition = 'Cada semana';
  String note = '';

  bool get isEditing => widget.existingSchedule != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final s = widget.existingSchedule!;
      day = s.day;
      professor = s.professor;
      room = s.room;
      repetition = s.repetition;
      note = s.note;
      _startTime = _parseTime(s.startTime);
      _endTime = _parseTime(s.endTime);

      selectedAsignatura = _asignaturaService.asignaturas.firstWhere(
        (a) => a.nombre == s.subject,
        orElse: () => _asignaturaService.asignaturas.first,
      );
    } else {
      day = widget.initialDay ?? 'Lunes';
    }
  }

  // Parsea correctamente HH:mm o hh:mm a
  TimeOfDay _parseTime(String timeString) {
    timeString = timeString.trim();

    final hasAmPm =
        timeString.toUpperCase().contains('AM') ||
        timeString.toUpperCase().contains('PM');

    if (hasAmPm) {
      final period = timeString.toUpperCase().contains('PM') ? 'PM' : 'AM';
      final cleanTime = timeString.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } else {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  // Convierte TimeOfDay → "HH:mm" siempre en formato 24h
  String _formatTime24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  final List<String> days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final List<String> repetitions = [
    'Cada día',
    'Cada semana',
    'Cada mes',
    'Cada año',
  ];

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart
          ? 'Selecciona hora de inicio'
          : 'Selecciona hora de término',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asignaturas = _asignaturaService.asignaturas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Horario' : 'Agregar Horario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Asignatura>(
                isExpanded: true,
                value: selectedAsignatura,
                decoration: const InputDecoration(
                  labelText: 'Asignatura',
                  prefixIcon: Icon(Icons.book),
                ),
                items: asignaturas
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text('${a.sigla} - ${a.nombre}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedAsignatura = v;
                    professor = v?.nombreProfesor ?? '';
                  });
                },
                validator: (v) =>
                    v == null ? 'Selecciona una asignatura' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Profesor',
                  prefixIcon: Icon(Icons.person),
                ),
                controller: TextEditingController(text: professor),
                onChanged: (v) => professor = v,
                onSaved: (v) => professor = v ?? '',
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Aula',
                  prefixIcon: Icon(Icons.room),
                ),
                onSaved: (v) => room = v ?? '',
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: day,
                decoration: const InputDecoration(
                  labelText: 'Día',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => day = v!),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        _startTime == null
                            ? 'Hora inicio'
                            : 'Desde: ${_formatTime24h(_startTime!)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.timelapse),
                      title: Text(
                        _endTime == null
                            ? 'Hora término'
                            : 'Hasta: ${_formatTime24h(_endTime!)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: repetition,
                decoration: const InputDecoration(
                  labelText: 'Repetición',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: repetitions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => repetition = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nota adicional',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                onSaved: (v) => note = v ?? '',
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: Text(
                  isEditing ? 'Guardar cambios' : 'Guardar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (_startTime == null || _endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona horas válidas'),
                        ),
                      );
                      return;
                    }

                    // Validar que la hora de término sea posterior a la de inicio
                    final startMinutes =
                        _startTime!.hour * 60 + _startTime!.minute;
                    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

                    if (endMinutes <= startMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La hora de término debe ser posterior a la hora de inicio.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final int notificationId =
                        DateTime.now().millisecondsSinceEpoch % 2147483647;
                    if (isEditing) {
                      NotificationService.instance.cancelNotification(
                        widget.existingSchedule!.notificationId,
                      );
                    }

                    final newSchedule = Schedule(
                      notificationId: notificationId,
                      subject: selectedAsignatura?.nombre ?? '',
                      professor: professor,
                      room: room,
                      day: day,
                      startTime: _startTime != null
                          ? _formatTime24h(_startTime!)
                          : '08:00',
                      endTime: _endTime != null
                          ? _formatTime24h(_endTime!)
                          : '10:00',
                      repetition: repetition,
                      note: note,
                    );

                    if (_startTime != null) {
                      NotificationService.instance.scheduleWeeklyClassNotification(
                        id: notificationId,
                        title: '¡Clase a punto de empezar!',
                        body:
                            'Tu clase de ${newSchedule.subject} comienza en 10 minutos.',
                        dayName: newSchedule.day, // "Lunes", "Martes", etc.
                        classTime: _startTime!, // El TimeOfDay del inicio
                      );
                    }

                    Navigator.pop(context, newSchedule);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
