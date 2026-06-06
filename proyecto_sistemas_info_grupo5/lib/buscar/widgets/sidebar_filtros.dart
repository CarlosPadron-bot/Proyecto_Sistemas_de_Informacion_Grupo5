import 'package:flutter/material.dart';

class SidebarFiltros extends StatefulWidget {
  const SidebarFiltros({super.key});

  @override
  State<SidebarFiltros> createState() => _SidebarFiltrosState();
}

class _SidebarFiltrosState extends State<SidebarFiltros> {
  // Variables de estado para los sliders
  double maxPresupuesto = 500;
  String tipoBusqueda = 'Todo';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Tarjeta de Calculadora de Presupuesto
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Calculadora de Presupuesto', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Número de personas: 1'),
                  Slider(value: 1, min: 1, max: 10, divisions: 9, activeColor: Colors.green, onChanged: (val) {}),
                  
                  const Text('Días de viaje: 1'),
                  Slider(value: 1, min: 1, max: 30, activeColor: Colors.green, onChanged: (val) {}),
                  
                  const Divider(),
                  const Text('Total del viaje:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('\$101', style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección de Filtros
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipo de Búsqueda'),
                  const SizedBox(height: 8),
                  // Botones de tipo (Todo, Paquetes, Alojamientos)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Text('Todo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                  // Agrega aquí los otros botones (Paquetes, Alojamientos) con estilo gris
                  
                  const SizedBox(height: 16),
                  const Text('Presupuesto Máximo'),
                  Slider(
                    value: maxPresupuesto, 
                    min: 10, 
                    max: 1000, 
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() { maxPresupuesto = val; });
                    }
                  ),
                  
                  // 
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Limpiar Filtros', style: TextStyle(color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
