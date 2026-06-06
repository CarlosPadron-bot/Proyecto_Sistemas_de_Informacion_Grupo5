import 'package:flutter/material.dart';
import '../../homepage/widgets/item_card.dart'; // Verifica que esta ruta sea correcta según tu proyecto

class GridResultados extends StatelessWidget {
  const GridResultados({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí está la lista con todos los destinos que me pediste
    final List<Map<String, dynamic>> destinos = [
      {'titulo': 'Aventura Los Roques 3 Días', 'ubicacion': 'Los Roques, Dependencias Federales', 'info': '3 días · 6 cupos', 'precio': '280', 'tipo': '/persona', 'calificacion': 4.9, 'resenas': 56, 'categoria': 'Paquete'},
      {'titulo': 'Salto Ángel Express 2 Días', 'ubicacion': 'Canaima, Bolívar', 'info': '2 días · 12 cupos', 'precio': '195', 'tipo': '/persona', 'calificacion': 4.8, 'resenas': 43, 'categoria': 'Paquete'},
      {'titulo': 'Ruta Andina Económica 4 Días', 'ubicacion': 'Mérida, Mérida', 'info': '4 días · 15 cupos', 'precio': '165', 'tipo': '/persona', 'calificacion': 4.6, 'resenas': 38, 'categoria': 'Paquete'},
      {'titulo': 'Morrocoy Fin de Semana', 'ubicacion': 'Parque Nacional Morrocoy', 'info': '2 días · 10 cupos', 'precio': '120', 'tipo': '/persona', 'calificacion': 4.7, 'resenas': 91, 'categoria': 'Paquete'},
      {'titulo': 'Playas de Sucre 3 Días', 'ubicacion': 'Península de Paria, Sucre', 'info': '3 días · 8 cupos', 'precio': '145', 'tipo': '/persona', 'calificacion': 4.5, 'resenas': 27, 'categoria': 'Paquete'},
      {'titulo': 'Posada Los Roques Paradise', 'ubicacion': 'Gran Roque', 'info': '6 personas', 'precio': '45', 'tipo': '/noche', 'calificacion': 4.8, 'resenas': 24, 'categoria': 'posada'},
      {'titulo': 'Camping Canaima', 'ubicacion': 'Parque Nacional Canaima', 'info': '4 personas', 'precio': '15', 'tipo': '/noche', 'calificacion': 4.5, 'resenas': 18, 'categoria': 'camping'},
      {'titulo': 'Cabaña Montaña Mérida', 'ubicacion': 'Los Nevados, Mérida', 'info': '8 personas', 'precio': '35', 'tipo': '/noche', 'calificacion': 4.7, 'resenas': 31, 'categoria': 'cabaña'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${destinos.length} resultados encontrados', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: destinos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Modifica este número si la tarjeta se ve muy estirada o aplastada
            ),
            itemBuilder: (context, index) {
              final destino = destinos[index];
              return ItemCard(
                titulo: destino['titulo'],
                ubicacion: destino['ubicacion'],
                infoExtra: destino['info'],
                precio: destino['precio'],
                tipoPrecio: destino['tipo'],
                calificacion: destino['calificacion'],
                resenas: destino['resenas'],
                categoria: destino['categoria'],
              );
            },
          ),
        ),
      ],
    );
  }
}
