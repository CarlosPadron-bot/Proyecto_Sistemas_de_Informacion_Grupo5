class Destino {
  final String? id;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String descripcion;
  final String urlImagen;
  final String categoria; 
  final String infoExtra; 
  final List<String> queIncluye; 
  final String estado; 

  Destino({
    this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.descripcion,
    required this.urlImagen,
    required this.categoria,
    required this.infoExtra,
    required this.queIncluye,
    required this.estado,
  });

  /// Método para convertir el objeto a un Map (Para GUARDAR en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'ubicacion': ubicacion,
      'precio': precio,
      'descripcion': descripcion,
      'urlImagen': urlImagen,
      'categoria': categoria,
      'infoExtra': infoExtra,
      'queIncluye': queIncluye,
      'estado': estado,
    };
  }

  /// Factory para crear un objeto a partir de un Map (Para LEER de Firestore)
  factory Destino.fromFirestore(String documentId, Map<String, dynamic> map) {
    return Destino(
      id: documentId,
      nombre: map['nombre'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      urlImagen: map['urlImagen'] ?? '',
      categoria: map['categoria'] ?? 'Paquetes Turisticos',
      infoExtra: map['infoExtra'] ?? '',
      queIncluye: List<String>.from(map['queIncluye'] ?? []),
      estado: map['estado'] ?? 'Otros',
    );
  }

  /// Método copyWith para crear copias del objeto modificando campos específicos
  /// (Ideal para trabajar con variables 'final')
  Destino copyWith({
    String? id,
    String? nombre,
    String? ubicacion,
    double? precio,
    String? descripcion,
    String? urlImagen,
    String? categoria,
    String? infoExtra,
    List<String>? queIncluye,
    String? estado,
  }) {
    return Destino(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ubicacion: ubicacion ?? this.ubicacion,
      precio: precio ?? this.precio,
      descripcion: descripcion ?? this.descripcion,
      urlImagen: urlImagen ?? this.urlImagen,
      categoria: categoria ?? this.categoria,
      infoExtra: infoExtra ?? this.infoExtra,
      queIncluye: queIncluye ?? this.queIncluye,
      estado: estado ?? this.estado,
    );
  }

  static Object? fromMap(Map<String, dynamic> data, String id) {}
}
