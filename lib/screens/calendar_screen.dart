import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';
import 'add_schedule_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Schedule> schedules = [];

  final List<String> daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  String selectedDay = 'Lunes';

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  // 🔹 Cargar horarios guardados desde SharedPreferences
  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('schedules');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        schedules = decoded.map((e) => Schedule.fromJson(e)).toList();
      });
    }
  }

  // 🔹 Guardar horarios actualizados
  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      schedules.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('schedules', encoded);
  }

  // 🔹 Agregar nuevo horario
  Future<void> _addNewSchedule() async {
    final newSchedule = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddScheduleScreen()),
    );

    if (newSchedule != null && newSchedule is Schedule) {
      setState(() {
        schedules.add(newSchedule);
      });
      await _saveSchedules();
    }
  }

  // 🔹 Eliminar horario (opcional)
  Future<void> _deleteSchedule(int index) async {
    setState(() {
      schedules.removeAt(index);
    });
    await _saveSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = schedules
        .where((s) => s.day == selectedDay)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario Universitario'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Selector de días
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                final isSelected = day == selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => selectedDay = day),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de clases
          Expanded(
            child: filteredSchedules.isEmpty
                ? const Center(child: Text('No hay clases programadas.'))
                : ListView.builder(
                    itemCount: filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = filteredSchedules[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteSchedule(index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${schedule.startTime} - ${schedule.endTime}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                schedule.subject,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(schedule.professor),
                              Text('Aula: ${schedule.room}'),
                              if (schedule.note.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('📝 ${schedule.note}'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}
