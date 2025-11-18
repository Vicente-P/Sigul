import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sigul/core/app_colors.dart';
import 'package:sigul/services/notification_service.dart';
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

  String _formatTimeTo12h(String time24h) {
    try {
      final parts = time24h.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      final hourStr = hour.toString().padLeft(2, '0');
      final minuteStr = minute.toString().padLeft(2, '0');

      return '$hourStr:$minuteStr $period';
    } catch (_) {
      return time24h;
    }
  }

  void _generateCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
    weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    selectedDate = now;
  }

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

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      schedules.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('schedules', encoded);
  }

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

  Future<void> _editSchedule(Schedule schedule, int index) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddScheduleScreen(existingSchedule: schedule),
      ),
    );

    if (updated != null && updated is Schedule) {
      setState(() {
        schedules[index] = updated;
      });
      await _saveSchedules();
    }
  }

  Future<void> _deleteSchedule(int index) async {
    final int notificationId = schedules[index].notificationId;
    setState(() {
      schedules.removeAt(index);
    });
    await _saveSchedules();

    NotificationService.instance.cancelNotification(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDayName = DateFormat(
      'EEEE',
      'es_ES',
    ).format(selectedDate);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Semana actual',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday ? AppColors.accent : AppColors.divider,
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'es_CL').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('d', 'es_CL').format(date),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'es_CL').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
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

          Expanded(
            child: filteredSchedules.isEmpty
                ? const Center(child: Text('No hay clases programadas.'))
                : ListView.builder(
                    itemCount: filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = filteredSchedules[index];
                      final scheduleIndex = schedules.indexOf(schedule);

                      return GestureDetector(
                        onTap: () => _editSchedule(schedule, scheduleIndex),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppColors.error,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _deleteSchedule(scheduleIndex),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.lightPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
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
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_formatTimeTo12h(schedule.startTime)} - ${_formatTimeTo12h(schedule.endTime)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.menu_book,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        schedule.subject,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      schedule.professor,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.meeting_room,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      schedule.room,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
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
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          schedule.note,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
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
