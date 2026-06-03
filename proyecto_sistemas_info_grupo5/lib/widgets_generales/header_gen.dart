import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../homepage/home_page.dart'; 

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1, // Añade una leve sombra/borde inferior elegante
      automaticallyImplyLeading: false, // Evita que Flutter ponga una flecha de volver atrás automática
      
      // LADO IZQ: Logo y Nombre
      title: Row(
        children: [
          Image.asset(
            'assets/logo_rutas.png',
            height: 35,
          ),
          const SizedBox(width: 10),
          const Text(
            'RutasVzla',
            style: TextStyle(
              color: Color(0xFF009933),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      
      // LADO DERECHO: Botones de acciones
      actions: [
        // Botón de Inicio (Regresar a la pag principal)
        TextButton.icon(
          onPressed: () {
            // Verifica si ya estás en la HomePage para no duplicar la pantalla en el stack
            if (ModalRoute.of(context)?.settings.name != '/') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.home, color: Colors.grey, size: 20),
          label: const Text(
            'Inicio',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        
        // Botón de Buscador
        IconButton(
          icon: const Icon(Icons.search, color: Colors.grey),
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
              backgroundColor: const Color(0xFF009933), // Tu verde corporativo
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