class Destino {
  final String? id;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String descripcion;
  final String urlImagen;

  Destino({
    this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.descripcion,
    required this.urlImagen,
  });

  // Convierte un objeto Destino a un mapa JSON para subirlo a Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'ubicacion': ubicacion,
      'precio': precio,
      'descripcion': descripcion,
      'urlImagen': urlImagen,
    };
  }

  // Crea un objeto Destino a partir de un documento de Firebase
  factory Destino.fromMap(Map<String, dynamic> map, String documentId) {
    return Destino(
      id: documentId,
      nombre: map['nombre'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      urlImagen: map['urlImagen'] ?? '',
    );
  }
}