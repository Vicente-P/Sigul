import 'dart:developer' as developer;
import 'package:flutter/material.dart'; // Necesario para TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal(); // Constructor privado
  static final NotificationService instance =
      NotificationService._internal(); // Instancia única

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logo');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            // Aquí puedes manejar el 'tap' en la notificación si lo necesitas
          },
    );
  }

  // --- Permisos (Importante para Android 13+) ---
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // --- Detalles de la notificación (Canal) ---
  static const NotificationDetails _platformDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'class_channel_id', // ID del canal
      'Recordatorios de Clases', // Nombre del canal
      channelDescription: 'Canal para notificaciones de clases programadas',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    ),
    iOS: DarwinNotificationDetails(
      sound: 'default.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  /// Esta es la función clave que llamaremos desde tu AddScheduleScreen
  ///
  /// [id] - Un ID entero único para la notificación (¡muy importante!)
  /// [title] - Ej: "¡Clase a punto de empezar!"
  /// [body] - Ej: "Tu clase de INF-343 - Programación comienza en 10 min."
  /// [dayName] - El String que ya usas: "Lunes", "Martes", etc.
  /// [classTime] - El TimeOfDay de la hora de INICIO de la clase.
  Future<void> scheduleWeeklyClassNotification({
    required int id,
    required String title,
    required String body,
    required String dayName, // "Lunes", "Martes", etc.
    required TimeOfDay classTime,
  }) async {
    // --- AÑADE ESTAS LÍNEAS DE DEPURACIÓN ---
    developer.log('---  DEBUG NOTIFICACIÓN ---', name: 'NotificationService');
    developer.log('Intentando programar ID: $id', name: 'NotificationService');
    developer.log(
      'Datos recibidos: Día "$dayName", Hora Clase: ${classTime.toString()}',
      name: 'NotificationService',
    ); // Usamos classTime.toString() en lugar de classTime.format(context)
    // ---

    // 1. Convertir el nombre del día a un entero (Lunes=1, ... Domingo=7)
    final int dayOfWeek = _dayNameToWeekday(dayName);
    if (dayOfWeek == 0) return; // Día no válido

    // 2. Calcular la hora de la notificación (10 minutos antes)
    final int classHour = classTime.hour;
    final int classMinute = classTime.minute;

    int notificationMinute = classMinute - 10;
    int notificationHour = classHour;
    int targetDayOfWeek = dayOfWeek;
    if (notificationMinute < 0) {
      notificationMinute += 60;
      notificationHour -= 1;
      if (notificationHour < 0) {
        // Ajuste de día si la notificación cae en el día anterior
        notificationHour += 24;
        targetDayOfWeek = (dayOfWeek == DateTime.monday)
            ? DateTime.sunday
            : dayOfWeek - 1;
      }
    }

    // 3. Obtener la próxima fecha/hora para programar
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(
      targetDayOfWeek,
      notificationHour,
      notificationMinute,
    );

    // --- AÑADE ESTAS OTRAS LÍNEAS ---
    developer.log(
      'Hora de notificación calculada: $notificationHour:$notificationMinute',
      name: 'NotificationService',
    );
    developer.log(
      'Próxima fecha programada (en TZ local): $scheduledDate',
      name: 'NotificationService',
    );
    developer.log(
      'Hora actual (en TZ local): ${tz.TZDateTime.now(tz.local)}',
      name: 'NotificationService',
    );
    developer.log('--- FIN DEBUG ---', name: 'NotificationService');
    // ---

    // 4. Programar con `zonedSchedule` y `matchDateTimeComponents`
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // La magia: repetir cada vez que coincida el DÍA DE LA SEMANA y la HORA
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancela una notificación programada usando su ID único
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // --- Funciones Auxiliares (privadas) ---

  /// Convierte "Lunes" -> 1, "Martes" -> 2, etc.
  int _dayNameToWeekday(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'lunes':
        return DateTime.monday;
      case 'martes':
        return DateTime.tuesday;
      case 'miércoles': // Acento
      case 'miercoles':
        return DateTime.wednesday;
      case 'jueves':
        return DateTime.thursday;
      case 'viernes':
        return DateTime.friday;
      case 'sábado': // Acento
      case 'sabado':
        return DateTime.saturday;
      case 'domingo':
        return DateTime.sunday;
      default:
        return 0;
    }
  }

  /// Obtiene la próxima instancia de un día de la semana y hora
  tz.TZDateTime _nextInstanceOfTime(int dayOfWeek, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfDay(dayOfWeek);

    scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfDay(int dayOfWeek) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int currentDay = now.weekday;
    int daysToAdd = (dayOfWeek - currentDay + 7) % 7;

    // Si es 0, es hoy. Dejamos que _nextInstanceOfTime decida si la hora ya pasó
    return now.add(Duration(days: daysToAdd));
  }
}
