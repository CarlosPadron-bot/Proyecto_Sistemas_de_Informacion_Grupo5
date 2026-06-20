import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class DestinoService {
  final CollectionReference _destinosRef =
      FirebaseFirestore.instance.collection('destinos');

  // Obtener todos los destinos en tiempo real (Stream)
  Stream<List<Destino>> obtenerDestinos() {
    return _destinosRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Destino.fromFirestore(doc)).toList();
    });
  }

  // Guardar un nuevo destino
  Future<void> guardarDestino(Destino destino) async {
    try {
      await _destinosRef.add(destino.toFirestore());
    } catch (e) {
      throw Exception("Error al guardar el destino: $e");
    }
  }

  // --- NUEVO / CORREGIDO: MÉTODO PARA ACTUALIZAR DESTINO ---
  // (Este es el método que llamaba la pantalla de cargar/editar destino)
  Future<void> actualizarDestino(Destino destino) async {
    try {
      if (destino.id != null) {
        await _destinosRef.doc(destino.id).update(destino.toFirestore());
      } else {
        throw Exception("El ID del destino es nulo, no se puede actualizar.");
      }
    } catch (e) {
      throw Exception("Error al actualizar el destino: $e");
    }
  }

  // Eliminar un destino
  Future<void> eliminarDestino(String id) async {
    try {
      await _destinosRef.doc(id).delete();
    } catch (e) {
      throw Exception("Error al eliminar el destino: $e");
    }
  }

  // Cargar datos iniciales de prueba (Seed Data) si la colección está vacía
  Future<void> cargarDatosInicialesSiVacio() async {
    final querySnapshot = await _destinosRef.get();
    
    if (querySnapshot.docs.isEmpty) {
      final List<Destino> destinosIniciales = [
        Destino(
          nombre: 'Posada La Turquesa',
          ubicacion: 'Los Roques',
          precio: 150.0,
          urlImagen: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7',
          categoria: 'Alojamientos',
          descripcion: 'Disfruta de una estancia inolvidable en el paraíso de Los Roques. Incluye atención personalizada y paseos a los cayos cercanos.',
          infoExtra: 'Por noche',
          queIncluye: ['Desayuno', 'Cena', 'Paseo en lancha a Madrisquí'],
          estado: 'Otros',
          duracion: '1 noche',              
          calificacion: 4.8,                
        ),
        Destino(
          nombre: 'Aventura en Roraima',
          ubicacion: 'Parque Nacional Canaima',
          precio: 450.0,
          urlImagen: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa',
          categoria: 'Paquetes Turísticos',
          descripcion: 'Trekking de 6 días al tepuy más famoso de Venezuela. Una experiencia única para los amantes del excursionismo.',
          infoExtra: 'Cupos limitados',
          queIncluye: ['Guías pemones', 'Todas las comidas', 'Equipos de camping'],
          estado: 'Bolívar',
          duracion: '6 días / 5 noches',    
          calificacion: 4.9,               
        ),
        Destino(
          nombre: 'Hotel Wyndham Concorde',
          ubicacion: 'Porlamar',
          precio: 95.0,
          urlImagen: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
          categoria: 'Alojamientos',
          descripcion: 'Lujo y confort frente al mar en la Isla de Margarita. Ideal para vacaciones familiares o viajes de negocios.',
          infoExtra: 'Por noche',
          queIncluye: ['Acceso a piscina', 'Wifi de alta velocidad', 'Gimnasio'],
          estado: 'Nueva Esparta',
          duracion: '1 noche',            
          calificacion: 4.5,               
        ),
      ];

      for (var destino in destinosIniciales) {
        await _destinosRef.add(destino.toFirestore());
      }
    }
  }
}