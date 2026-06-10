import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String titulo;
  final String ubicacion;
  final String infoExtra; // Ej: "3 días, 6 cupos" o "4 personas"
  final String precio;
  final String tipoPrecio; // Ej: "/persona" o "/noche"
  final double calificacion;
  final int resenas;
  final String categoria; // Ej: "Paquete", "posada"
  final String rutaImagen; // <-- NUEVO: Variable para la ruta de la imagen

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
    required this.rutaImagen, // <-- NUEVO: Se requiere al crear la tarjeta
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de la Imagen con Etiqueta
          Expanded(
            child: Stack(
              children: [
                // AQUI VA LA IMAGEN AHORA
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    // Usamos DecorationImage para poner la imagen de fondo en el contenedor
                    image: DecorationImage(
                      image: AssetImage(rutaImagen),
                      fit: BoxFit.cover, // Hace que la imagen llene todo el espacio sin deformarse
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green, // Color de la etiqueta
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sección de Textos
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(infoExtra, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('\$$precio', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(' $tipoPrecio', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('$calificacion', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(' ($resenas)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}