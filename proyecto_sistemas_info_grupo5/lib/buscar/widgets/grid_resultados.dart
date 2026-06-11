import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import '../../homepage/widgets/item_card.dart';

class GridResultados extends StatelessWidget {
  final String categoriaFiltro;
  final double precioMaxFiltro;
  final String estadoFiltro;
  final double calificacionMinFiltro;

  const GridResultados({
    super.key,
    required this.categoriaFiltro,
    required this.precioMaxFiltro,
    required this.estadoFiltro,
    required this.calificacionMinFiltro,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> destinos = [
      // Sección de paquetes
      {
        'titulo': 'Isla la Tortuga',
        'ubicacion': 'Dependencias Federales',
        'info': '3 días · 6 cupos',
        'precio': '150',
        'tipo': '/persona',
        'calificacion': 4.8,
        'resenas': 24,
        'estado': 'Todos',
        'categoria': 'Paquetes Turisticos',
        'rutaImagen': 'assets/isla_la_tortuga.png',
      },
      {
        'titulo': 'Morrocoy',
        'ubicacion': 'Falcón',
        'info': '2 días · 10 cupos',
        'precio': '80',
        'tipo': '/persona',
        'calificacion': 4.7,
        'resenas': 42,
        'estado': 'Falcón',
        'categoria': 'Paquetes Turisticos',
        'rutaImagen': 'assets/morrocoy.png',
      },
      {
        'titulo': 'Roraima',
        'ubicacion': 'Bolívar',
        'info': '6 días · 4 cupos',
        'precio': '350',
        'tipo': '/persona',
        'calificacion': 4.9,
        'resenas': 18,
        'estado': 'Bolívar',
        'categoria': 'Paquetes Turisticos',
        'rutaImagen': 'assets/salto_angel.png',
      },
      {
        'titulo': 'Los Roques',
        'ubicacion': 'Dependencias Federales',
        'info': '4 días · 8 cupos',
        'precio': '299',
        'tipo': '/persona',
        'calificacion': 4.9,
        'resenas': 56,
        'estado': 'Todos',
        'categoria': 'Paquetes Turisticos',
        'rutaImagen': 'assets/los_roques.png',
      },
      // Sección de alojamientos
      {
        'titulo': 'Galipan',
        'ubicacion': 'La Guaira',
        'info': 'Habitaciones confortables',
        'precio': '45',
        'tipo': '/noche',
        'calificacion': 4.5,
        'resenas': 28,
        'estado': 'Caracas',
        'categoria': 'Alojamientos',
        'rutaImagen': 'assets/humbolt.png',
      },
      {
        'titulo': 'Canaima',
        'ubicacion': 'Parque Nacional Canaima',
        'info': 'Cabañas y habitaciones',
        'precio': '60',
        'tipo': '/noche',
        'calificacion': 4.6,
        'resenas': 31,
        'estado': 'Todos',
        'categoria': 'Alojamientos',
        'rutaImagen': 'assets/posada.png',
      },
      {
        'titulo': 'Mérida',
        'ubicacion': 'Mérida',
        'info': 'Hermosa vista a las montañas',
        'precio': '50',
        'tipo': '/noche',
        'calificacion': 4.8,
        'resenas': 19,
        'estado': 'Mérida',
        'categoria': 'Alojamientos',
        'rutaImagen': 'assets/caba_merida.png',
      },
    ];

    final destinosFiltrados = destinos.where((dest) {
      // Categoría
      final bool cumpleCategoria =
          (categoriaFiltro == 'Todo' || dest['categoria'] == categoriaFiltro);

      // Presupuesto
      final double precioDestino =
          double.tryParse(dest['precio'] ?? '0') ?? 0.0;
      final bool cumplePrecio = precioDestino <= precioMaxFiltro;

      // Estado del país
      final bool cumpleEstado =
          (estadoFiltro == 'Todos' || dest['estado'] == estadoFiltro);

      // Calificación
      final double calificacionDestino =
          (dest['calificacion'] as num).toDouble();
      final bool cumpleCalificacion =
          calificacionDestino >= calificacionMinFiltro;

      return cumpleCategoria &&
          cumplePrecio &&
          cumpleEstado &&
          cumpleCalificacion;
    }).toList();

    if (destinosFiltrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No se encontraron resultados que coincidan con los filtros aplicados.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultados encontrados: ${destinosFiltrados.length}',
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: destinosFiltrados.length,
            itemBuilder: (context, index) {
              final destino = destinosFiltrados[index];
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
