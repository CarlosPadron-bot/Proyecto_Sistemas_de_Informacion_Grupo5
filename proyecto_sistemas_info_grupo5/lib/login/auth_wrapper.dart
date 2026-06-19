import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener este import
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
      stream: _authService.authStateChanges, // Escucha si hay una sesión activa en el dispositivo
      builder: (context, authSnapshot) {
        // 1. Cargando estado de autenticación inicial
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00B14F)),
            ),
          );
        }

        // 2. ¡SESIÓN DETECTADA! Evaluamos su existencia en Firestore en tiempo real
        if (authSnapshot.hasData && authSnapshot.data != null) {
          final String uid = authSnapshot.data!.uid;

          // Escuchamos el documento del usuario para saber si sigue existiendo en la base de datos
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
            builder: (context, userSnapshot) {
              // Mientras carga los datos desde Firestore por primera vez
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B14F)),
                  ),
                );
              }

              // ¡ELIMINACIÓN EN TIEMPO REAL! 
              // Si el administrador eliminó al usuario de la base de datos (el documento ya no existe):
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // Forzamos el cierre de sesión en Firebase Auth para limpiar los tokens locales
                FirebaseAuth.instance.signOut(); 
                return const LoginScreen(); // Lo saca inmediatamente a la pantalla de Login
              }

              // Si el usuario existe de forma correcta, extraemos sus datos
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              String rolNormalizado = (userData?['rol'] ?? 'viajero').toString().toLowerCase();

              // Decidimos a qué Dashboard enviarlo según el rol con el que se registró
              if (rolNormalizado == 'admin') {
                return const AdminDashboard();
              } else if (rolNormalizado == 'operador') {
                return const OperadorDashboard();
              } else {
                return const HomePage(); // Viajero
              }
            },
          );
        }

        // 3. NO HAY SESIÓN: El usuario no está logueado en el dispositivo, directo al Login.
        return const LoginScreen();
      },
    );
  }
}