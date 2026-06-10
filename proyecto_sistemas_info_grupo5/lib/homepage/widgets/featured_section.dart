import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';
import 'item_card.dart';

class FeaturedSection extends StatelessWidget {
  final String title;
  final bool isAccommodation;
  final Color? backgroundColor;

  const FeaturedSection({
    Key? key,
    required this.title,
    required this.isAccommodation,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Usamos ListView horizontal o Column. Aquí un ListView para formato carrusel
          SizedBox(
            height: 350, // Altura fija para el carrusel de tarjetas
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Equivale a mockPackages.slice(0, 3)
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16.0),
                  // Envolvemos el ItemCard en un InkWell
                  child: InkWell(
                    onTap: () {
                      // Navegación a la pantalla de detalle
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleDestinoPage(
                            title: isAccommodation
                                ? 'Posada El Valle'
                                : 'Tour Páramo',
                            location: 'Mérida, Mérida',
                            price: isAccommodation ? '25' : '120',
                            priceSuffix:
                                isAccommodation ? '/noche' : '/persona',
                            rating: '4.8',
                            reviewCount: '24',
                            imageUrl: isAccommodation ? "assets/posada.png" : "assets/merida.png",
                                 // Asegúrate de pasar la URL si la tienes
                            description: 'Descripción detallada...',
                            includes: const ['Desayuno', 'Guía'],
                          ),
                        ),
                      );
                    },
                    child: ItemCard(
                      ubicacion: 'Mérida, Mérida',
                      titulo:
                          isAccommodation ? 'Posada El Valle' : 'Tour Páramo',
                      infoExtra: isAccommodation
                          ? 'Posada • hasta 4 personas'
                          : '3 días • hasta 10 personas',
                      precio: isAccommodation ? '25' : '120',
                      tipoPrecio: isAccommodation ? '/noche' : '/persona',
                      calificacion: 4.8,
                      resenas: 24,
                      categoria: isAccommodation ? 'Posada' : 'Paquete',
                      rutaImagen: isAccommodation ? 'assets/posada.png' : 'assets/merida.png',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAccommodation
                        ? 'Ver todos los alojamientos'
                        : 'Ver todos los paquetes',
                    style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.green[600], size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
