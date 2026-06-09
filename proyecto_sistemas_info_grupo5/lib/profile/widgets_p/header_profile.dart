import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importamos Firestore

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. 
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink(); // Si no hay sesión, no muestra nada
    }

    // 2. Buscamos los datos adicionales (username y rol) en Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        // Mientras consulta la base de datos, muestra un indicador de carga ligero
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF009933)),
            ),
          );
        }

        // Valores por defecto por si el documento aún no existe en Firestore
        String userName = "Usuario";
        String userRole = "traveler";
        String userEmail = currentUser.email ?? "correo@ejemplo.com";

        // Si el documento existe, extraemos los datos reales
        if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          userName = userData['username'] ?? 'Usuario';
          userRole = userData['rol'] ?? 'traveler';
        }

        // Extraemos la primera letra para el Avatar
        final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

        return Container(
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
          padding: const EdgeInsets.all(32.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFF009933),
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),
                    // Pasamos el rol real de Firestore al Badge
                    _buildRoleBadge(userRole),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Lógica para editar perfil
                },
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: const Color(0xFFF9FAFB),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrador':
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        label = 'Administrador';
        break;
      case 'operator':
      case 'operador':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        label = 'Operador';
        break;
      default:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        label = 'Viajero';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
            label,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}