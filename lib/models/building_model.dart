

class Building {
  final String name;
  final String description;
  final String image;
  final List<PointOfInterest> pointsOfInterest;

  Building({
    required this.name,
    required this.description,
    required this.image,
    required this.pointsOfInterest,
  });
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