import 'package:flutter/material.dart';
import 'widgets/banner.dart';
import 'widgets/featured_section.dart';
import 'widgets/cta_section.dart';
import '../widgets_generales/header_gen.dart';
import '../botones/botones.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUrl = Uri.base.toString();

      if (currentUrl.contains('token=') || currentUrl.contains('PayerID=')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Pago procesado con éxito! Bienvenido de vuelta.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

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
