import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GestionResenasDashboard extends StatefulWidget {
  const GestionResenasDashboard({super.key});

  @override
  State<GestionResenasDashboard> createState() => _GestionResenasDashboardState();
}

class _GestionResenasDashboardState extends State<GestionResenasDashboard> {
  String _busqueda = "";

  // Función útil para formatear de manera limpia el Timestamp de Firebase
  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return "-";
    if (fecha is Timestamp) {
      DateTime dt = fecha.toDate();
      return DateFormat('dd/MM/yyyy').format(dt);
    }
    return fecha.toString();
  }

  // Función para eliminar reseñas directamente de Firestore
  void _eliminarResena(String idDocumento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar reseña?'),
          content: const Text('Esta acción eliminará de forma permanente el comentario de la base de datos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance.collection('resenas').doc(idDocumento).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reseña eliminada correctamente'), backgroundColor: Colors.redAccent),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historial de Comentarios de Usuarios',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      // Buscador reactivo integrado
                      SizedBox(
                        width: 250,
                        height: 40,
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _busqueda = val.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar por usuario o destino...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Conexión reactiva a la colección "resenas" ordenadas por fecha más reciente
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('resenas')
                        .orderBy('fechaResena', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFF009933)),
                        ));
                      }

                      var docs = snapshot.data!.docs;

                      // Filtrar localmente según lo que el admin escriba en el buscador
                      if (_busqueda.isNotEmpty) {
                        docs = docs.where((doc) {
                          String usuario = (doc['usuarioNombre'] ?? '').toString().toLowerCase();
                          String destino = (doc['destinoNombre'] ?? '').toString().toLowerCase();
                          return usuario.contains(_busqueda) || destino.contains(_busqueda);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('No se encontraron reseñas registradas.', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                          horizontalMargin: 12,
                          columnSpacing: 15,
                          columns: const [
                            DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Destino', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Comentario', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Calificación', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: docs.map((doc) {
                            String idDoc = doc.id;
                            String usuario = doc['usuarioNombre'] ?? 'Anónimo';
                            String destino = doc['destinoNombre'] ?? 'No especificado';
                            String comentario = doc['comentario'] ?? '';
                            int calificacion = int.tryParse(doc['calificacion'].toString()) ?? 0;
                            dynamic fechaRaw = doc['fechaResena'];

                            return DataRow(cells: [
                              DataCell(Text(usuario, style: const TextStyle(fontSize: 13))),
                              DataCell(Text(destino, style: const TextStyle(fontSize: 13))),
                              DataCell(
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    comentario,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ),
                              ),
                              // Dibujar las estrellas según el número entero de la base de datos
                              DataCell(Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < calificacion ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 15,
                                  );
                                }),
                              )),
                              DataCell(Text(_formatearFecha(fechaRaw), style: const TextStyle(fontSize: 13))),
                              // Acciones administrativas de control
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  tooltip: 'Eliminar comentario inapropiado',
                                  onPressed: () => _eliminarResena(idDoc),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      );
                    },
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