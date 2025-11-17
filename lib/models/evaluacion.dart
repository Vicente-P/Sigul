class Evaluacion {
  final String id;
  final String tipo; // "Certamen", "Control", "Proyecto", "Tarea", etc.
  final double calificacion; // 0-100
  final double? ponderacion; // 1-100% (opcional)
  final String? nombre; // Nombre opcional de la evaluación
  final DateTime? fecha; // Fecha opcional

  Evaluacion({
    required this.id,
    required this.tipo,
    required this.calificacion,
    this.ponderacion,
    this.nombre,
    this.fecha,
  });

  // Validación de calificación
  static bool isValidCalificacion(double calificacion) {
    return calificacion >= 0 && calificacion <= 100;
  }

  // Validación de ponderación
  static bool isValidPonderacion(double? ponderacion) {
    if (ponderacion == null) return true;
    return ponderacion > 0 && ponderacion <= 100;
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'calificacion': calificacion,
      'ponderacion': ponderacion,
      'nombre': nombre,
      'fecha': fecha?.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      id: json['id'],
      tipo: json['tipo'],
      calificacion: json['calificacion'],
      ponderacion: json['ponderacion'],
      nombre: json['nombre'],
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
    );
  }

  // Crear copia con modificaciones
  Evaluacion copyWith({
    String? id,
    String? tipo,
    double? calificacion,
    double? ponderacion,
    String? nombre,
    DateTime? fecha,
  }) {
    return Evaluacion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      calificacion: calificacion ?? this.calificacion,
      ponderacion: ponderacion ?? this.ponderacion,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
    );
  }
}
