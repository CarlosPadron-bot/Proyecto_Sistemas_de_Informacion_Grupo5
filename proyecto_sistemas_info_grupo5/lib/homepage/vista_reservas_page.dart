import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Servicios/reserva_service.dart';
import '../modelos/reserva_model.dart';

class VistaReservasPage extends StatelessWidget {
  const VistaReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReservaService _reservaService = ReservaService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis Viajes - EcoRutas'),
        backgroundColor: const Color(0xFF009933),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(
              child: Text('Debes iniciar sesión para ver tus reservas.'),
            )
          : StreamBuilder<List<Reserva>>(
              stream: _reservaService.obtenerReservasPorUsuario(user.uid), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF009933)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No tienes viajes ni reservas registradas todavía. 🗺️',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final listaReservas = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listaReservas.length,
                  itemBuilder: (context, index) {
                    final reserva = listaReservas[index];
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          // Imagen miniatura del destino comprado
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              reserva.urlImagen.isNotEmpty
                                  ? reserva.urlImagen
                                  : 'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800&auto=format&fit=crop',
                              width: 110,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 110,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          // Detalles de la reserva
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0), // <-- ¡CORREGIDO! Solo una vez
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reserva.destinoNombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cliente: ${user.email}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fecha: ${reserva.fechaCompra.day}/${reserva.fechaCompra.month}/${reserva.fechaCompra.year}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Precio Pagado
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${reserva.precioTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Éxito',
                                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}