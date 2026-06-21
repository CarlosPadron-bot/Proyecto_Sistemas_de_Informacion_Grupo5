import 'package:cloud_firestore/cloud_firestore.dart';

class Destino {
  final String? id;
  final String nombre;
  final String ubicacion;
  final double precio;
  final String urlImagen;
  final String categoria;
  final String descripcion;
  final String infoExtra;
  final List<String> queIncluye;
  final String estado;
  final String duracion;
  final double calificacion;
  final String operadorId;

  Destino({
    this.id,
    required this.nombre,
    required this.ubicacion,
    required this.precio,
    required this.urlImagen,
    required this.categoria,
    required this.descripcion,
    required this.infoExtra,
    required this.queIncluye,
    required this.estado,
    required this.duracion,
    required this.calificacion,
    required this.operadorId,
  });

  // Factory para leer directamente de un DocumentSnapshot de Firestore
  factory Destino.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Destino(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      ubicacion: data['ubicacion'] ?? '',
      precio: (data['precio'] ?? 0.0).toDouble(),
      urlImagen: data['urlImagen'] ?? '',
      categoria: data['categoria'] ?? 'Paquetes Turísticos',
      descripcion: data['descripcion'] ?? '',
      infoExtra: data['infoExtra'] ?? '',
      queIncluye: List<String>.from(data['queIncluye'] ?? []),
      estado: data['estado'] ?? 'Otros',
      duracion: data['duracion'] ?? 'No definida',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      operadorId: data['operadorId'] ?? '',
    );
  }

  // Método para convertir a Map y subir/guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'ubicacion': ubicacion,
      'precio': precio,
      'urlImagen': urlImagen,
      'categoria': categoria,
      'descripcion': descripcion,
      'infoExtra': infoExtra,
      'queIncluye': queIncluye,
      'estado': estado,
      'duracion': duracion,
      'calificacion': calificacion,
      'operadorId': operadorId,
    };
  }

  // Método complementario copyWith por si necesitas modificar instancias clonadas
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
    String? duracion,
    double? calificacion,
    String? operadorId,
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
      duracion: duracion ?? this.duracion,
      calificacion: calificacion ?? this.calificacion,
      operadorId: operadorId ?? this.operadorId,
    );
  }
}