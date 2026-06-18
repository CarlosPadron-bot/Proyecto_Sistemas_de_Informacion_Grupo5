import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/resena_model.dart';

class ResenaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guarda la reseña
  Future<void> publicarResena(Resena resena) async {
    await _db.collection('resenas').add(resena.toMap());
  }

  // Obtener las reseñas que ha hecho un usuario específico
  Stream<List<Resena>> obtenerResenasPorUsuario(String usuarioId) {
    return _db
        .collection('resenas')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => Resena.fromMap(doc.data(), doc.id))
          .toList();
      lista.sort((a, b) => b.fechaResena.compareTo(a.fechaResena));
      return lista;
    });
  }

  // Obtener todas las reseñas de la plataforma en tiempo real (Para el Operador)
  Stream<List<Resena>> obtenerTodasLasResenas() {
    return _db.collection('resenas').snapshots().map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => Resena.fromMap(doc.data(), doc.id))
          .toList();
      // Las ordenamos para que las más recientes salgan primero
      lista.sort((a, b) => b.fechaResena.compareTo(a.fechaResena));
      return lista;
    });
  }
}
