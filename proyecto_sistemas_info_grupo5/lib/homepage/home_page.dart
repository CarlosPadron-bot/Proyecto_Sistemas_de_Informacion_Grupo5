import 'package:flutter/material.dart';
import 'widgets/banner.dart';
import 'widgets/featured_section.dart';
import 'widgets/cta_section.dart';
import '../widgets_generales/header_gen.dart';
import '../botones/botones.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomHeader(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Hbanner(),

            // AGREGAMOS EL WIDGET AQUÍ
            Botones(),

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
