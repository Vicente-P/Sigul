import '../models/asignatura.dart';

class AsignaturaService {
  static final AsignaturaService _instance = AsignaturaService._internal();
  factory AsignaturaService() => _instance;
  AsignaturaService._internal() {
    _initializeDemoData();
  }

  final List<Asignatura> _asignaturas = [];

  void _initializeDemoData() {
    _asignaturas.addAll([
      Asignatura(
        id: '1',
        nombre: 'Programación Orientada a Objetos',
        sigla: 'INF-343',
        nombreProfesor: 'Dr. Juan Pérez',
        diaHoraClase: 'Lunes y Miércoles 10:00-11:30',
        emailProfesor: 'juan.perez@universidad.cl',
        horarioAtencionProfesor: 'Martes 14:00-16:00',
        nombresAyudantes: 'María García, Carlos López',
        diaHoraAyudantia: 'Viernes 15:00-16:30',
        emailAyudantes: 'ayudantes.inf343@universidad.cl',
      ),
      Asignatura(
        id: '2',
        nombre: 'Bases de Datos',
        sigla: 'INF-244',
        nombreProfesor: 'Dra. Ana Morales',
        diaHoraClase: 'Martes y Jueves 14:00-15:30',
        emailProfesor: 'ana.morales@universidad.cl',
      ),
      Asignatura(
        id: '3',
        nombre: 'Algoritmos y Estructuras de Datos',
        sigla: 'INF-134',
      ),
    ]);
  }

  List<Asignatura> get asignaturas => List.unmodifiable(_asignaturas);

  void agregarAsignatura(Asignatura asignatura) {
    _asignaturas.add(asignatura);
  }

  void eliminarAsignatura(String id) {
    _asignaturas.removeWhere((asignatura) => asignatura.id == id);
  }

  void actualizarAsignatura(Asignatura asignaturaActualizada) {
    final index = _asignaturas.indexWhere((asignatura) => asignatura.id == asignaturaActualizada.id);
    if (index != -1) {
      _asignaturas[index] = asignaturaActualizada;
    }
  }

  bool existeSigla(String sigla, {String? excludeId}) {
    return _asignaturas.any((asignatura) => 
      asignatura.sigla == sigla && (excludeId == null || asignatura.id != excludeId));
  }

  Asignatura? buscarPorId(String id) {
    try {
      return _asignaturas.firstWhere((asignatura) => asignatura.id == id);
    } catch (e) {
      return null;
    }
  }
}