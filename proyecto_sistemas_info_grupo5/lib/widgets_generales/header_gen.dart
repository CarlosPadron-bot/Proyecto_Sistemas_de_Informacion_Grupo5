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
      automaticallyImplyLeading:
          false, // Evita que Flutter ponga una flecha de volver atrás automática

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
            // Remueve todas las pantallas anteriores de la pila y redirige a la HomePage de forma limpia
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.home,
              color: Color.fromARGB(255, 255, 255, 255), size: 20),
          label: const Text(
            'Inicio',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w600),
          ),
        ),

        // Botón de Buscador
        TextButton.icon(
          // Lo cambié a TextButton.icon para que diga "Buscar" al lado del ícono
          onPressed: () {
            // Navega a la página de búsqueda
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuscarPage()),
            );
          },
          icon: const Icon(Icons.search,
              color: Color.fromARGB(255, 255, 255, 255), size: 20),
          label: const Text(
            'Buscar',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
            width: 16), // Un poco más de espacio antes del botón verde

        // Botón de Inicio de Sesión
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
        // Si no hay sesión, muestra el botón de "Iniciar Sesión"
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

        // Si hay sesión se busca el rol y nombre en Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
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

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Icon(Icons.error, color: Colors.white);
            }

            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String username = userData['username'] ?? 'Usuario';
            String rol = userData['rol'] ?? 'Viajero';

            // Botón con el nombre y el rol
            return ElevatedButton.icon(
              onPressed: () {
                // AQUÍ VA LA LÓGICA PARA EL PERFIL DE USUARIO 👀👀👀👀👀
                // Navegamos a la pantalla de perfil que acabamos de refactorizar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF009933),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.person),
              label: Text(
                "$username ($rol)",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
