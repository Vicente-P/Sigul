

class Building {
  final String name;
  final String description;
  final String image;
  final List<PointOfInterest> pointsOfInterest;
  final List<String> salas;
  final String orientation;

  Building({
    required this.name,
    required this.description,
    required this.image,
    required this.pointsOfInterest,
    this.orientation = '',
    List<String>? salas,
  }) : salas = salas ?? [];

  // Verificar si una sala pertenece a este edificio
  bool tieneSala(String nombreSala) {
    return salas.any((sala) => 
      sala.toLowerCase() == nombreSala.toLowerCase()
    );
  }
}

class PointOfInterest {
  final String name;
  final String image;
  final String description;
  final String floor;

  PointOfInterest({
    required this.name,
    required this.image,
    required this.description,
    required this.floor,
  });
}