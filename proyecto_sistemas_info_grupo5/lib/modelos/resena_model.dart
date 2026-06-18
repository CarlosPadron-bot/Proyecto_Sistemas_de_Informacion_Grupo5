import 'package:cloud_firestore/cloud_firestore.dart';

//Para guardar sobre todo las calificaciones de los usuarios
class Resena {
  final String? id;
  final String usuarioId;
  final String usuarioNombre;
  final String destinoId;
  final String destinoNombre;
  final String urlImagenDestino;
  final int calificacion; // Del 1 al 5
  final String comentario;
  final DateTime fechaResena;

  Resena({
    this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.destinoId,
    required this.destinoNombre,
    required this.urlImagenDestino,
    required this.calificacion,
    required this.comentario,
    required this.fechaResena,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'destinoId': destinoId,
      'destinoNombre': destinoNombre,
      'urlImagenDestino': urlImagenDestino,
      'calificacion': calificacion,
      'comentario': comentario,
      'fechaResena': Timestamp.fromDate(fechaResena),
    };
  }

  factory Resena.fromMap(Map<String, dynamic> map, String id) {
    return Resena(
      id: id,
      usuarioId: map['usuarioId'] ?? '',
      usuarioNombre: map['usuarioNombre'] ?? '',
      destinoId: map['destinoId'] ?? '',
      destinoNombre: map['destinoNombre'] ?? '',
      urlImagenDestino: map['urlImagenDestino'] ?? '',
      calificacion: map['calificacion'] ?? 0,
      comentario: map['comentario'] ?? '',
      fechaResena: (map['fechaResena'] as Timestamp).toDate(),
    );
  }
}
