import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import '../../homepage/widgets/item_card.dart';
import '../../modelos/destino_model.dart';

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
    // Escuchamos la colección de destinos completa
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

        // 1. Convertir los documentos a instancias de nuestro modelo Destino
        List<Destino> listaDestinos = snapshot.data!.docs.map((doc) {
          return Destino.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // 2. Aplicación de los Filtros del Sidebar del Viajero en memoria dinámicamente
        List<Destino> resultadosFiltrados = listaDestinos.where((destino) {
          // Filtro por Categoría (Paquete / Alojamiento)
          bool cumpleCategoria = true;
          if (categoriaFiltro != 'Todo') {
            // Mapeamos el filtro visual del frontend al guardado en base de datos
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
            child: Text(
                'No se encontraron destinos que coincidan con los filtros aplicados.'),
          );
        }

        // 3. Renderizado del catálogo dinámico
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Ideal para pantallas de escritorio/web unimet
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
                      priceSuffix: destino.categoria == 'Alojamientos'
                          ? '/noche'
                          : '/persona',
                      rating: "5.0", // Base inicial para maquetación de reseñas
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
                tipoPrecio:
                    destino.categoria == 'Alojamientos' ? '/noche' : '/persona',
                calificacion: 5.0,
                resenas: 0,
                categoria: destino.categoria,
                rutaImagen: destino.urlImagen,
              ),
            );
          },
        );
      },
    );
  }
}
