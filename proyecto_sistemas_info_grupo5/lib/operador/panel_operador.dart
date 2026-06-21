import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/resena_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/resena_model.dart';
import 'package:proyecto_sistemas_info_grupo5/operador/grafico_operador.dart';
import 'package:proyecto_sistemas_info_grupo5/operador/tarjetainfo_operador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PanelOperador extends StatefulWidget {
  const PanelOperador({super.key});

  @override
  State<PanelOperador> createState() => _PanelOperadorState();
}

class _PanelOperadorState extends State<PanelOperador> {
  Future<void> _migrarDatosExistentes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final destinosSnapshot = await FirebaseFirestore.instance
        .collection('destinos')
        .where('operadorId', isNull: true)
        .get();

    for (var doc in destinosSnapshot.docs) {
      await doc.reference.update({'operadorId': user.uid});
      debugPrint("DEBUG: Destino ${doc.id} migrado a ${user.uid}");
    }

    final reservasSnapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('operadorId', isNull: true)
        .get();

    for (var doc in reservasSnapshot.docs) {
      await doc.reference.update({'operadorId': user.uid});
      debugPrint("DEBUG: Reserva ${doc.id} migrada a ${user.uid}");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _migrarDatosExistentes();
  }

  int _selectedIndex = 0;
  final DestinoService _destinoService = DestinoService();
  final ResenaService _resenaService = ResenaService();

  final String _operadorUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // FUNCIÓN PARA EL POPUP DE ELIMINAR (ROJO Y ADVERTENCIA)
  void _confirmarEliminacion(Destino destino) async {
    // 1. Mostrar indicador de carga mientras verificamos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Verificar si existen reservas para este destino
    final reservasSnapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('destinoNombre', isEqualTo: destino.nombre)
        .limit(1) // Solo necesitamos saber si existe al menos una
        .get();

    // 3. Cerrar el indicador de carga
    Navigator.pop(context);

    // 4. Si hay reservas, mostrar el aviso de bloqueo
    if (reservasSnapshot.docs.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Acción no permitida',
                style: TextStyle(color: Colors.orange)),
            content: const Text(
              'Este destino no se puede eliminar porque un usuario ya hizo una reserva.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 5. Si no hay reservas, procedemos con el diálogo de confirmación original
    _mostrarConfirmacionFinal(destino);
  }

  void _mostrarConfirmacionFinal(Destino destino) {
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
            '¿Estás seguro de que deseas eliminar el servicio "${destino.nombre}"?\n\nEsta acción no es recuperable.',
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
                Navigator.pop(context);
                try {
                  await _destinoService.eliminarDestino(destino.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Servicio eliminado con éxito'),
                          backgroundColor: Colors.red),
                    );
                    setState(() {});
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
      setState(() {});
    });
  }

  Future<void> _verificarPermisosYNavegar(String categoria) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final bool esActivo = data['activo'] ?? true;
        final bool esEliminado = data['eliminado'] ?? false;

        if (!esActivo || esEliminado) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Acción denegada',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
                content: const Text(
                    'Cuenta suspendida. No puedes publicar nuevos servicios en este momento. Para más detalles o reclamos, comunícate con la administración.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al verificar cuenta: $e'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CargarDestinoPage(categoriaInicial: categoria),
        ),
      ).then((_) => setState(() {}));
    }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeccionTarjetasInfo(operadorId: _operadorUid),
        const SizedBox(height: 20),
        const Row(children: [
          Expanded(child: GraficoPrecios()),
          SizedBox(width: 20),
          Expanded(child: GraficoEstados())
        ]),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)),
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
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reservas')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text("Cargando...");

                              debugPrint(
                                  "Total de reservas en BD: ${snapshot.data!.docs.length}");

                              final docs = snapshot.data!.docs;
                              // Filtra manualmente para depurar
                              final pagadas = docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                debugPrint(
                                    "Reserva encontrada: ${data['destinoNombre']} - Operador: ${data['operadorId']}");
                                return data['estado'] == 'Pagada' ||
                                    (data['completa'] == false);
                              }).length;

                              return _buildReservaStat(
                                  pagadas.toString(), 'Pagadas', Colors.green);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reservas')
                                .where('operadorId', isEqualTo: _operadorUid)
                                .where('estado', isEqualTo: 'completado')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildReservaStat(
                                    '...', 'Completadas', Colors.purple);
                              }

                              String totalCompletadas = snapshot.hasData
                                  ? snapshot.data!.docs.length.toString()
                                  : '0';

                              return _buildReservaStat(totalCompletadas,
                                  'Completadas', Colors.purple);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(child: GraficoIngresos()),
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
              onPressed: () => _verificarPermisosYNavegar(categoria),
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

              final destinos = snapshot.data?.where((d) {
                    return d.categoria == categoria &&
                        d.operadorId == _operadorUid;
                  }).toList() ??
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
                    DataColumn(label: Text('Duración')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Calificación')),
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
    String duracionDestino = "Flexible";
    if (destino.infoExtra.contains('|')) {
      List<String> partes = destino.infoExtra.split('|');
      duracionDestino = partes[1].trim();
    } else if (destino.categoria == 'Alojamientos') {
      duracionDestino = "Por Noche";
    }

    return DataRow(cells: [
      // 1. Imagen
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
      // 2. Nombre
      DataCell(Text(destino.nombre,
          style: const TextStyle(fontWeight: FontWeight.w500))),
      // 3. Ubicación
      DataCell(Text(destino.ubicacion)),
      // 4. Duración (Nueva)
      DataCell(Text(duracionDestino,
          style: const TextStyle(color: Colors.blueGrey))),
      // 5. Precio
      DataCell(Text('\$${destino.precio}',
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold))),
      // 6. Calificación Interactiva (Nueva)
      DataCell(
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('resenas')
              .where('destinoId', isEqualTo: destino.nombre)
              .snapshots(),
          builder: (context, snapshot) {
            double promedio = 0.0;
            int total = 0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              total = snapshot.data!.docs.length;
              double suma = 0;
              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                suma += (data['calificacion'] ?? 0).toDouble();
              }
              promedio = suma / total;
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  total == 0 ? '0.0' : promedio.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(' ($total)',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            );
          },
        ),
      ),
      // 7. Acciones
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
        const Text('Reseñas de mis servicios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        FutureBuilder<List<Resena>>(
          future: _cargarResenasFiltradas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final listaResenas = snapshot.data ?? [];

            if (listaResenas.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                    child: Text('Aún no tienes reseñas para tus servicios.',
                        style: TextStyle(color: Colors.grey))),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaResenas.length,
              itemBuilder: (context, index) {
                return _buildCardResenaOperador(listaResenas[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<Resena>> _cargarResenasFiltradas() async {
    final destinosSnapshot = await FirebaseFirestore.instance
        .collection('destinos')
        .where('operadorId', isEqualTo: _operadorUid)
        .get();

    List<String> misDestinosNombres =
        destinosSnapshot.docs.map((doc) => doc['nombre'] as String).toList();

    if (misDestinosNombres.isEmpty) return [];

    final resenasSnapshot = await FirebaseFirestore.instance
        .collection('resenas')
        .where('destinoNombre', whereIn: misDestinosNombres)
        .get();

    return resenasSnapshot.docs.map((doc) {
      return Resena.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
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
                  Text(
                    resena.comentario,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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
}
