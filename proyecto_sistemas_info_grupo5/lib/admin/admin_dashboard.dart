import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart'
    hide CustomHeader;

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BARRA EXCLUSIVA DE ADMIN
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 45, 133, 49),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Bienvenido Administrador! ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //
                ],
              ),
            ),

            // --- CONTENIDO ORIGINAL DEL HOME (Imágenes y Carruseles) ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todos los Paquetes',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  // Utilizamos el widget de home_page.dart
                  HorizontalCarousel(isAccommodation: false),

                  SizedBox(height: 24),

                  Text(
                    'Todos los Alojamientos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  // Utilizamos el widget de home_page.dart
                  HorizontalCarousel(isAccommodation: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
