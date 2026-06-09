import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // BOTONES EN LA PARTE SUPERIOR (Toggle)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildToggleButton(0, 'Mis Reservas', Icons.calendar_month)),
            const SizedBox(width: 16),
            Expanded(child: _buildToggleButton(1, 'Mis Reseñas', Icons.star_border_rounded)),
          ],
        ),
        const SizedBox(height: 24), // Espacio entre los botones y la caja de contenido
        
        // CAJA BLANCA CON EL CONTENIDO (Reservas o Reseñas)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: _buildTabContent(),
        ),
      ],
    );
  }

  // Lógica visual del botón superior
  Widget _buildToggleButton(int index, String title, IconData icon) {
    final bool isActive = _activeTabIndex == index;
    return ElevatedButton.icon(
      onPressed: () => setState(() => _activeTabIndex = index),
      icon: Icon(icon, color: isActive ? Colors.white : const Color(0xFF4B5563)),
      label: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : const Color(0xFF4B5563),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF009933) : const Color(0xFFE5E7EB),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Error: No hay sesión activa"));
    }

    if (_activeTabIndex == 0) {
      // PESTAÑA 0: RESERVAS DESDE FIRESTORE
      return _buildReservasStream(currentUser.uid);
    } else {
      // PESTAÑA 1: REVIEWS DEL USUARIO (POR AHORA VACÍA)
      return const EmptyState(
        title: "No has escrito reseñas aún",
        subtitle: "Tus opiniones sobre los destinos visitados aparecerán aquí.",
        icon: Icons.star_border_rounded,
      );
    }
  }

  Widget _buildReservasStream(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservas')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF009933)));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Hubo un error al cargar tus reservas.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(
            title: "No tienes reservas",
            subtitle: "Explora nuestros destinos y comienza tu aventura",
            icon: Icons.calendar_month,
          );
        }

        final reservas = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            var reservaData = reservas[index].data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(Icons.map, color: Color(0xFF009933)),
                title: Text(
                  reservaData['destino'] ?? 'Destino en proceso',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Fecha: ${reservaData['fecha'] ?? 'Por definir'}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            );
          },
        );
      },
    );
  }
}