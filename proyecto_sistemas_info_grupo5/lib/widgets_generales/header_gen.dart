import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';

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
        IconButton(
          icon: const Icon(Icons.search,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            // Aquí irá la lógica para abrir el buscador o ir a la pantalla de búsqueda
            print("Buscar presionado");
          },
        ),
        const SizedBox(width: 4),

        // Botón de Inicio de Sesión
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
