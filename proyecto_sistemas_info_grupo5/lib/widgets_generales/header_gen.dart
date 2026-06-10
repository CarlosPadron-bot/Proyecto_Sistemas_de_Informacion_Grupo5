import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';
import '../buscar/buscar_page.dart';
import '../profile/profile_screen.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF009933),
      elevation: 2,
      automaticallyImplyLeading: false, // Evita la flecha de volver atrás automática

      // Logo y Nombre
      title: Row(
        children: [
          Image.asset(
            'assets/logo_rutas.png',
            height: 60,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.flight_takeoff, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'RutasVzla',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.home, color: Colors.white, size: 20),
          label: const Text(
            'Inicio',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600),
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
          icon: const Icon(Icons.search, color: Colors.white, size: 20),
          label: const Text(
            'Buscar',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
        ),
        
        const SizedBox(width: 16),

        // Zona dinámica: Botón de Iniciar Sesión o (Nombre + Salir)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Muestra un indicador de carga mientras lee la base de datos
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            }

            // Extraemos el nombre. Si hay error o no existe, ponemos 'Usuario' por defecto
            String username = 'Usuario';
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              username = userData['username'] ?? 'Usuario';
            }

            // Retornamos la fila con el Nombre y el botón de Salir 
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón del Nombre (lleva al perfil)
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
                
                const SizedBox(width: 5),

                // Botón de Salir
                TextButton.icon(
                  onPressed: () async {
                    // 1. Cierra sesión en Firebase
                    await FirebaseAuth.instance.signOut();
                    
                    // 2. Devuelve a la pantalla de Login y borra el historial
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