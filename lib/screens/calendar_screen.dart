import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sigul/core/app_colors.dart';
import '../models/schedule.dart';
import 'add_schedule_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Schedule> schedules = [];
  late DateTime selectedDate; 
  late List<DateTime> weekDates; 

  String selectedDay = 'Lunes';

  @override
  void initState() {
    super.initState();
    _generateCurrentWeek();
    _loadSchedules();
  }

  // 🔹 Genera los días de la semana actual (lunes a domingo)
  void _generateCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // 1=lunes, 7=domingo
    DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
    weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    selectedDate = now; // Día actual seleccionado por defecto
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
    final String selectedDayName = DateFormat('EEEE', 'es_CL')
        .format(selectedDate)
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase());

    final newSchedule = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddScheduleScreen(
          initialDay: selectedDayName,
        ),
      ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Día seleccionado como texto (ej: "Lunes")
    final String selectedDayName = DateFormat(
      'EEEE',
      'es_ES',
    ).format(selectedDate);
    // Filtrar horarios del día seleccionado
    final filteredSchedules = schedules
        .where((s) => s.day.toLowerCase() == selectedDayName.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Horario Universitario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 🔹 Título "Hoy" o fecha actual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Semana actual',
                style:
                    Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 🔹 Selector de días con fechas
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                final date = weekDates[index];
                final isSelected =
                    DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(selectedDate);
                final isToday =
                    DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.accent
                            : Colors.grey.shade400,
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'es_CL').format(date), // Thu, Fri...
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          DateFormat('d', 'es_CL').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'es_CL').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Lista de clases del día
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
                            vertical: 8,
                            horizontal: 8,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary, // Color de fondo
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withValues(
                                alpha: 0.4,
                              ), // 👈 contorno suave
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${schedule.startTime} - ${schedule.endTime}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      schedule.subject,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    schedule.professor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.meeting_room,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    schedule.room,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              if (schedule.note.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.note_alt,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        schedule.note,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
