import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/destino_model.dart';

class DestinoService {
  final CollectionReference _destinosCollection =
      FirebaseFirestore.instance.collection('destinos');

  // 1. OBTENER TODOS LOS DESTINOS EN TIEMPO REAL (STREAM)
  Stream<List<Destino>> obtenerTodosLosDestinos() {
    return _destinosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Destino.fromFirestore(doc);
      }).toList();
    });
  }

  // 2. OBTENER DESTINOS FILTRADOS POR CATEGORÍA (Paquetes Turísticos o Alojamientos)
  Stream<List<Destino>> obtenerDestinosPorCategoria(String categoria) {
    // Normalizamos el string por si viene con variaciones de escritura
    String categoriaFiltro = categoria;
    if (categoria.toLowerCase().contains('paquete')) {
      categoriaFiltro = 'Paquetes Turísticos';
    } else if (categoria.toLowerCase().contains('alojamiento')) {
      categoriaFiltro = 'Alojamientos';
    }

    return _destinosCollection
        .where('categoria', isEqualTo: categoriaFiltro)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Destino.fromFirestore(doc)).toList();
    });
  }

  // 3. OBTENER DESTINOS EXCLUSIVOS DE UN OPERADOR LOGUEADO
  Stream<List<Destino>> obtenerDestinosPorOperador(String operadorId) {
    return _destinosCollection
        .where('operadorId', isEqualTo: operadorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Destino.fromFirestore(doc)).toList();
    });
  }

  // 4. GUARDAR UN NUEVO SERVICIO (CREATE)
  Future<void> guardarDestino(Destino destino) async {
    try {
      await _destinosCollection.add(destino.toFirestore());
    } catch (e) {
      throw Exception('Error al guardar el destino en Firestore: $e');
    }
  }

  // 5. ACTUALIZAR UN SERVICIO EXISTENTE (UPDATE)
  Future<void> actualizarDestino(Destino destino) async {
    if (destino.id == null || destino.id!.isEmpty) {
      throw Exception('No se puede actualizar un destino sin un ID válido.');
    }
    try {
      await _destinosCollection.doc(destino.id).update(destino.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar el destino en Firestore: $e');
    }
  }

  // 6. ELIMINAR UN SERVICIO (DELETE)
  Future<void> eliminarDestino(String idDestino) async {
    try {
      await _destinosCollection.doc(idDestino).delete();
    } catch (e) {
      throw Exception('Error al eliminar el destino de Firestore: $e');
    }
  }

  // 7. OBTENER UN ÚNICO DESTINO POR SU ID (Para pantallas de detalles)
  Future<Destino?> obtenerDestinoPorId(String idDestino) async {
    try {
      final doc = await _destinosCollection.doc(idDestino).get();
      if (doc.exists) {
        return Destino.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el destino: $e');
    }
  }
}