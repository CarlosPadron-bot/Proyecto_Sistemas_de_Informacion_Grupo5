import 'package:flutter/material.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green[600],
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 16.0),
      child: Column(
        children: [
          const Text(
            '¿Eres operador turístico?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Únete a nuestra plataforma y llega a miles de viajeros',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.green[100]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navegar a /register
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green[600],
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Registrar mi Negocio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}