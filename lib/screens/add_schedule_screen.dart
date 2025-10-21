import 'package:flutter/material.dart';
import 'package:sigul/core/app_colors.dart';
import '../models/schedule.dart';

class AddScheduleScreen extends StatefulWidget {
  final String? initialDay;

  const AddScheduleScreen({super.key, this.initialDay});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String subject = '';
  String professor = '';
  String room = '';
  late String day;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String repetition = 'Cada semana';
  String note = '';

  @override
  void initState() {
    super.initState();
    day = widget.initialDay ?? 'Lunes';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agregar Horario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Asignatura',
                  prefixIcon: Icon(Icons.book),
                ),
                onSaved: (v) => subject = v ?? '',
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Profesor',
                  prefixIcon: Icon(Icons.person),
                ),
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
                            : 'Desde: ${_startTime!.format(context)}',
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
                            : 'Hasta: ${_endTime!.format(context)}',
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
                label: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newSchedule = Schedule(
                      subject: subject,
                      professor: professor,
                      room: room,
                      day: day,
                      startTime: _startTime?.format(context) ?? '08:00',
                      endTime: _endTime?.format(context) ?? '10:00',
                      repetition: repetition,
                      note: note,
                    );

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
