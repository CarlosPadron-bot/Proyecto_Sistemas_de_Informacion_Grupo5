import 'package:flutter/material.dart';
import '../widgets_generales/header_gen.dart'; 
import 'widgets/sidebar_filtros.dart';
import 'widgets/grid_resultados.dart';

class BuscarPage extends StatelessWidget {
  const BuscarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AQUÍ PONEMOS TU HEADER
      appBar: const CustomHeader(), 
      
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buscar Destinos y Alojamientos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna Izquierda: Filtros
                  SizedBox(
                    width: 300, 
                    child: SidebarFiltros(),
                  ),
                  SizedBox(width: 24),
                  // Columna Derecha: Resultados
                  Expanded(
                    child: GridResultados(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
