import 'package:flutter/material.dart';
import '../widgets_generales/header_gen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/login_screen.dart';

class DetalleDestinoPage extends StatefulWidget {
  final String title;
  final String location;
  final String price;
  final String priceSuffix;
  final String rating;
  final String reviewCount;
  final String imageUrl;
  final String description;
  final List<String> includes;

  const DetalleDestinoPage({
    Key? key,
    required this.title,
    required this.location,
    required this.price,
    required this.priceSuffix,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.includes,
  }) : super(key: key);

  @override
  State<DetalleDestinoPage> createState() => _DetalleDestinoPageState();
}

class _DetalleDestinoPageState extends State<DetalleDestinoPage> {
  int _cantidadViajeros = 1;
  DateTime? _fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    double precioIndividual = double.tryParse(widget.price) ?? 280.0;
    double total = precioIndividual * _cantidadViajeros;
    bool esPantallaAncha = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Layout principal de dos columnas
                if (esPantallaAncha)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildContenidoIzquierdo()),
                      const SizedBox(width: 40),
                      Expanded(
                          flex: 1,
                          child: _buildCajaReserva(precioIndividual, total)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildContenidoIzquierdo(),
                      const SizedBox(height: 24),
                      _buildCajaReserva(precioIndividual, total),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget columna izquierda
  Widget _buildContenidoIzquierdo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen Principal
        Container(
          height: 420,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),

        // Título, ubicación y reseñas
        Text(
          widget.title,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            Text(widget.location,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.calendar_today_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            const Text('3 días',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.people_outline, color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            const Text('Hasta 8 personas',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(widget.rating,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(' (${widget.reviewCount} reseñas)',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.check, color: Color(0xFF009933), size: 16),
            const SizedBox(width: 4),
            const Text('6 cupos disponibles',
                style: TextStyle(
                    color: Color(0xFF009933),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
        const SizedBox(height: 30),

        // Descripción
        _buildCuadroInformativo(
          titulo: 'Descripción',
          child: Text(
            widget.description,
            style: const TextStyle(
                fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 20),

        // Que incluye
        _buildCuadroInformativo(
          titulo: '¿Qué incluye?',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 6,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.includes.map((item) {
              return Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFF009933), size: 18),
                  const SizedBox(width: 8),
                  Text(item,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87)),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Ubicación
        _buildCuadroInformativo(
          titulo: 'Ubicación',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.location,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Venezuela', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text('Ver en Google Maps',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009933),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Reseñas
        _buildCuadroInformativo(
          titulo: 'Reseñas (0)',
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Aún no hay reseñas para este paquete turístico.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  // Columna derecha
  Widget _buildCajaReserva(double precioIndividual, double total) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('\$$precioIndividual',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009933))),
                const SizedBox(width: 4),
                const Text('por persona',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const Divider(height: 30),
            const Text('Número de viajeros (máx. 6)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _cantidadViajeros > 1
                        ? () => setState(() => _cantidadViajeros--)
                        : null,
                  ),
                  Text('$_cantidadViajeros',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: _cantidadViajeros < 6
                        ? () => setState(() => _cantidadViajeros++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio por persona',
                    style: TextStyle(color: Colors.black87)),
                Text('\$$precioIndividual',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cantidad de personas',
                    style: TextStyle(color: Colors.black87)),
                Text('x $_cantidadViajeros',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('\$$total',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009933))),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Verifica si está logueado
                  final usuarioActual = FirebaseAuth.instance.currentUser;

                  if (usuarioActual == null) {
                    // Si la persona no está logueada se muestra un aviso y redirigire a la pantalla de Login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Debes iniciar sesión para poder solicitar una reserva :)'),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  } else {
                    // si ya esta logueado no para nada
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Procesando solicitud... '),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Comprar Paquete',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCuadroInformativo(
      {required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
