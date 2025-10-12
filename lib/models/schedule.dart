class Schedule {
  final String subject;
  final String professor;
  final String room;
  final String day;
  final String startTime;
  final String endTime;
  final String repetition;
  final String note;

  Schedule({
    required this.subject,
    required this.professor,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.repetition,
    required this.note,
  });

  // 🔹 Convertir objeto a Map (para JSON)
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

  // 🔹 Crear objeto desde Map
  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
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
