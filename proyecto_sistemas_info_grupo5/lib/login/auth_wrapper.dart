import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/auth.dart';
import 'package:proyecto_sistemas_info_grupo5/login/login_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';

class AuthWrapper extends StatelessWidget {
  final Auth _authService = Auth();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges, // Escucha el estado de la sesión
      builder: (context, snapshot) {
        // 1. Mientras Firebase lee el almacenamiento del teléfono, muestra pantalla de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00B14F)),
            ),
          );
        }

        // 2. ¡SESIÓN DETECTADA! Si hay datos, el usuario ya estaba logueado, lo mandamos al HomePage directamente.
        if (snapshot.hasData) {
          return const HomePage(); 
        }

        // 3. NO HAY SESIÓN: El usuario no está logueado, lo mandamos al Login.
        return const LoginScreen();
      },
    );
  }
}
