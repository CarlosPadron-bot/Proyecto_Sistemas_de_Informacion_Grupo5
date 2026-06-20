import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/widgets/item_card.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

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
          return Destino.fromFirestore(doc);
        }).toList();

        List<Destino> resultadosFiltrados = listaDestinos.where((destino) {
          bool cumpleCategoria = true;
          if (categoriaFiltro != 'Todo') {
            String catNormalizada = (categoriaFiltro == 'Paquetes Turisticos' ||
                    categoriaFiltro == 'Paquetes')
                ? 'Paquetes Turísticos'
                : 'Alojamientos';
            cumpleCategoria = (destino.categoria == catNormalizada);
          }

          bool cumplePrecio = destino.precio <= precioMaxFiltro;
          bool cumpleEstado = (estadoFiltro == 'Todos' || destino.estado == estadoFiltro);
          bool cumpleCalificacion = destino.calificacion >= calificacionMinFiltro;

          return cumpleCategoria && cumplePrecio && cumpleEstado && cumpleCalificacion;
        }).toList();

        if (resultadosFiltrados.isEmpty) {
          return const Center(
            child: Text('No se encontraron destinos que coincidan con los filtros.'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78, 
          ),
          itemCount: resultadosFiltrados.length,
          itemBuilder: (context, index) {
            final destino = resultadosFiltrados[index];
            final List<String> incluye = destino.queIncluye;
            final String tipoPrecio = destino.categoria == 'Alojamientos' ? '/noche' : '/persona';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleDestinoPage(
                      title: destino.nombre,
                      location: destino.ubicacion,
                      price: destino.precio.toString(),
                      priceSuffix: tipoPrecio, 
                      rating: destino.calificacion.toString(), 
                      reviewCount: '0', 
                      imageUrl: destino.urlImagen, 
                      description: destino.descripcion,
                      includes: incluye, 
                    ),
                  ),
                );
              },
              child: ItemCard(
                titulo: destino.nombre,
                ubicacion: destino.ubicacion,
                infoExtra: destino.infoExtra,
                precio: destino.precio.toString(),
                tipoPrecio: tipoPrecio,
                calificacion: destino.calificacion,
                resenas: 0,
                categoria: destino.categoria == 'Alojamientos' ? 'Alojamiento' : 'Paquete',
                rutaImagen: destino.urlImagen,
              ),
            );
          },
        );
      },
    );
  }
}