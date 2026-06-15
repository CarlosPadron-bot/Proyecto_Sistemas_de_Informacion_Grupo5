import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/cargar_destino_page.dart';

class PanelOperador extends StatefulWidget {
  const PanelOperador({super.key});

  @override
  State<PanelOperador> createState() => _PanelOperadorState();
}

class _PanelOperadorState extends State<PanelOperador> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Panel de Operador',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 5),
              const Text(
                'Gestión y análisis de tus servicios y clientes',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Barra de Pestañas (Tabs con el mismo estilo del admin)
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    _buildTabItem('Dashboard', Icons.show_chart, 0),
                    const SizedBox(width: 20),
                    _buildTabItem('Paquetes', Icons.inventory_2_outlined, 1),
                    const SizedBox(width: 20),
                    _buildTabItem('Alojamientos', Icons.home_work_outlined, 2),
                    const SizedBox(width: 20),
                    _buildTabItem('Reservas', Icons.people_outline, 3),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // CONTENIDO TABS
              if (_selectedIndex == 0) _buildTabDashboard(),
              if (_selectedIndex == 1) _buildTabPaquetes(),
              if (_selectedIndex == 2) _buildTabAlojamientos(),
              if (_selectedIndex == 3) _buildTabReservas(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF00B14F) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- PESTAÑAS --
  Widget _buildTabDashboard() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildMockCard('Destinos por Rango de Precio',
                    Icons.bar_chart, Colors.blue)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildMockCard(
                    'Distribución por Estado', Icons.pie_chart, Colors.orange)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado de Reservas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            child: _buildReservaStat(
                                '0', 'Solicitadas', Colors.blue)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildReservaStat(
                                '1', 'Aceptadas', Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildReservaStat(
                                '1', 'Pagadas', Colors.green)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildReservaStat(
                                '1', 'Completadas', Colors.purple)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
                child: _buildMockCard('Ingresos Mensuales',
                    Icons.stacked_line_chart, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildReservaStat(String numero, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(numero,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(texto, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMockCard(String title, IconData icon, Color color) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Icon(icon, size: 60, color: color.withOpacity(0.5)),
                const SizedBox(height: 10),
                const Text('[Área del Gráfico]',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTabPaquetes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Gestión de Paquetes Turísticos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              // CONEXIÓN CON LA PÁGINA DE CARGA PASANDO LA CATEGORÍA CORRECTA
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CargarDestinoPage(
                        categoriaInicial: 'Paquetes Turisticos'),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nuevo Paquete',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009933)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ... El resto del código de la tabla se mantiene exactamente igual
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              columns: const [
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Destino')),
                DataColumn(label: Text('Duración')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: [
                _crearFilaTabla('assets/los_roques.png', 'Aventura Los Roques',
                    'Los Roques', '3 días', '\$280'),
                _crearFilaTabla('assets/salto_angel.png', 'Salto Ángel Express',
                    'Canaima', '2 días', '\$195'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabAlojamientos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Gestión de Alojamientos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              // CONEXIÓN CON LA PÁGINA DE CARGA PASANDO LA CATEGORÍA CORRECTA
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CargarDestinoPage(
                        categoriaInicial: 'Alojamientos'),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nuevo Alojamiento',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009933)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ... El resto del código de la tabla se mantiene exactamente igual[cite: 22]
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              columns: const [
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Ubicación')),
                DataColumn(label: Text('Capacidad')),
                DataColumn(label: Text('Precio/noche')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: [
                _crearFilaTabla('assets/posada.png', 'Posada Paradise',
                    'Gran Roque', '6', '\$45'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _crearFilaTabla(
      String img, String nombre, String ubi, String ext, String precio) {
    return DataRow(cells: [
      DataCell(Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.image))),
      DataCell(Text(nombre)),
      DataCell(Text(ubi)),
      DataCell(Text(ext)),
      DataCell(Text(precio,
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(Row(children: [
        IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {}),
      ])),
    ]);
  }

  Widget _buildTabReservas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gestión de Reservas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildReservaCard('Aventura Los Roques', 'Paquete • res1',
            'Check-in: 2026-05-15', '\$280', 'Pagado', Colors.green),
        _buildReservaCard('Cabaña Montaña', 'Alojamiento • res2',
            'Check-in: 2026-06-01', '\$105', 'Aceptado', Colors.orange),
      ],
    );
  }

  Widget _buildReservaCard(
      String tit, String sub, String det, String pre, String est, Color col) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.image)),
        title: Text(tit, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$sub\n$det'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(pre,
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(est,
                style: TextStyle(color: col, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
