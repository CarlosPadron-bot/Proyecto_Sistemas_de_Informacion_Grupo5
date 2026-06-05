import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/DetalleDestinoPage.dart';

class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String title;
  final String subtitle;
  final String price;
  final String priceSuffix;
  final String rating;
  final String reviewCount;

  const ItemCard({
    Key? key,
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceSuffix,
    required this.rating,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MouseRegion altera el tipo de cursor del ratón sobre la vista
    return MouseRegion(
      cursor: SystemMouseCursors
          .click, // Cambia el puntero para saber que es seleccionable
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleDestinoPage(
                title: title,
                location: location,
                price: price,
                priceSuffix: priceSuffix,
                rating: rating,
                reviewCount: reviewCount,
                imageUrl: imageUrl,
                description:
                    'Descubre la magia de este increíble destino sustentable en Venezuela. Una experiencia única diseñada para conectar con la naturaleza de forma responsable.',
                includes: const [
                  'Guía certificado',
                  'Transporte ida y vuelta',
                  'Almuerzo típico',
                  'Entradas a los parques'
                ],
              ),
            ),
          );
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de placeholder (cambiar por NetworkImage cuando uses datos reales)
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(location,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(subtitle,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$$price',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600])),
                            Text(' $priceSuffix',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(rating,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(' ($reviewCount)',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
