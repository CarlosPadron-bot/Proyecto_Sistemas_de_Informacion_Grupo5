import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/reserva_model.dart'; // Importamos el modelo que acabamos de actualizar

class ReservaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para guardar la reserva con la imagen incluida
  Future<void> registrarReserva(Reserva reserva) async {
    try {
      Map<String, dynamic> data = reserva.toMap();
      // Aseguramos que guarde el estado que tu panel busca
      data['estado'] = 'Pagada';
      data.remove('id');
      await _firestore.collection('reservas').add(data);
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Función útil para leer las reservas en tiempo real (Stream)
  Stream<List<Reserva>> obtenerReservasPorUsuario(String usuarioId) {
    return _firestore
        .collection('reservas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('completa', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
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

  Future<void> marcarReservaComoCompleta(String reservaId) async {
    try {
      await _firestore.collection('reservas').doc(reservaId).update({
        'completa': true, // ⬅️ Marcamos que ya terminó y tiene reseña
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado de la reserva: $e');
    }
  }

  Stream<List<Reserva>> obtenerHistorialPorUsuario(String usuarioId) {
    return _firestore
        .collection('reservas')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('completa', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Reserva.fromJson(data);
      }).toList();
    });
  }
}
