import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class BannerAnuncioNuevo extends StatelessWidget {
  const BannerAnuncioNuevo({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Conectamos con la colección 'destinos' en Firebase
      // Ordenamos por 'fechaCreacion' de forma descendente (el más nuevo primero)
      // Y le ponemos un límite de 1 para que solo consuma el último registro
      stream: FirebaseFirestore.instance
          .collection('destinos')
          .orderBy('fechaCreacion', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Si hay datos, extraemos el primer documento de la lista
        var doc = snapshot.data!.docs.first;
        

        Destino ultimoDestino = Destino.fromFirestore(
          doc.id, 
          doc.data() as Map<String, dynamic>
        );

        // Retornamos el diseño físico de la barra de anuncios
        return Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 238, 139, 58), // El color anaranjado de la barra de anuncios
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.campaign, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "¡NUEVA RUTA DISPONIBLE! Ya puedes reservar: ${ultimoDestino.nombre}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}