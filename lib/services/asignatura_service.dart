import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asignatura.dart';

class AsignaturaService {
  static final AsignaturaService _instance = AsignaturaService._internal();
  factory AsignaturaService() => _instance;
  AsignaturaService._internal();

  static const String _key = 'asignaturas';
  List<Asignatura> _asignaturas = [];
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? asignaturasJson = prefs.getString(_key);
    
    if (asignaturasJson != null && asignaturasJson.isNotEmpty) {
      final List<dynamic> decoded = json.decode(asignaturasJson);
      _asignaturas = decoded.map((item) => Asignatura.fromMap(item)).toList();
    } else {
      await _initializeDemoData();
    }
    
    _isInitialized = true;
  }

  Future<void> _initializeDemoData() async {
    _asignaturas = [
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
    ];
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> asignaturasMap = 
        _asignaturas.map((asignatura) => asignatura.toMap()).toList();
    await prefs.setString(_key, json.encode(asignaturasMap));
  }

  Future<List<Asignatura>> get asignaturas async {
    await _init();
    return List.unmodifiable(_asignaturas);
  }

  Future<void> agregarAsignatura(Asignatura asignatura) async {
    await _init();
    _asignaturas.add(asignatura);
    await _save();
  }

  Future<void> eliminarAsignatura(String id) async {
    await _init();
    _asignaturas.removeWhere((asignatura) => asignatura.id == id);
    await _save();
  }

  Future<void> actualizarAsignatura(Asignatura asignaturaActualizada) async {
    await _init();
    final index = _asignaturas.indexWhere((asignatura) => asignatura.id == asignaturaActualizada.id);
    if (index != -1) {
      _asignaturas[index] = asignaturaActualizada;
      await _save();
    }
  }

  Future<bool> existeSigla(String sigla, {String? excludeId}) async {
    await _init();
    return _asignaturas.any((asignatura) => 
      asignatura.sigla == sigla && (excludeId == null || asignatura.id != excludeId));
  }

  Future<Asignatura?> buscarPorId(String id) async {
    await _init();
    try {
      return _asignaturas.firstWhere((asignatura) => asignatura.id == id);
    } catch (e) {
      return null;
    }
  }
}