import 'package:flutter/material.dart';
import 'widgets/banner.dart';
import 'widgets/featured_section.dart';
import 'widgets/cta_section.dart';
import '../widgets_generales/header_gen.dart'; // Asegúrate de que la ruta a tu HeaderGen sea correcta

// La mayoria de los botones de la homepage llevan a la pantalla del buscador cuando la añadan hay que arreglar esos botones

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomHeader(), 
      body: SingleChildScrollView(
        child: Column(
          children: const [
            Hbanner(),
            FeaturedSection(
              title: 'Paquetes Destacados',
              isAccommodation: false,
            ),
            FeaturedSection(
              title: 'Alojamientos Económicos',
              isAccommodation: true,
              backgroundColor: Colors.white,
            ),
            CtaSection(),
          ],
        ),
      ),
    );
  }
}