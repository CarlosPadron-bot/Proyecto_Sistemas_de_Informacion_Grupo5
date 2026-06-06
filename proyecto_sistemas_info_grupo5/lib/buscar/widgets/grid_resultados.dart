import 'package:flutter/material.dart';

class GridResultados extends StatelessWidget {
  const GridResultados({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('11 resultados encontrados', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: 8, // Cantidad de tarjetas de prueba
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Ajusta este número si quieres las tarjetas más altas o bajas
            ),
            itemBuilder: (context, index) {
              
              // --- TARJETA DE PRUEBA TEMPORAL ---
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Espacio gris simulando la imagen
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey, size: 50),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destino de Prueba',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '3 días - 6 cupos',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$280 / persona',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              // -----------------------------------
              
            },
          ),
        ),
      ],
    );
  }
}