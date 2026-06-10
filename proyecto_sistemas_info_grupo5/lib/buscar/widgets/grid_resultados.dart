import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import '../../homepage/widgets/item_card.dart';

class GridResultados extends StatelessWidget {
  const GridResultados({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí está la lista con todos los destinos 
    final List<Map<String, dynamic>> destinos = [
      {
        'titulo': 'Aventura Los Roques 3 Días',
        'ubicacion': 'Los Roques, Dependencias Federales',
        'info': '3 días · 6 cupos',
        'precio': '280',
        'tipo': '/persona',
        'calificacion': 4.9,
        'resenas': 56,
        'categoria': 'Paquete',
        'rutaImagen': "assets/isla_la_tortuga.png",
      },
      {
        'titulo': 'Salto Ángel Express 2 Días',
        'ubicacion': 'Canaima, Bolívar',
        'info': '2 días · 12 cupos',
        'precio': '195',
        'tipo': '/persona',
        'calificacion': 2.1,
        'resenas': 43,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/salto_angel.png',
      },
      {
        'titulo': 'Ruta Andina Económica 4 Días',
        'ubicacion': 'Mérida, Mérida',
        'info': '4 días · 15 cupos',
        'precio': '165',
        'tipo': '/persona',
        'calificacion': 4.6,
        'resenas': 38,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/merida.png'
      },
      {
        'titulo': 'Morrocoy Fin de Semana',
        'ubicacion': 'Parque Nacional Morrocoy',
        'info': '2 días · 10 cupos',
        'precio': '120',
        'tipo': '/persona',
        'calificacion': 5.0,
        'resenas': 91,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/morrocoy.png',
      },
      {
        'titulo': 'Playas de Sucre 3 Días',
        'ubicacion': 'Península de Paria, Sucre',
        'info': '3 días · 8 cupos',
        'precio': '145',
        'tipo': '/persona',
        'calificacion': 4.5,
        'resenas': 27,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/playas_sucre.png',
      },
      {
        'titulo': 'Posada Los Roques Paradise',
        'ubicacion': 'Gran Roque',
        'info': '6 personas',
        'precio': '45',
        'tipo': '/noche',
        'calificacion': 4.8,
        'resenas': 24,
        'categoria': 'posada',
        'rutaImagen': 'assets/los_roques.png',
      },
      {
        'titulo': 'Camping Canaima',
        'ubicacion': 'Parque Nacional Canaima',
        'info': '4 personas',
        'precio': '15',
        'tipo': '/noche',
        'calificacion': 1.5,
        'resenas': 18,
        'categoria': 'camping',
        'rutaImagen': 'assets/posada.png',
      },
      {
        'titulo': 'Cabaña Montaña Mérida',
        'ubicacion': 'Los Nevados, Mérida',
        'info': '8 personas',
        'precio': '35',
        'tipo': '/noche',
        'calificacion': 3.1,
        'resenas': 31,
        'categoria': 'cabaña',
        'rutaImagen': 'assets/caba_merida.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${destinos.length} resultados encontrados',
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: destinos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio:
                  1.5, // Modifica este número si la tarjeta se ve muy estirada o aplastada
            ),
            itemBuilder: (context, index) {
              final destino = destinos[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleDestinoPage(
                        title: destino['titulo'],
                        location: destino['ubicacion'],
                        price: destino['precio'],
                        priceSuffix: destino['tipo'],
                        rating: destino['calificacion'].toString(),
                        reviewCount: destino['resenas'].toString(),
                        imageUrl: destino["rutaImagen"],
                        description:
                            'Descripción detallada de ${destino['titulo']}.',
                        includes: const [
                          'Traslado',
                          'Alojamiento',
                          'Guía turístico'
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: ItemCard(
                  titulo: destino['titulo'],
                  ubicacion: destino['ubicacion'],
                  infoExtra: destino['info'],
                  precio: destino['precio'],
                  tipoPrecio: destino['tipo'],
                  calificacion: destino['calificacion'],
                  resenas: destino['resenas'],
                  categoria: destino['categoria'],
                  rutaImagen: destino["rutaImagen"],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
