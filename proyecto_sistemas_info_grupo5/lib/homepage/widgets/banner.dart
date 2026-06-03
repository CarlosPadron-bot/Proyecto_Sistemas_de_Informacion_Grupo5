import 'package:flutter/material.dart';

class Hbanner extends StatelessWidget {
  const Hbanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Descubre Venezuela sin Gastar de Más',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32, // Adaptado para móviles
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Turismo económico, auténtico y sostenible al alcance de todos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.green[100],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a /search
            },
            icon: const Icon(Icons.search, color: Colors.green),
            label: const Text(
              'Explorar Destinos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green[600],
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}