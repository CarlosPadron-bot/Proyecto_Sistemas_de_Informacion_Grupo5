import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeccionTarjetasInfo extends StatelessWidget {
  final String operadorId;

  const SeccionTarjetasInfo({super.key, required this.operadorId});

  @override
  Widget build(BuildContext context) {
    // Usamos un StreamBuilder combinado para esperar ambos datos antes de renderizar
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('destinos')
          .where('operadorId', isEqualTo: operadorId)
          .snapshots(),
      builder: (context, destinoSnapshot) {
        if (destinoSnapshot.hasData) {
          debugPrint(
              "DEBUG: ¡ÉXITO! Se encontraron ${destinoSnapshot.data!.docs.length} documentos en 'destinos'.");
          for (var doc in destinoSnapshot.data!.docs) {
            debugPrint("DEBUG: Encontré destino con ID: ${doc.id}");
          }
        } else if (destinoSnapshot.hasError) {
          debugPrint("DEBUG: ERROR en Firestore: ${destinoSnapshot.error}");
        } else {
          debugPrint("DEBUG: Aún no hay datos (loading)");
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reservas')
              .where('operadorId', isEqualTo: operadorId)
              .snapshots(),
          builder: (context, reservasSnapshot) {
            // Muestra un loader mientras los datos se sincronizan
            if (destinoSnapshot.connectionState == ConnectionState.waiting ||
                reservasSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Lógica de cálculo de contadores
            int totalPublicaciones =
                destinoSnapshot.hasData ? destinoSnapshot.data!.docs.length : 0;
            int totalReservas = reservasSnapshot.hasData
                ? reservasSnapshot.data!.docs.length
                : 0;

            int alojamientos = 0;
            int paquetes = 0;
            double ingresos = 0.0;

            if (destinoSnapshot.hasData) {
              for (var doc in destinoSnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                if (data['categoria'] == 'Alojamientos') {
                  alojamientos++;
                } else {
                  paquetes++;
                }
              }
            }

            if (reservasSnapshot.hasData) {
              for (var doc in reservasSnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                double valorReserva =
                    (data['precioTotal'] ?? data['precio'] ?? 0.0).toDouble();

                ingresos += valorReserva;
              }
            }

            final colorVerde = Colors.green.shade600;
            final colorAzul = Colors.blue.shade600;
            final colorAmarillo = Colors.amber.shade700;
            final colorMorado = Colors.purple.shade600;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _TarjetaInfo(
                            titulo: 'Paquetes',
                            valor: paquetes.toString(),
                            color: colorVerde,
                            icono: Icons.inventory_2_outlined)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _TarjetaInfo(
                            titulo: 'Alojamientos',
                            valor: alojamientos.toString(),
                            color: colorAzul,
                            icono: Icons.home_outlined)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _TarjetaInfo(
                        titulo: 'Ingresos',
                        valor: '\$${ingresos.toStringAsFixed(0)}',
                        color: colorAmarillo,
                        icono: Icons.attach_money,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                        child: _TarjetaInfo(
                            titulo: 'Publicaciones',
                            valor: totalPublicaciones.toString(),
                            color: colorVerde,
                            icono: Icons.add,
                            subtitulo: 'Total servicios activos')),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _TarjetaInfo(
                            titulo: 'Reservas',
                            valor: totalReservas.toString(),
                            color: colorMorado,
                            icono: Icons.person,
                            subtitulo: 'Total historial de ventas')),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TarjetaInfo extends StatelessWidget {
  final String titulo, valor;
  final Color color;
  final IconData icono;
  final String? subtitulo;

  const _TarjetaInfo({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icono, color: Colors.white, size: 24),
              Text(valor,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          if (subtitulo != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitulo!,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
