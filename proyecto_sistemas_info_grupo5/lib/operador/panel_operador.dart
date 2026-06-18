import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/resena_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/resena_model.dart';

class PanelOperador extends StatefulWidget {
  const PanelOperador({super.key});

  @override
  State<PanelOperador> createState() => _PanelOperadorState();
}

class _PanelOperadorState extends State<PanelOperador> {
  int _selectedIndex = 0;
  final DestinoService _destinoService = DestinoService();
  final ResenaService _resenaService =
      ResenaService(); // Instanciamos el servicio

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

                if (destino.id == null || destino.id!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Error: Este destino no tiene un ID válido asignado.'),
                        backgroundColor: Colors.red),
                  );
                  return;
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

  // EDITAR DESTINO
  void _editarDestino(Destino destino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CargarDestinoPage(
          categoriaInicial: destino.categoria,
          destinoAEditar: destino,
        ),
      ),
    ).then((_) {
      setState(() {}); // Refrescar la tabla al volver
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
                    _buildTabItem('Reseñas', Icons.rate_review_outlined, 3),
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
              if (_selectedIndex == 3) _buildTabResenasDinamicas(),
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

    if (url.contains('base64')) {
      try {
        final String cadenaLimpia = url.contains(',') ? url.split(',')[1] : url;
        return Image.memory(
          base64Decode(cadenaLimpia.trim()),
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

  Widget _buildTabResenasDinamicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reseñas e Historial de Clientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        StreamBuilder<List<Resena>>(
          stream: _resenaService.obtenerTodasLasResenas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF009933)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Error al cargar reseñas: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                ),
              );
            }

            final listaResenas = snapshot.data ?? [];

            if (listaResenas.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'Tu plataforma aún no cuenta con comentarios de clientes.',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaResenas.length,
              itemBuilder: (context, index) {
                final resena = listaResenas[index];
                return _buildCardResenaOperador(resena);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardResenaOperador(Resena resena) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen del Destino (Soporta Base64 y URL de Red)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 75,
                height: 75,
                color: Colors.grey[100],
                child: _construirImagenDestino(resena.urlImagenDestino),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Información central de la reseña
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resena.destinoNombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Por: ${resena.usuarioNombre}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 4. El comentario real del cliente
                  Text(
                    resena.comentario,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Calificación en estrellas en el lado derecho
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < resena.calificacion
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFCC00),
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '${resena.fechaResena.day}/${resena.fechaResena.month}/${resena.fechaResena.year}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservaCard(
      String tit, String sub, String det, String pre, String est, Color col) {
    return const SizedBox.shrink();
  }
}
