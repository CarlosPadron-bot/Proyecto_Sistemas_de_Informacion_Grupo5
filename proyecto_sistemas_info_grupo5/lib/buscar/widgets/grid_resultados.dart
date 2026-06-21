import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
<<<<<<< HEAD
import 'package:proyecto_sistemas_info_grupo5/homepage/widgets/item_card.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
=======
import '../../modelos/destino_model.dart';
import 'dart:convert';
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db

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
<<<<<<< HEAD
          return Destino.fromFirestore(doc);
        }).toList();

        List<Destino> resultadosFiltrados = listaDestinos.where((destino) {
=======
          return Destino.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        List<Destino> resultadosFiltrados = listaDestinos.where((destino) {
          int cuposDisponibles = 1;
          if (destino.infoExtra.contains('|')) {
            String textoCupos = destino.infoExtra.split('|')[0];
            cuposDisponibles =
                int.tryParse(textoCupos.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          }

          if (cuposDisponibles <= 0) return false;

          // Filtro por Categoría
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
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
<<<<<<< HEAD
            child: Text('No se encontraron destinos que coincidan con los filtros.'),
=======
            child: Text(
                'No se encontraron destinos que coincidan con los filtros aplicados.'),
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
<<<<<<< HEAD
            childAspectRatio: 0.78, 
=======
            childAspectRatio: 0.82,
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
          ),
          itemCount: resultadosFiltrados.length,
          itemBuilder: (context, index) {
            final destino = resultadosFiltrados[index];
            final List<String> incluye = destino.queIncluye;
            final String tipoPrecio = destino.categoria == 'Alojamientos' ? '/noche' : '/persona';

<<<<<<< HEAD
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
=======
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resenas')
                  .where('destinoId', isEqualTo: destino.nombre)
                  .snapshots(),
              builder: (context, resenaSnapshot) {
                double promedioRating = 0.0;
                int cantidadResenas = 0;

                if (resenaSnapshot.hasData &&
                    resenaSnapshot.data!.docs.isNotEmpty) {
                  final resenasDocumentos = resenaSnapshot.data!.docs;
                  cantidadResenas = resenasDocumentos.length;

                  double sumaCalificaciones = 0;
                  for (var doc in resenasDocumentos) {
                    var data = doc.data() as Map<String, dynamic>;
                    sumaCalificaciones +=
                        (data['calificacion'] ?? 0).toDouble();
                  }
                  promedioRating = sumaCalificaciones / cantidadResenas;
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleDestinoPage(
                          title: destino.nombre,
                          location: destino.ubicacion,
                          price: destino.precio.toStringAsFixed(0),
                          infoExtra: destino.infoExtra,
                          rating: promedioRating.toStringAsFixed(1),
                          reviewCount: cantidadResenas.toString(),
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
                    tipoPrecio: destino.categoria == 'Alojamientos'
                        ? '/noche'
                        : '/persona',
                    calificacion: promedioRating,
                    resenas: cantidadResenas,
                    categoria: destino.categoria == 'Paquetes Turisticos'
                        ? 'Paquete'
                        : 'Alojamiento',
                    rutaImagen: destino.urlImagen,
                  ),
                );
              },
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
            );
          },
        );
      },
    );
  }
<<<<<<< HEAD
}
=======
}

// ==========================================
// WIDGET ITEMCARD ACTUALIZADO
// ==========================================
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
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported,
                  size: 40, color: Colors.grey)),
        );
      } catch (e) {
        return const Center(
            child:
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey));
      }
    } else {
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
            child:
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Procesamos el desglose de cupos y fechas para mostrarlo limpiamente abajo
    String cuposTexto = "Cupos variables";
    String fechaTexto = "Fecha flexible";
    if (infoExtra.contains('|')) {
      List<String> partes = infoExtra.split('|');
      cuposTexto = partes[0].trim().toLowerCase().contains('cupo')
          ? partes[0].trim()
          : '${partes[0].trim()} Cupos';
      fechaTexto = partes[1].trim();
    }

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImage(rutaImagen),
              ),
            ),
          ),
          // CONTENIDO DE TEXTO DE LA TARJETA
          Expanded(
            flex: 5,
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 15, color: Colors.blueGrey),
                      const SizedBox(width: 3),
                      Text(
                        cuposTexto,
                        style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today_outlined,
                          size: 15, color: Colors.blueGrey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          fechaTexto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 15),
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
                            resenas == 0
                                ? '0.0'
                                : calificacion.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            ' ($resenas)',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
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
>>>>>>> 278bd9f14ac1161280cd9265f5144fd4cda176db
