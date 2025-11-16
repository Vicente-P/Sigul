class Schedule {
  final int notificationId; // ID único para la notificación
  final String subject;
  final String professor;
  final String room;
  final String day;
  final String startTime;
  final String endTime;
  final String repetition;
  final String note;

  Schedule({
    required this.notificationId,
    required this.subject,
    required this.professor,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.repetition,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'professor': professor,
    'room': room,
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'repetition': repetition,
    'note': note,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    notificationId:
        json['notificationId'] ??
        DateTime.now().millisecondsSinceEpoch % 2147483647,
    subject: json['subject'],
    professor: json['professor'],
    room: json['room'],
    day: json['day'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    repetition: json['repetition'],
    note: json['note'],
  );
}
