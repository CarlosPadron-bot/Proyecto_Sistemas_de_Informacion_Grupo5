class Destino {
  final String? id;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String descripcion;
  final String urlImagen;
  final String categoria; // 'Paquetes Turisticos' o 'Alojamientos'
  final String infoExtra; // Ej: "3 días · 6 cupos" o "Por noche"
  final List<String> queIncluye; // Ej: ['Traslado', 'Guía']
  final String estado; // Estado de Venezuela (Mérida, Falcón, Caracas, etc.)

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

  factory Destino.fromMap(Map<String, dynamic> map, String documentId) {
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
}
