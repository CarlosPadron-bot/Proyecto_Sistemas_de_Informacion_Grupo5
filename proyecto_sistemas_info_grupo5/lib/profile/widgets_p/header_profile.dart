import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/profile/editar_perfil.dart'; // Importamos Firestore

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
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

        String userName = "Usuario";
        String userRole = "viajero";
        String biografia = "¡Bienvenido a tu perfil de EcoRutas!";
        String? photoUrl;

        if (snapshot.hasData &&
            snapshot.data!.exists &&
            snapshot.data!.data() != null) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['username'] ?? "Usuario";
          userRole = data['rol'] ?? "viajero";
          biografia = data['biografia'] ?? "Sin biografía definida todavía.";
          photoUrl = data['photoUrl'];
        }

        String inicialNombre =
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Container(
          padding: const EdgeInsets.all(24),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR DEL USUARIO
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF009933).withOpacity(0.1),
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Text(
                        inicialNombre,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009933),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              //Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRoleBadge(userRole),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentUser.email ?? '',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      biografia,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Lógica para editar perfil <-- Gracias al que puso esto aqui :)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditarPerfilPage()),
                  );
                },
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Editar Perfil',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
        style: TextStyle(
            color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}
