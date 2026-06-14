import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/login/login_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/login/auth_wrapper.dart'; 
import 'package:proyecto_sistemas_info_grupo5/buscar/buscar_page.dart'; 
import 'package:proyecto_sistemas_info_grupo5/profile/profile_screen.dart'; 
import 'package:proyecto_sistemas_info_grupo5/admin/panel_admin.dart'; 
import 'package:proyecto_sistemas_info_grupo5/operador/panel_operador.dart'; 

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF009933),
      elevation: 2,
      automaticallyImplyLeading: false, 

      // Logo y Nombre
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo_rutas.png',
            height: 50, // Un poco más pequeño para dar espacio a los botones
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.flight_takeoff, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'RutasVzla',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),

      // Botones de acciones
      actions: [
        // Botón de Inicio
        TextButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AuthWrapper()), 
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.home, color: Colors.white, size: 18),
          label: const Text(
            'Inicio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),

        // Botón de Buscador
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuscarPage()),
            );
          },
          icon: const Icon(Icons.search, color: Colors.white, size: 18),
          label: const Text(
            'Buscar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        
        const SizedBox(width: 8),

        // Zona dinámica: Botón de Iniciar Sesión o (Paneles + Nombre + Salir)
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: _buildAuthButton(context),
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Si NO hay sesión iniciada, muestra el botón de "Iniciar Sesión"
        if (!snapshot.hasData) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009933),
              foregroundColor: Colors.white,
              elevation: 0,
              side: const BorderSide(color: Colors.white, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        // 2. Si SÍ hay sesión, busca los datos en Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            }

            String username = 'Usuario';
            String rol = 'viajero'; 

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              username = userData['username'] ?? 'Usuario';
              // Convertimos a minúsculas para evitar fallos si en la DB dice "Operador" u "Operator"
              rol = (userData['rol'] ?? 'viajero').toString().trim().toLowerCase();
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- BOTÓN EXCLUSIVO PARA ADMINISTRADOR ---
                if (rol == 'admin' || rol == 'administrador') ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PanelAdmin()),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                    label: const Text(
                      'Admin',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],

                // --- BOTÓN EXCLUSIVO PARA OPERADOR ---
                if (rol == 'operador') ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PanelOperador()), 
                      );
                    },
                    icon: const Icon(Icons.dashboard, color: Colors.white, size: 18),
                    label: const Text(
                      'Panel Operador',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],

                // --- BOTÓN DE PERFIL (Para todos) ---
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                  label: Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                
                const SizedBox(width: 4),

                // --- BOTÓN DE SALIR (Para todos) ---
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                  label: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}