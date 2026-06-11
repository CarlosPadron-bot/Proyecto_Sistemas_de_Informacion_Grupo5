import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/reserva_model.dart'; // Importamos el modelo que acabamos de actualizar

class ReservaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para guardar la reserva con la imagen incluida
  Future<void> registrarReserva(Reserva reserva) async {
    try {
      // El método .toMap() ahora incluye automáticamente la propiedad 'urlImagen'
      await _firestore.collection('reservas').add(reserva.toMap());
    } catch (e) {
      throw Exception('Error al registrar la reserva en Firestore: $e');
    }
  }

  // Función útil para leer las reservas en tiempo real (Stream)
  Stream<List<Reserva>> obtenerReservasPorUsuario(String usuarioId) {
    return _firestore
        .collection('reservas')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Combinamos los datos de Firebase con el ID del documento
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; 
        return Reserva.fromJson(data);
      }).toList();
    });
  }

  // Función útil para que el Admin lea TODAS las reservas del sistema
  Stream<List<Reserva>> obtenerTodasLasReservas() {
    return _firestore.collection('reservas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Reserva.fromJson(data);
      }).toList();
    });
  }
}