import 'package:flutter/material.dart';
import '../models/schedule.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String subject = '';
  String professor = '';
  String room = '';
  String day = 'Lunes';
  String startTime = '';
  String endTime = '';
  String repetition = 'Cada semana';
  String note = '';

  final List<String> days = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  final List<String> repetitions = [
    'Cada día', 'Cada semana', 'Cada mes', 'Cada año'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Horario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Asignatura'),
                onSaved: (v) => subject = v ?? '',
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Profesor'),
                onSaved: (v) => professor = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Aula'),
                onSaved: (v) => room = v ?? '',
              ),
              DropdownButtonFormField<String>(
                value: day,
                decoration: const InputDecoration(labelText: 'Día'),
                items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => day = v!),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Hora desde (ej: 08:00)'),
                      onSaved: (v) => startTime = v ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Hora hasta (ej: 10:00)'),
                      onSaved: (v) => endTime = v ?? '',
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: repetition,
                decoration: const InputDecoration(labelText: 'Repetición'),
                items: repetitions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => repetition = v!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nota adicional'),
                onSaved: (v) => note = v ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newSchedule = Schedule(
                      subject: subject,
                      professor: professor,
                      room: room,
                      day: day,
                      startTime: startTime,
                      endTime: endTime,
                      repetition: repetition,
                      note: note,
                    );
                    Navigator.pop(context, newSchedule);
                  }
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
