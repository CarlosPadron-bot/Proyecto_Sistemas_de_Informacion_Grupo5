import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_usuarios_dashboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_sistemas_info_grupo5/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/resena_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/resena_model.dart';

extension DestinoServiceCategoriaExtension on DestinoService {
  Stream<List<Destino>> obtenerDestinosPorCategoria(String categoria) {
    final Object? destinosResult = obtenerDestinos();
    if (destinosResult is Stream<List<Destino>>) {
      return destinosResult.map((destinos) =>
          destinos.where((destino) => destino.categoria == categoria).toList());
    } else if (destinosResult is Future<List<Destino>>) {
      return Stream.fromFuture(
        destinosResult.then((destinos) => destinos
            .where((destino) => destino.categoria == categoria)
            .toList()),
      );
    }
    return Stream.value(<Destino>[]);
  }
}

extension ResenaServiceEliminarExtension on ResenaService {
  Future<void> eliminarResena(String? id) async {
    if (id == null) {
      throw Exception('ID de la reseña no está disponible');
    }
    await FirebaseFirestore.instance.collection('resenas').doc(id).delete();
  }
}

class PanelAdmin extends StatefulWidget {
  const PanelAdmin({super.key});

  // Simple placeholder horizontal carousel used in the dashboard.
  // Kept lightweight and const so existing usages can remain unchanged.
  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class HorizontalCarousel extends StatelessWidget {
  final bool isAccommodation;
  const HorizontalCarousel({super.key, required this.isAccommodation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    isAccommodation ? 'Alojamiento ejemplo' : 'Paquete ejemplo',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('\$100 • Ubicación',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PanelAdminState extends State<PanelAdmin> {
  int _selectedIndex = 0;
  String _filtroActivo = 'todos';
  final DestinoService _destinoService = DestinoService();
  final ResenaService _resenaService = ResenaService();

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
              const Text(
                'Panel Administrativo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const m.SizedBox(height: 5),
              const Text(
                'Gestión y análisis de la plataforma',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const m.SizedBox(height: 30),

              // Barra de Pestañas
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    _buildTabItem('Dashboard', Icons.trending_up, 0),
                    const m.SizedBox(width: 20),
                    _buildTabItem('Usuarios', Icons.people_outline, 1),
                    const m.SizedBox(width: 20),
                    _buildTabItem('Paquetes', Icons.inventory_2_outlined, 2),
                    const m.SizedBox(width: 20),
                    _buildTabItem('Alojamientos', Icons.home_work_outlined, 3),
                    const m.SizedBox(width: 20),
                    _buildTabItem('Reseñas', Icons.rate_review_outlined,
                        4), // MODIFICADO: Reservas -> Reseñas
                  ],
                ),
              ),
              const m.SizedBox(height: 30),

              // --- LLAMADO DE VISTAS SEGÚN LA PESTAÑA ---
              if (_selectedIndex == 0) _buildDashboardView(),
              if (_selectedIndex == 1) const GestionUsuariosDashboard(),
              if (_selectedIndex == 2)
                _buildGestionGlobalTuristicaView(
                    categoria: 'paquetes',
                    titulo: 'Todos los Paquetes Publicados'),
              if (_selectedIndex == 3)
                _buildGestionGlobalTuristicaView(
                    categoria: 'alojamientos',
                    titulo: 'Todos los Alojamientos Publicados'),
              if (_selectedIndex == 4)
                _buildGestionGlobalResenasView(), // NUEVA VISTA DE RESEÑAS
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
            const m.SizedBox(width: 8),
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

  // --- TABLA GLOBAL DE CONTENIDO TURÍSTICO (PAQUETES / ALOJAMIENTOS) ---
  Widget _buildGestionGlobalTuristicaView(
      {required String categoria, required String titulo}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                    const m.SizedBox(height: 4),
                    const Text(
                      'Monitoreo, control y edición del catálogo global en la plataforma',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CargarDestinoPage(categoriaInicial: categoria),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 20),
                  label: Text(
                    'Nuevo ${categoria == "paquetes" ? "Paquete" : "Alojamiento"}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<Destino>>(
            stream: _destinoService.obtenerDestinosPorCategoria(categoria),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(Icons.layers_clear_outlined,
                            size: 64, color: Colors.grey[300]),
                        const m.SizedBox(height: 16),
                        Text(
                            'No se encontraron registros de $categoria en el sistema.',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              final listaDestinos = snapshot.data!;

              return Column(
                children: [
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      children: [
                        m.SizedBox(
                            width: 70,
                            child: Text('VISTA',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B)))),
                        m.SizedBox(width: 20),
                        Expanded(
                            flex: 3,
                            child: Text('NOMBRE DEL DESTINO',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B)))),
                        Expanded(
                            flex: 2,
                            child: Text('UBICACIÓN / ESTADO',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B)))),
                        Expanded(
                            flex: 1,
                            child: Text('PRECIO BASE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B)))),
                        m.SizedBox(
                            width: 120,
                            child: Text('ESTADO',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B)))),
                        m.SizedBox(
                            width: 110,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('ACCIONES',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B))))),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listaDestinos.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      final item = listaDestinos[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: item.urlImagen.isNotEmpty
                                    ? item.urlImagen.startsWith('base64,')
                                        ? Image.memory(
                                            Uri.parse(
                                                    'data:image/jpeg;base64,${item.urlImagen.substring(7)}')
                                                .data!
                                                .contentAsBytes(),
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            item.urlImagen,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 20,
                                                  color: Colors.grey),
                                            ),
                                          )
                                    : Container(
                                        color: Colors.grey[100],
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 20,
                                            color: Colors.grey)),
                              ),
                            ),
                            const m.SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.nombre,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 15, color: Color(0xFF64748B)),
                                  const m.SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${item.ubicacion}, ${item.estado}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '\$${item.precio}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00B14F)),
                              ),
                            ),
                            m.SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Color(0xFF00B14F)),
                                        const m.SizedBox(width: 6),
                                        const Text('Publicado',
                                            style: TextStyle(
                                                color: Color(0xFF00B14F),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            m.SizedBox(
                              width: 110,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar Registro',
                                    icon: const Icon(Icons.edit_note_outlined,
                                        color: Colors.blue, size: 22),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CargarDestinoPage(
                                            categoriaInicial: categoria,
                                            destinoAEditar: item,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar del Sistema',
                                    icon: const Icon(
                                        Icons.delete_sweep_outlined,
                                        color: Colors.redAccent,
                                        size: 22),
                                    onPressed: () =>
                                        _confirmarEliminacion(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- VISTA GLOBAL DE RESEÑAS DE LA PLATAFORMA ---
  Widget _buildGestionGlobalResenasView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auditoría Global de Reseñas',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const m.SizedBox(height: 4),
          const Text(
            'Supervisa, analiza y elimina comentarios o puntuaciones que infrinjan los términos comunitarios.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const m.SizedBox(height: 24),
          StreamBuilder<List<Resena>>(
            stream: _resenaService.obtenerTodasLasResenas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 48, color: Colors.grey[300]),
                        const m.SizedBox(height: 12),
                        const Text(
                            'No se registran opiniones de usuarios en la plataforma.',
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }

              final listaResenas = snapshot.data!;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listaResenas.length,
                separatorBuilder: (context, index) =>
                    const m.SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final resena = listaResenas[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFF00B14F).withOpacity(0.1),
                          child: const Icon(Icons.person,
                              color: Color(0xFF00B14F)),
                        ),
                        const m.SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    resena.usuarioNombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B)),
                                  ),
                                  const m.SizedBox(width: 8),
                                  Text(
                                    '${resena.fechaResena.day}/${resena.fechaResena.month}/${resena.fechaResena.year}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const m.SizedBox(height: 6),
                              Text(
                                resena.comentario,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF334155),
                                    height: 1.4),
                              ),
                              const m.SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < resena.calificacion
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: const Color(0xFFFFCC00),
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remover reseña inapropiada',
                          icon: const Icon(Icons.delete_outline_outlined,
                              color: Colors.redAccent, size: 22),
                          onPressed: () => _confirmarEliminacionResena(resena),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // POPUP DE ADVERTENCIA PARA ELIMINACIÓN DE REGISTROS TURÍSTICOS
  void _confirmarEliminacion(Destino destino) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              m.SizedBox(width: 10),
              Text('Confirmar acción',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
              '¿Está seguro de que desea eliminar permanentemente "${destino.nombre}"? Esta acción se reflejará inmediatamente en toda la plataforma.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final idDestino = destino.id;
                  if (idDestino == null) {
                    throw Exception('ID del destino no está disponible');
                  }
                  await _destinoService.eliminarDestino(idDestino);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '"${destino.nombre}" fue eliminado correctamente.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Eliminar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // POPUP PARA CONFIRMAR LA ELIMINACIÓN DE RESEÑAS
  void _confirmarEliminacionResena(Resena resena) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.gavel_outlined, color: Colors.red, size: 26),
              const m.SizedBox(width: 10),
              const Text('Moderar Comentario',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
              '¿Desea remover permanentemente la reseña escrita por "${resena.usuarioNombre}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _resenaService.eliminarResena(resena.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'La reseña fue moderada y eliminada correctamente.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al procesar moderación: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Confirmar Eliminación',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  Widget _buildDashboardView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. FILA SUPERIOR DE TARJETAS INDICADORAS
          // ==========================================
          LayoutBuilder(
            builder: (context, constraints) {
              double espaciado = 16.0;
              double anchoTarjeta = (constraints.maxWidth - espaciado) / 2;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🟢 BOTÓN VERDE: TOTAL PAQUETES
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filtroActivo = (_filtroActivo == 'paquetes')
                            ? 'todos'
                            : 'paquetes';
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (_filtroActivo == 'paquetes' ||
                              _filtroActivo == 'todos')
                          ? 1.0
                          : 0.4,
                      child: Container(
                        width: anchoTarjeta,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B050),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.widgets_outlined,
                                    color: Colors.white, size: 28),
                                SizedBox(height: 12),
                                Text(
                                  'Total Paquetes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('destinos')
                                  .where('categoria', isEqualTo: 'Paquete')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String total = snapshot.hasData
                                    ? snapshot.data!.docs.length.toString()
                                    : '...';
                                return Text(
                                  total,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔵 BOTÓN AZUL: TOTAL ALOJAMIENTOS
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filtroActivo = (_filtroActivo == 'alojamientos')
                            ? 'todos'
                            : 'alojamientos';
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (_filtroActivo == 'alojamientos' ||
                              _filtroActivo == 'todos')
                          ? 1.0
                          : 0.4,
                      child: Container(
                        width: anchoTarjeta,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.home, color: Colors.white, size: 28),
                                SizedBox(height: 12),
                                Text(
                                  'Total Alojamientos',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('destinos')
                                  .where('categoria', isEqualTo: 'Alojamiento')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String total = snapshot.hasData
                                    ? snapshot.data!.docs.length.toString()
                                    : '...';
                                return Text(
                                  total,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 2. CARRUSELES DE CONTENIDO FILTRADO
          // ==========================================
          if (_filtroActivo == 'todos' || _filtroActivo == 'paquetes') ...[
            const Text(
              'Paquetes Publicados por Operadores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const HorizontalCarousel(isAccommodation: false),
            const SizedBox(height: 24),
          ],

          if (_filtroActivo == 'todos' || _filtroActivo == 'alojamientos') ...[
            const Text(
              'Alojamientos Registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const HorizontalCarousel(isAccommodation: true),
            const SizedBox(height: 24),
          ],

          // ==========================================
          // 3. ANALÍTICAS AVANZADAS (Solo vista 'todos')
          // ==========================================
          if (_filtroActivo == 'todos') ...[
            const Text(
              'Reservas Mensuales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 30)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Ene');
                            case 1:
                              return const Text('Feb');
                            case 2:
                              return const Text('Mar');
                            case 3:
                              return const Text('Abr');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 8, color: const Color(0xFF009933))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 15, color: const Color(0xFF009933))
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 10, color: const Color(0xFF009933))
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 22, color: const Color(0xFF2F80ED))
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 📊 METRICAS SECUNDARIAS (Usuarios e Ingresos)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 4; // Redirección a Gestión de Usuarios
                      });
                    },
                    child: _buildFigmaCard(
                      title: 'Usuarios Activos',
                      value: '6',
                      icon: Icons.person_outline,
                      color: const Color(0xFF9837F5),
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFigmaCard(
                    title: 'Ingresos Totales',
                    value: '\$400',
                    icon: Icons.attach_money,
                    color: const Color(0xFFDCA10D),
                    width: double.infinity,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ⚡ ACCIONES RÁPIDAS
            LayoutBuilder(
              builder: (context, constraints) {
                double espaciado = 16.0;
                double anchoTarjetaMedio =
                    (constraints.maxWidth - espaciado) / 2;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFigmaActionCard(
                      title: 'Gestionar Usuarios',
                      subtitle: 'Ver, suspender o eliminar cuentas',
                      value: '6',
                      icon: Icons.people_alt_outlined,
                      color: const Color(0xFF5351FB),
                      width: anchoTarjetaMedio,
                    ),
                    _buildFigmaActionCard(
                      title: 'Transacciones del Mes',
                      subtitle: 'Reservas pagadas en abril 2026',
                      value: '2',
                      icon: Icons.trending_up,
                      color: const Color(0xFF00A699),
                      width: anchoTarjetaMedio,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // 🧩 BLOQUES GRÁFICOS Y COSTOS FINALES
            LayoutBuilder(
              builder: (context, constraints) {
                double espaciado = 20.0;
                double anchoColumna = (constraints.maxWidth - espaciado) / 2;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: anchoColumna,
                      child: Column(
                        children: [
                          _buildDestinosPrecioCard(),
                          const SizedBox(height: 20),
                          _buildEstadoReservasCard(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: anchoColumna,
                      child: Column(
                        children: [
                          _buildDistribucionEstadoCard(),
                          const SizedBox(height: 20),
                          _buildIngresosMensualesCard(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFigmaCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      required double width}) {
    return Container(
      width: width,
      height: 95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFigmaActionCard(
      {required String title,
      required String subtitle,
      required String value,
      required IconData icon,
      required Color color,
      required double width}) {
    return Container(
      width: width,
      height: 115,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDestinosPrecioCard() {
    return _buildBaseGraficoCard(
      title: 'Destinos por Rango de Precio',
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 4,
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                    toY: 2,
                    color: const Color(0xFF2B78E4),
                    width: 22,
                    borderRadius: BorderRadius.circular(2))
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                    toY: 0, color: const Color(0xFF2B78E4), width: 22)
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(
                    toY: 3,
                    color: const Color(0xFF2B78E4),
                    width: 22,
                    borderRadius: BorderRadius.circular(2))
              ]),
              BarChartGroupData(x: 3, barRods: [
                BarChartRodData(
                    toY: 0, color: const Color(0xFF2B78E4), width: 22)
              ]),
            ],
            gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
            borderData: FlBorderData(
                show: true,
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                    left: BorderSide(color: Colors.grey.shade400))),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true, interval: 1, reservedSize: 22)),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          '\$0-\$50',
                          '\$51-\$100',
                          '\$101-\$200',
                          '\$201+'
                        ];
                        return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(labels[value.toInt()],
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey)));
                      })),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistribucionEstadoCard() {
    return _buildBaseGraficoCard(
      title: 'Distribución por Estado',
      child: SizedBox(
        height: 180,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 0,
            sections: [
              PieChartSectionData(
                  color: const Color(0xFF2B78E4),
                  value: 25,
                  title: 'Bolívar',
                  radius: 70,
                  titleStyle:
                      const TextStyle(fontSize: 10, color: Color(0xFF2B78E4)),
                  badgeWidget: const Text('Bolívar',
                      style: TextStyle(fontSize: 9, color: Colors.blue))),
              PieChartSectionData(
                  color: const Color(0xFF00B050),
                  value: 20,
                  title: 'Dep. Federales',
                  radius: 70,
                  titleStyle:
                      const TextStyle(fontSize: 10, color: Color(0xFF00B050))),
              PieChartSectionData(
                  color: const Color(0xFF9837F5),
                  value: 15,
                  title: 'Sucre',
                  radius: 70,
                  titleStyle:
                      const TextStyle(fontSize: 10, color: Color(0xFF9837F5))),
              PieChartSectionData(
                  color: const Color(0xFFF14336),
                  value: 20,
                  title: 'Falcón',
                  radius: 70,
                  titleStyle:
                      const TextStyle(fontSize: 10, color: Color(0xFFF14336))),
              PieChartSectionData(
                  color: const Color(0xFFF1A100),
                  value: 20,
                  title: 'Mérida',
                  radius: 70,
                  titleStyle:
                      const TextStyle(fontSize: 10, color: Color(0xFFF1A100))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngresosMensualesCard() {
    return _buildBaseGraficoCard(
      title: 'Ingresos Mensuales',
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 1000,
            gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade100)),
            borderData: FlBorderData(
                show: true,
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                    left: BorderSide(color: Colors.grey.shade400))),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true, interval: 250, reservedSize: 28)),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Ene', 'Feb', 'Mar', 'Abr'];
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return Text(labels[value.toInt()],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey));
                        }
                        return const Text('');
                      })),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 420),
                  FlSpot(1, 700),
                  FlSpot(2, 950),
                  FlSpot(3, 400)
                ],
                isCurved: true,
                color: const Color(0xFF00A699),
                barWidth: 2,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoReservasCard() {
    return _buildBaseGraficoCard(
      title: 'Estado de Reservas',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildMiniStatusBox(
                      'Solicitadas', '0', const Color(0xFF2B78E4))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMiniStatusBox(
                      'Aceptadas', '1', const Color(0xFFDCA10D))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildMiniStatusBox(
                      'Pagadas', '1', const Color(0xFF00B050))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMiniStatusBox(
                      'Completadas', '1', const Color(0xFF9837F5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusBox(String label, String value, Color color) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: double.infinity, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBaseGraficoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
