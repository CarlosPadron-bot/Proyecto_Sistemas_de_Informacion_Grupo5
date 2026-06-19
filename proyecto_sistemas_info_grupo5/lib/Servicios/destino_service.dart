import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class DestinoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Función para guardar un nuevo destino en Firestore
  Future<void> guardarDestino(Destino destino) async {
    try {
      await _db.collection('destinos').add(destino.toMap());
    } catch (e) {
      throw Exception('Error al guardar el destino en la base de datos: $e');
    }
  }

  // 2. Función para actualizar un destino existente en Firestore
  Future<void> actualizarDestino(Destino destino) async {
    try {
      if (destino.id == null || destino.id!.isEmpty) {
        throw Exception('No se puede actualizar un destino sin un ID válido.');
      }

      await _db.collection('destinos').doc(destino.id).update(destino.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el destino en la base de datos: $e');
    }
  }

  // 3. Función para eliminar un destino de Firestore
  Future<void> eliminarDestino(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('No se puede eliminar un destino sin un ID válido.');
      }

      await _db.collection('destinos').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar el destino de la base de datos: $e');
    }
  }

  //Función para obtener la lista de destinos (Una sola petición - Para FutureBuilder)
  Future<List<Destino>> obtenerDestinos() async {
    try {
      QuerySnapshot snapshot = await _db.collection('destinos').get();

      // Mapeamos cada documento de Firestore convirtiéndolo en un objeto Destino
      return snapshot.docs.map((doc) {
        // Usamos el constructor fromFirestore pasándole el ID y los datos
        return Destino.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception(
          'Error al obtener los destinos desde la base de datos: $e');
    }
  }

//Función para obtener destinos en tiempo real (Para StreamBuilder)
  Stream<List<Destino>> obtenerDestinosStream() {
    return _db.collection('destinos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Destino.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Destino>>? obtenerDestinosPorCategoria(String categoriaFiltro) {}
}
