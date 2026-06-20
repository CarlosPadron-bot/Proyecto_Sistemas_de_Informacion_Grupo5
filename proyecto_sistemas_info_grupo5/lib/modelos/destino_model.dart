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
}