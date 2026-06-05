import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class DestinoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Función para guardar un nuevo destino en Firestore
  Future<void> guardarDestino(Destino destino) async {
    try {
      await _db.collection('destinos').add(destino.toMap());
    } catch (e) {
      throw Exception('Error al guardar el destino en la base de datos: $e');
    }
  }
}