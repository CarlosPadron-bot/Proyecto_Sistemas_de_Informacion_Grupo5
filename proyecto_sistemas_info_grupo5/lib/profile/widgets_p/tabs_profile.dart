import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/reserva_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/reserva_model.dart';
import 'emptystate.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({Key? key}) : super(key: key);

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botones de Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: _buildToggleButton(
                    0, 'Mis Reservas', Icons.calendar_month)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildToggleButton(
                    1, 'Mis Reseñas', Icons.star_border_rounded)),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child:
              _activeTabIndex == 0 ? _buildReservasTab() : _buildResenasTab(),
        ),
      ],
    );
  }

  Widget _buildToggleButton(int index, String label, IconData icon) {
    bool isActive = _activeTabIndex == index;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF009933) : Colors.grey[100],
        foregroundColor: isActive ? Colors.white : Colors.black87,
        elevation: isActive ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _activeTabIndex = index),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReservasTab() {
    final ReservaService _reservaService = ReservaService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child:
            Center(child: Text('Debes iniciar sesión para ver tus reservas.')),
      );
    }

    return StreamBuilder<List<Reserva>>(
      stream: _reservaService.obtenerReservasPorUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFF009933))),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('Hubo un error al cargar tus reservas.')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            title: "No tienes reservas",
            subtitle: "Explora nuestros destinos y comienza tu aventura",
            icon: Icons.calendar_month,
          );
        }

        final listaReservas = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: listaReservas.length,
          itemBuilder: (context, index) {
            final reserva = listaReservas[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fila Superior: Datos, Imagen y Éxito
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: reserva.urlImagen.isNotEmpty
                                ? Image.network(
                                    reserva.urlImagen,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.image_not_supported,
                                            color: Colors.grey),
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reserva.destinoNombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: ${reserva.fechaCompra.day}/${reserva.fechaCompra.month}/${reserva.fechaCompra.year}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${reserva.precioTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: const Text(
                                'Éxito',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botón de escribir reseña
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Escribir reseña para ${reserva.destinoNombre}'),
                            backgroundColor: const Color(0xFF009933),
                          ),
                        );
                      },
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: const Color(0xFFFFCC00),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review,
                                color: Colors.black87, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Escribir Reseña',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResenasTab() {
    return const EmptyState(
      title: "No tienes reseñas",
      subtitle:
          "Aquí se mostrarán las opiniones que compartas sobre tus viajes",
      icon: Icons.star_border_rounded,
    );
  }
}
