import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeccionTarjetasInfo extends StatelessWidget {
  const SeccionTarjetasInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
      builder: (context, snapshot) {
        int totalPublicaciones = 0;
        int alojamientos = 0;
        int paquetes = 0;

        if (snapshot.hasData) {
          totalPublicaciones = snapshot.data!.docs.length;
          
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['categoria'] == 'Alojamientos') {
              alojamientos++;
            } else {
              paquetes++;
            }
          }
        }

        final colorVerde = Colors.green.shade600;
        final colorAzul = Colors.blue.shade600;
        final colorAmarillo = Colors.amber.shade700;

        return Column(
          children: [
            // FILA 1
            Row(
              children: [
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Paquetes Activos',
                    valor: paquetes.toString(),
                    color: colorVerde,
                    icono: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Alojamientos',
                    valor: alojamientos.toString(),
                    color: colorAzul,
                    icono: Icons.home_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Ingresos Totales',
                    valor: '\$400',
                    color: colorAmarillo,
                    icono: Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // FILA 2
            Row(
              children: [
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Publicaciones',
                    valor: totalPublicaciones.toString(),
                    color: colorVerde,
                    icono: Icons.add,
                    subtitulo: 'Gestionar paquetes y alojamientos',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Calendario',
                    valor: '3',
                    color: colorAzul,
                    icono: Icons.calendar_today,
                    subtitulo: 'Ver itinerarios y reservas',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _TarjetaInfo(
                    titulo: 'Ingresos',
                    valor: '\$400',
                    color: colorAmarillo,
                    icono: Icons.credit_card,
                    subtitulo: 'Gestión de costos y PayPal',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Widget privado para el molde interno de cada tarjeta
class _TarjetaInfo extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;
  final String? subtitulo;
  final VoidCallback? onTap; // Variable para detectar el clic en el futuro

  const _TarjetaInfo({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
    this.subtitulo,
    this.onTap, // Añadido al constructor
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Material para que el color base permita ver el efecto del InkWell
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap, // Aquí se conectará tu futura navegación
        borderRadius: BorderRadius.circular(8), // Redondea la animación del clic
        child: Container(
          padding: const EdgeInsets.all(16),
          // Ya no necesitamos el color aquí porque el Material lo maneja
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icono, color: Colors.white, size: 28),
                  Text(
                    valor,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitulo!, // El '!' le dice a Flutter que estamos seguros de que no es null aquí
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}