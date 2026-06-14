import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/auth.dart';
import 'package:proyecto_sistemas_info_grupo5/login/login_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';
import 'package:proyecto_sistemas_info_grupo5/operador/operador_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  final Auth _authService = Auth();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges, // Escucha el estado de la sesión activa
      builder: (context, authSnapshot) {
        // 1. Cargando estado de autenticación
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00B14F)),
            ),
          );
        }

        // 2. ¡SESIÓN DETECTADA! Evaluamos el rol guardado en Firestore de forma asíncrona
        if (authSnapshot.hasData && authSnapshot.data != null) {
          return FutureBuilder<String?>(
            future: _authService.obtenerRol(authSnapshot.data!.uid),
            builder: (context, roleSnapshot) {
              // Mientras descarga el rol de Firestore, muestra pantalla de carga elegante
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B14F)),
                  ),
                );
              }

              // Si obtuvo el rol con éxito, decide la vista raíz
              if (roleSnapshot.hasData && roleSnapshot.data != null) {
                String rolNormalizado = roleSnapshot.data!.toLowerCase();

                if (rolNormalizado == 'admin') {
                  return const AdminDashboard();
                } else if (rolNormalizado == 'operador') {
                  return const OperadorDashboard();
                } else {
                  return const HomePage(); // Viajero
                }
              }

              // En caso de error crítico al leer el rol, se le fuerza al login preventivamente
              return const LoginScreen();
            },
          );
        }

        // 3. NO HAY SESIÓN: El usuario no está logueado, directo al Login.
        return const LoginScreen();
      },
    );
  }
}