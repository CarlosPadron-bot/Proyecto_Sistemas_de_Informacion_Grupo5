import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/reserva_model.dart';

class ReservaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Guardar nueva reserva en Firestore
  Future<void> registrarReserva(Reserva reserva) async {
    await _db.collection('reservas').add(reserva.toMap());
  }

  // 2. Escuchar todas las reservas en tiempo real (Para el Operador)
  Stream<List<Reserva>> obtenerTodasLasReservas() {
    return _db
        .collection('reservas')
        .orderBy('fechaReserva', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reserva.fromFirestore(doc))
            .toList());
  }
}