import 'package:flutter/material.dart';
import '../Servicios/reserva_service.dart';
import '../modelos/reserva_model.dart';

class VistaReservasPage extends StatelessWidget {
  const VistaReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReservaService _reservaService = ReservaService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Reservas - EcoRutas'),
        backgroundColor: const Color(0xFF009933),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Reserva>>(
        stream: _reservaService.obtenerTodasLasReservas(), // Escucha activa a Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay transacciones ni reservas registradas todavía. 🗺️',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF009933),
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(
                    reserva.destinoNombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cliente: ${reserva.usuarioCorreo}\nViajeros: ${reserva.cantidadViajeros} | Fecha: ${reserva.fechaReserva.toLocal().toString().split('.')[0]}',
                  ),
                  trailing: Text(
                    '\$${reserva.precioPagado.toStringAsFixed(2)} USD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 16,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}