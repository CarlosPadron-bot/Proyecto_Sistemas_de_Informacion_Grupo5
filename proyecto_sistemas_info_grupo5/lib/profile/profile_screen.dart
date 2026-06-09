import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para el signOut
import '../widgets_generales/header_gen.dart';
import 'widgets_p/header_profile.dart';
import 'widgets_p/tabs_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileHeaderCard(),
                const SizedBox(height: 32),
                const ProfileTabs(),
                const SizedBox(height: 32), // Espacio antes del botón
                
                // BOTÓN DE CERRAR SESIÓN AL FINAL A LA DERECHA
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      // 1. Cerramos la sesión en Firebase
                      await FirebaseAuth.instance.signOut();
                      // 2. Sacamos al usuario de la pantalla de perfil
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: const Color(0xFFFEF2F2), // Fondo rojo muy claro
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}