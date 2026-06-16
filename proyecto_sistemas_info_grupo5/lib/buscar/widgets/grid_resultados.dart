import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import '../../homepage/widgets/item_card.dart';
import '../../modelos/destino_model.dart';
import 'dart:convert';

class GridResultados extends StatelessWidget {
  final String categoriaFiltro; // 'Todo', 'Paquetes Turisticos', 'Alojamientos'
  final double precioMaxFiltro;
  final String estadoFiltro; // 'Todos', 'Mérida', etc.
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF009933)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No hay destinos publicados por el momento.'));
        }

        List<Destino> listaDestinos = snapshot.data!.docs.map((doc) {
          return Destino.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        List<Destino> resultadosFiltrados = listaDestinos.where((destino) {
          // Filtro por Categoría
          bool cumpleCategoria = true;
          if (categoriaFiltro != 'Todo') {
            String catNormalizada = (categoriaFiltro == 'Paquetes Turisticos' ||
                    categoriaFiltro == 'Paquetes')
                ? 'Paquetes Turisticos'
                : 'Alojamientos';
            cumpleCategoria = (destino.categoria == catNormalizada);
          }

          // Filtro por Precio Máximo
          bool cumplePrecio = destino.precio <= precioMaxFiltro;

          // Filtro por Estado de Venezuela
          bool cumpleEstado =
              (estadoFiltro == 'Todos' || destino.estado == estadoFiltro);

          return cumpleCategoria && cumplePrecio && cumpleEstado;
        }).toList();

        if (resultadosFiltrados.isEmpty) {
          return const Center(
            child: Text('No se encontraron destinos que coincidan con los filtros aplicados.'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: resultadosFiltrados.length,
          itemBuilder: (context, index) {
            final destino = resultadosFiltrados[index];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleDestinoPage(
                      title: destino.nombre,
                      location: destino.ubicacion,
                      price: destino.precio.toStringAsFixed(0),
                      priceSuffix: destino.categoria == 'Alojamientos' ? '/noche' : '/persona',
                      rating: "5.0", 
                      reviewCount: "0",
                      imageUrl: destino.urlImagen,
                      description: destino.descripcion,
                      includes: destino.queIncluye,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: ItemCard(
                titulo: destino.nombre,
                ubicacion: destino.ubicacion,
                infoExtra: destino.infoExtra,
                precio: destino.precio.toStringAsFixed(0),
                tipoPrecio: destino.categoria == 'Alojamientos' ? '/noche' : '/persona',
                calificacion: 5.0,
                resenas: 0,
                categoria: destino.categoria,
                rutaImagen: destino.urlImagen, // Se envía la metadata de la imagen aquí
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET ITEMCARD MODIFICADO CON TU LÓGICA DE DETECCIÓN DE IMAGEN ---
class ItemCard extends StatelessWidget {
  final String titulo;
  final String ubicacion;
  final String infoExtra;
  final String precio;
  final String tipoPrecio;
  final double calificacion;
  final int resenas;
  final String categoria;
  final String rutaImagen;

  const ItemCard({
    super.key,
    required this.titulo,
    required this.ubicacion,
    required this.infoExtra,
    required this.precio,
    required this.tipoPrecio,
    required this.calificacion,
    required this.resenas,
    required this.categoria,
    required this.rutaImagen,
  });

  // TU FUNCIÓN ADAPTADA PARA EL TAMAÑO DE LA TARJETA
  Widget _buildImage(String ruta) {
    if (ruta.isEmpty) {
      return const Center(
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey));
    }

    if (ruta.startsWith('base64,')) {
      try {
        return Image.memory(
          base64Decode(ruta.substring(7)),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity, // Ocupa todo el espacio asignado en el diseño superior de la tarjeta
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
        );
      } catch (e) {
        return const Center(
            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey));
      }
    } else {
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONTENEDOR DE LA IMAGEN
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImage(rutaImagen), // Llamado a la función de renderizado inteligente
              ),
            ),
          ),
          // CONTENIDO DE TEXTO DE LA TARJETA
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$$precio$tipoPrecio',
                        style: const TextStyle(
                            color: Color(0xFF009933),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            calificacion.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}