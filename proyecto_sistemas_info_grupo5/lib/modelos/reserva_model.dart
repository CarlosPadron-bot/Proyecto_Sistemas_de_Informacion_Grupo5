import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  final String? id;
  final String destinoNombre;
  final String destinoUbicacion;
  final double precioPagado;
  final int cantidadViajeros;
  final String usuarioCorreo;
  final DateTime fechaReserva;

  Reserva({
    this.id,
    required this.destinoNombre,
    required this.destinoUbicacion,
    required this.precioPagado,
    required this.cantidadViajeros,
    required this.usuarioCorreo,
    required this.fechaReserva,
  });

  // Convertir de Objeto Dart a JSON (Map) para Firebase
  Map<String, dynamic> toMap() {
    return {
      'destinoNombre': destinoNombre,
      'destinoUbicacion': destinoUbicacion,
      'precioPagado': precioPagado,
      'cantidadViajeros': cantidadViajeros,
      'usuarioCorreo': usuarioCorreo,
      'fechaReserva': Timestamp.fromDate(fechaReserva),
    };
  }

  // Convertir de Firebase (DocumentSnapshot) a Objeto Dart
  factory Reserva.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reserva(
      id: doc.id,
      destinoNombre: data['destinoNombre'] ?? '',
      destinoUbicacion: data['destinoUbicacion'] ?? '',
      precioPagado: (data['precioPagado'] ?? 0.0).toDouble(),
      cantidadViajeros: data['cantidadViajeros'] ?? 1,
      usuarioCorreo: data['usuarioCorreo'] ?? 'Invitado',
      fechaReserva: (data['fechaReserva'] as Timestamp).toDate(),
    );
  }
}