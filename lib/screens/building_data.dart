
import '../models/building_model.dart';

class BuildingData {
  static List<String> _generarSalas(String prefijo, int inicio, int fin) {
    List<String> salas = [];
    for (int i = inicio; i <= fin; i++) {
      salas.add('$prefijo${i.toString().padLeft(2, '0')}');
    }
    return salas;
  }

  static List<String> _getSalasEdificioP() {
    List<String> salas = [];
    
    salas.addAll(_generarSalas('P1', 1, 15));
    
    salas.addAll(_generarSalas('P2', 1, 15));
    
    salas.addAll(_generarSalas('P3', 1, 15));
    
    salas.addAll(_generarSalas('P4', 1, 15));
    
    salas.addAll(_generarSalas('PC', 1, 10));
    
    return salas;
  }

  static List<String> _getSalasEdificioC() {
    List<String> salas = [];
    
    salas.addAll(_generarSalas('C2', 1, 40));
    
    salas.add('C365');
    
    return salas;
  }

  static List<Building> getAllBuildings() {
    return [
      getBuildingData('Edificio P'),
      getBuildingData('Edificio C'),
    ];
  }

  static Building? buscarEdificioPorSala(String nombreSala) {
    final edificios = getAllBuildings();
    
    for (var edificio in edificios) {
      if (edificio.tieneSala(nombreSala)) {
        return edificio;
      }
    }
    
    return null;
  }

  static Building getBuildingData(String buildingName) {
    
    if (buildingName == 'Edificio P') {
      return Building(
        name: 'Edificio P',
        description: 'De los edificios más recientes de la universidad, con múltiples salas con computadores. Cuenta con 4 pisos y algunas áreas comunes.',
        image: 'assets/images/edificio_p.png',
        salas: _getSalasEdificioP(),
        pointsOfInterest: [
          PointOfInterest(
            name: 'Comedor Principal',
            image: 'assets/images/comedor_p.jpeg',
            description: 'Comedor que podrás encontrar en el último piso y que abre desde las 12PM. En caso de estar congestionado el comedor del Patio Central es una opción.',
            floor: 'Piso 4',
          ),
          PointOfInterest(
            name: 'Laboratorio de Central',
            image: 'assets/images/lab_computacion.jpeg',
            description: 'Salas en subterráneo con computadores para clases comunmente de programación y diseño.',
            floor: 'Piso 0',
          ),
          PointOfInterest(
            name: 'Kiosco Terraza',
            image: 'assets/images/kiosco_p.jpeg',
            description: 'Aquí puedes comer almuerzos también o simplemente comprar snacks y bebidas.',
            floor: 'Terraza',
          ),
          PointOfInterest(
            name: 'Oficina Administración',
            image: 'assets/images/oficina_adm.jpeg',
            description: 'Oficina del subterráneo del edificio P, donde puedes realizar trámites administrativos como la foto de tu carnet universitario.',
            floor: 'Piso 0',
          ),
          PointOfInterest(
            name: 'Sala compartida', 
            image: 'assets/images/sala_compartida.jpeg', 
            description: 'Sala multipropósito compartida con otros estudiantes y funcionarios, ideal para comer algo, estudiar o simplemente descansar un rato entre clases.',
            floor: 'Piso 1',
          ),
        ],
      
        orientation: """
📋 **Sistema de Numeración de Salas**

• **PC##** - Salas del subterráneo (Piso 0)
• **P1##** - Salas del primer piso 
• **P2##** - Salas del segundo piso
• **P3##** - Salas del tercer piso  
• **P4##** - Salas del cuarto piso

🗺️ **Distribución por Pisos**

**Piso 0 (Subterráneo):**
- Laboratorios de computación (PC01-PC10)
- Oficina administrativa

**Piso 1:**
- Salas P101-P115
- LABUX

**Piso 2:**
- Salas P201-P215
- Área de sillones para descanso

**Piso 3:**
- Salas P301-P315
- Cenade

**Piso 4:**
- Salas P401-P415
- Comedor principal
- Subida a kiosco terraza

💡 **Consejos de Orientación**
• Hay salas con puertas en ambos lados de los pasillos
• Hay salas de estudio en todos los pisos
• Ascensores cerca de los baños en casi todos los pisos
• Las numeraciones de salas aumentan conforme vas al fondo del edificio
• Señalización de numeración de salas en cada piso junto a las puertas
""",
      
      );
    }

    
    if (buildingName == 'Edificio C') {
      return Building(
        name: 'Edificio C',
        description: 'Edificio con departamento de obras civiles y ciencia de materiales. Cuenta con otros laboratorios como los CIMA. Es de los edificios por los cuales circulan muchos estudiantes para llegar a otros edificios. Cuenta con 2 pisos transitables por estudiantes.',
        image: 'assets/images/edificio_c.jpg',
        salas: _getSalasEdificioC(),
        pointsOfInterest: [
          PointOfInterest(
            name: 'Kiosco edificio C',
            image: 'assets/images/kiosco_c.jpg',
            description: 'Kiosco ubicado en el primer piso del edificio C, ideal para comprar snacks y bebidas entre clases. Puedes comprar usando tu beneficio BAES.',
            floor: 'Piso 2',
          ),
          PointOfInterest(
            name: 'Baño Mixto',
            image: 'assets/images/bano_mix.jpg',
            description: 'Baño mixto ubicado en el primer piso del edificio C, accesible para todos los estudiantes y personal del campus.',
            floor: 'Piso 1',
          ),
        ],
      
        orientation: """
📋 **Sistema de Numeración de Salas**

• **C20#** - Salas del primer pasillo
• **C22#** - Salas del segundo pasillo
• **C23#** - Salas del tercer pasillo

🗺️ **Distribución por Pisos**

**Piso 1:**
- Salas C201-C23# (lado norte)
- Baños mixtos
- Cajero automático
- OSI: Lugar de impresiones, fotocopias y venta de útiles
- Departamento de obras civiles
- Laboratorios CIMA

**Piso 2:**
- Algunas salas C23# (pasillo 3)
- Kiosco del edificio C


💡 **Consejos de Orientación**
• La mayoría de las salas están en los pasillos a mano derecha al entrar desde Placeres
• Hay algunas salas ubicadas en el tercer pasillo (C23#) que están subiendo unas escaleras.
• Bajando las escaleras por el pasillo principal hay un pequeño espacio con baños y maquinas expendedoras
• Pasillo de las salas C22# conecta con subida a Salida por Valdés, Edificio M y Gimnasios
• Al comienzo de cada pasillo hay una lista con la numeración de las salas
""",

      
      );
    }
    
    return Building(
      name: buildingName,
      description: 'Edificio del campus universitario con instalaciones modernas y espacios adaptados para el aprendizaje.',
      image: 'assets/images/default_building.jpg',
      pointsOfInterest: [
        PointOfInterest(
          name: 'Entrada Principal',
          image: 'assets/images/entrada.jpg',
          description: 'Acceso principal al edificio con recepción y información general.',
          floor: 'Piso 1',
        ),
      ],
    );
  }
}