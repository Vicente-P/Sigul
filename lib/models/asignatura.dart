class Asignatura {
  final String id;
  final String nombre;
  final String sigla;
  final String? nombreProfesor;
  final String? diaHoraClase;
  final String? emailProfesor;
  final String? horarioAtencionProfesor;
  final String? nombresAyudantes;
  final String? diaHoraAyudantia;
  final String? emailAyudantes;

  Asignatura({
    required this.id,
    required this.nombre,
    required this.sigla,
    this.nombreProfesor,
    this.diaHoraClase,
    this.emailProfesor,
    this.horarioAtencionProfesor,
    this.nombresAyudantes,
    this.diaHoraAyudantia,
    this.emailAyudantes,
  });

  // Método para validar el formato de la sigla (3 letras + guión + 3 números)
  static bool isValidSigla(String sigla) {
    final regex = RegExp(r'^[A-Z]{3}-\d{3}$');
    return regex.hasMatch(sigla);
  }

  // Crear una copia con valores modificados
  Asignatura copyWith({
    String? id,
    String? nombre,
    String? sigla,
    String? nombreProfesor,
    String? diaHoraClase,
    String? emailProfesor,
    String? horarioAtencionProfesor,
    String? nombresAyudantes,
    String? diaHoraAyudantia,
    String? emailAyudantes,
  }) {
    return Asignatura(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      sigla: sigla ?? this.sigla,
      nombreProfesor: nombreProfesor ?? this.nombreProfesor,
      diaHoraClase: diaHoraClase ?? this.diaHoraClase,
      emailProfesor: emailProfesor ?? this.emailProfesor,
      horarioAtencionProfesor: horarioAtencionProfesor ?? this.horarioAtencionProfesor,
      nombresAyudantes: nombresAyudantes ?? this.nombresAyudantes,
      diaHoraAyudantia: diaHoraAyudantia ?? this.diaHoraAyudantia,
      emailAyudantes: emailAyudantes ?? this.emailAyudantes,
    );
  }

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'sigla': sigla,
      'nombreProfesor': nombreProfesor,
      'diaHoraClase': diaHoraClase,
      'emailProfesor': emailProfesor,
      'horarioAtencionProfesor': horarioAtencionProfesor,
      'nombresAyudantes': nombresAyudantes,
      'diaHoraAyudantia': diaHoraAyudantia,
      'emailAyudantes': emailAyudantes,
    };
  }

  // Crear desde Map
  factory Asignatura.fromMap(Map<String, dynamic> map) {
    return Asignatura(
      id: map['id'],
      nombre: map['nombre'],
      sigla: map['sigla'],
      nombreProfesor: map['nombreProfesor'],
      diaHoraClase: map['diaHoraClase'],
      emailProfesor: map['emailProfesor'],
      horarioAtencionProfesor: map['horarioAtencionProfesor'],
      nombresAyudantes: map['nombresAyudantes'],
      diaHoraAyudantia: map['diaHoraAyudantia'],
      emailAyudantes: map['emailAyudantes'],
    );
  }
}