import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class PanelOperador extends StatefulWidget {
  const PanelOperador({super.key});

  @override
  State<PanelOperador> createState() => _PanelOperadorState();
}

class _PanelOperadorState extends State<PanelOperador> {
  int _selectedIndex = 0;
  final DestinoService _destinoService =
      DestinoService(); // Instancia del servicio

  // FUNCIÓN PARA EL POPUP DE ELIMINAR (ROJO Y ADVERTENCIA)
  void _confirmarEliminacion(Destino destino) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Eliminar Servicio',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar el servicio "${destino.nombre}"?\n\nEsta acción no es recuperable y se borrará permanentemente de la plataforma.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context); // Cierra el popup

                // 1. VALIDACIÓN SEGURA ANTI-CRASH
                if (destino.id == null || destino.id!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Error: Este destino no tiene un ID válido asignado.'),
                        backgroundColor: Colors.red),
                  );
                  return; // Detenemos la ejecución aquí
                }

                try {
                  await _destinoService.eliminarDestino(destino.id!);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Servicio eliminado con éxito'),
                          backgroundColor: Colors.red),
                    );
                    setState(() {}); // Refresca la pantalla
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al eliminar: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Sí, eliminar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // FUNCIÓN PARA EDITAR
  void _editarDestino(Destino destino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CargarDestinoPage(
          categoriaInicial: destino.categoria,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

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
              const Text('Panel de Operador',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 5),
              const Text('Gestión y análisis de tus servicios y clientes',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 30),

              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))),
                child: Row(
                  children: [
                    _buildTabItem('Dashboard', Icons.show_chart, 0),
                    const SizedBox(width: 20),
                    _buildTabItem('Paquetes', Icons.inventory_2_outlined, 1),
                    const SizedBox(width: 20),
                    _buildTabItem('Alojamientos', Icons.home_work_outlined, 2),
                    const SizedBox(width: 20),
                    _buildTabItem('Reseñas', Icons.people_outline, 3),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Contenido de las tabs
              if (_selectedIndex == 0) _buildTabDashboard(),
              if (_selectedIndex == 1)
                _buildTabServiciosDinamico('Paquetes Turisticos'),
              if (_selectedIndex == 2)
                _buildTabServiciosDinamico('Alojamientos'),
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
                color:
                    isSelected ? const Color(0xFF00B14F) : Colors.transparent,
                width: 3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF00B14F) : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

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

  // TABLA DINÁMICA QUE LEE DE FIREBASE
  Widget _buildTabServiciosDinamico(String categoria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gestión de $categoria',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CargarDestinoPage(categoriaInicial: categoria)),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                  'Nuevo ${categoria == 'Alojamientos' ? 'Alojamiento' : 'Paquete'}',
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009933)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8)),
          child: StreamBuilder<List<Destino>>(
            stream: _destinoService.obtenerDestinosStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error: ${snapshot.error}'));
              }

              final destinos = snapshot.data
                      ?.where((d) => d.categoria == categoria)
                      .toList() ??
                  [];

              if (destinos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: Text(
                          'Aún no has publicado servicios en esta categoría.',
                          style: TextStyle(color: Colors.grey))),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMaxHeight: 85,
                  dataRowMinHeight: 75,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  columns: const [
                    DataColumn(label: Text('Imagen')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Ubicación')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: destinos
                      .map((destino) => _crearFilaTabla(destino))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construirImagenDestino(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey, size: 24);
    }

    if (url.startsWith('base64,')) {
      try {
        final String cadenaLimpia = url.replaceFirst('base64,', '');
        return Image.memory(
          base64Decode(cadenaLimpia),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const Icon(Icons.broken_image_outlined,
            color: Colors.red, size: 24);
      }
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
    );
  }

  DataRow _crearFilaTabla(Destino destino) {
    return DataRow(cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 115,
              height: 85,
              color: Colors.grey[100],
              child: _construirImagenDestino(destino.urlImagen),
            ),
          ),
        ),
      ),
      DataCell(Text(destino.nombre,
          style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(destino.ubicacion)),
      DataCell(Text('\$${destino.precio}',
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(Row(children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => _editarDestino(destino),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _confirmarEliminacion(destino),
        ),
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
