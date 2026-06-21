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
        final colorMorado = Colors.purple.shade600;

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
                // --- TARJETA MODIFICADA: INGRESOS TOTALES EN TIEMPO REAL ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reservas')
                        .snapshots(),
                    builder: (context, reservasSnapshot) {
                      double ingresosCalculados = 0.0;

                      if (reservasSnapshot.hasData) {
                        for (var doc in reservasSnapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          // Sumamos el precio total real cobrado en la reserva
                          ingresosCalculados +=
                              (data['precioTotal'] ?? 0.0).toDouble();
                        }
                      }

                      return _TarjetaInfo(
                        titulo: 'Ingresos Totales',
                        // Formateamos el valor dinámicamente con sus decimales o limpio
                        valor:
                            '\$${ingresosCalculados.toStringAsFixed(ingresosCalculados % 1 == 0 ? 0 : 2)}',
                        color: colorAmarillo,
                        icono: Icons.attach_money,
                      );
                    },
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
                // TARJETA: USUARIOS QUE HAN COMPRADO
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reservas')
                        .snapshots(),
                    builder: (context, reservasSnapshot) {
                      int totalCompras = 0;
                      if (reservasSnapshot.hasData) {
                        totalCompras = reservasSnapshot.data!.docs.length;
                      }

                      return _TarjetaInfo(
                        titulo: 'Usuarios que han comprado',
                        valor: totalCompras.toString(),
                        color: colorMorado,
                        icono: Icons.person,
                        subtitulo: 'Historial de compras registradas',
                      );
                    },
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
  final VoidCallback? onTap;

  const _TarjetaInfo({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
    this.subtitulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                      subtitulo!,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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
