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
<<<<<<< HEAD
  final String duracion;       
  final double calificacion;   
=======
  final String operadorId;
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db

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
<<<<<<< HEAD
    required this.duracion,    
    required this.calificacion, 
=======
    required this.operadorId,
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
  });

  factory Destino.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Destino(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      ubicacion: data['ubicacion'] ?? '',
      precio: (data['precio'] ?? 0.0).toDouble(),
      urlImagen: data['urlImagen'] ?? '',
      categoria: data['categoria'] ?? '',
      descripcion: data['descripcion'] ?? '',
      infoExtra: data['infoExtra'] ?? '',
      queIncluye: List<String>.from(data['queIncluye'] ?? []),
      estado: data['estado'] ?? 'Caracas',
      duracion: data['duracion'] ?? 'No definida', 
      calificacion: (data['calificacion'] ?? 0.0).toDouble(), 
    );
  }

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
    };
  }
<<<<<<< HEAD
}
=======

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
      operadorId: map['operadorId'] ?? '',
    );
  }

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
      operadorId: operadorId ?? this.operadorId,
    );
  }

  static fromMap(Map<String, dynamic> data) {}
}
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
