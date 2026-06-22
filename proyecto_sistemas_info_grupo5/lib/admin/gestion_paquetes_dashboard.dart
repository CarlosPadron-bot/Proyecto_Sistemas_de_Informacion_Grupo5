import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionPaquetesDashboard extends StatefulWidget {
  const GestionPaquetesDashboard({super.key});

  @override
  State<GestionPaquetesDashboard> createState() => _GestionPaquetesDashboardState();
}

class _GestionPaquetesDashboardState extends State<GestionPaquetesDashboard> {
  String _busqueda = "";

  // =========================================================================
  // 🟩 FUNCIÓN PARA ELIMINAR UN PAQUETE DE FIRESTORE
  // =========================================================================
  void _confirmarEliminar(String idDocumento, String nombrePaquete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar paquete turístico?'),
          content: Text('Esta acción eliminará de forma permanente "$nombrePaquete" de la base de datos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance.collection('destinos').doc(idDocumento).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paquete eliminado correctamente'), backgroundColor: Colors.redAccent),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 📝 FUNCIÓN PARA MOSTRAR FORMULARIO (SOPORTA CREAR Y EDITAR)
  // =========================================================================
  void _mostrarFormularioPaquete({String? idDocumento, Map<String, dynamic>? datosActuales}) {
    final bool esEdicion = idDocumento != null && datosActuales != null;

    final TextEditingController nombreController = TextEditingController(
      text: esEdicion ? datosActuales['nombre']?.toString() : ''
    );
    final TextEditingController precioController = TextEditingController(
      text: esEdicion ? datosActuales['precio']?.toString() : ''
    );
    final TextEditingController cuposController = TextEditingController(
      text: esEdicion ? datosActuales['cupos']?.toString() : ''
    );
    
    String imagenBase64 = esEdicion ? (datosActuales['urlImagen']?.toString() ?? '') : '';
    bool subiendo = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            void _seleccionarImagenWeb() {
              final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
              uploadInput.accept = 'image/*';
              uploadInput.click();

              uploadInput.onChange.listen((e) {
                final files = uploadInput.files;
                if (files != null && files.isNotEmpty) {
                  final file = files[0];
                  final reader = html.FileReader();

                  reader.readAsDataUrl(file);
                  reader.onLoadEnd.listen((e) {
                    setDialogState(() {
                      String resultadoRaw = reader.result.toString();
                      if (resultadoRaw.contains('base64,')) {
                        imagenBase64 = 'base64,' + resultadoRaw.split('base64,')[1];
                      } else {
                        imagenBase64 = resultadoRaw;
                      }
                    });
                  });
                }
              });
            }

            Future<void> _procesarGuardado() async {
              if (nombreController.text.trim().isEmpty || precioController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor llena los campos obligatorios'), backgroundColor: Colors.orange),
                );
                return;
              }

              setDialogState(() => subiendo = true);

              final Map<String, dynamic> datosPaquete = {
                'nombre': nombreController.text.trim(),
                'precio': double.tryParse(precioController.text.trim()) ?? 0.0,
                'cupos': cuposController.text.trim().isEmpty ? 'Disponibles' : cuposController.text.trim(),
                'urlImagen': imagenBase64,
              };

              try {
                if (esEdicion) {
                  // 🟩 EDITAR: Actualiza el documento existente
                  await FirebaseFirestore.instance.collection('destinos').doc(idDocumento).update(datosPaquete);
                } else {
                  // CREAR: Añade un nuevo documento
                  await FirebaseFirestore.instance.collection('destinos').add(datosPaquete);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(esEdicion ? '¡Paquete actualizado correctamente! 🔄' : '¡Paquete creado con éxito! 🎉'), 
                    backgroundColor: Colors.green
                  ),
                );
              } catch (e) {
                setDialogState(() => subiendo = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(esEdicion ? 'Editar Paquete Turístico' : 'Agregar Nuevo Paquete Turístico', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: subiendo 
                ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFF009933))))
                : SingleChildScrollView(
                    child: SizedBox(
                      width: 450,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nombreController,
                            decoration: const InputDecoration(labelText: 'Nombre del Destino/Paquete *', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: precioController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Precio (\$) *', prefixText: '\$ ', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: cuposController,
                            decoration: const InputDecoration(labelText: 'Disponibilidad / Cupos (Opcional)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6), color: Colors.grey.shade50),
                            child: Column(
                              children: [
                                imagenBase64.isEmpty
                                    ? const Icon(Icons.image_search, size: 45, color: Colors.grey)
                                    : const Icon(Icons.check_circle, size: 45, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
                                  imagenBase64.isEmpty ? 'Ninguna imagen seleccionada' : '¡Imagen cargada con éxito!',
                                  style: TextStyle(fontSize: 13, color: imagenBase64.isEmpty ? Colors.grey : Colors.green, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.upload_file, size: 16),
                                  label: Text(esEdicion ? 'Cambiar Imagen de PC' : 'Seleccionar Imagen de PC'),
                                  onPressed: _seleccionarImagenWeb,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              actions: subiendo ? [] : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009933), foregroundColor: Colors.white),
                  onPressed: _procesarGuardado,
                  child: Text(esEdicion ? 'Guardar Cambios' : 'Guardar Paquete'),
                ),
              ],
            );
          },
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Control de Paquetes Turísticos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              onChanged: (val) => setState(() => _busqueda = val.toLowerCase()),
                              decoration: InputDecoration(
                                hintText: 'Buscar paquete...',
                                hintStyle: const TextStyle(fontSize: 13),
                                prefixIcon: const Icon(Icons.search, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009933), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo Paquete'),
                            onPressed: () => _mostrarFormularioPaquete(), // Crear limpio
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF009933)));
                      }

                      var docs = snapshot.data!.docs;

                      if (_busqueda.isNotEmpty) {
                        docs = docs.where((doc) {
                          String nombre = (doc['nombre'] ?? '').toString().toLowerCase();
                          return nombre.contains(_busqueda);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No hay paquetes turísticos disponibles.', style: TextStyle(color: Colors.grey))));
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                          horizontalMargin: 12,
                          columnSpacing: 15,
                          columns: const [
                            DataColumn(label: Text('Imagen', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Disponibilidad', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>?;
                            String idDoc = doc.id;

                            String nombre = data != null && data.containsKey('nombre') ? data['nombre'] : 'Sin nombre';
                            String precio = data != null && data.containsKey('precio') ? data['precio'].toString() : '0';
                            String urlImg = data != null && data.containsKey('urlImagen') ? data['urlImagen'] : '';
                            String cupos = data != null && data.containsKey('cupos') ? data['cupos'].toString() : 'Disponibles';

                            return DataRow(cells: [
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: () {
                                      if (urlImg.startsWith('http')) {
                                        return Image.network(urlImg, width: 50, height: 35, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 35));
                                      }
                                      if (urlImg.startsWith('base64,')) {
                                        try {
                                          final String base64Limpio = urlImg.replaceFirst('base64,', '').trim();
                                          return Image.memory(Uri.parse('data:image/jpeg;base64,$base64Limpio').data!.contentAsBytes(), width: 50, height: 35, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 35));
                                        } catch (e) {
                                          return const Icon(Icons.broken_image, color: Colors.redAccent, size: 35);
                                        }
                                      }
                                      if (urlImg.isNotEmpty && urlImg.length > 100) {
                                        try {
                                          return Image.memory(Uri.parse('data:image/jpeg;base64,${urlImg.trim()}').data!.contentAsBytes(), width: 50, height: 35, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 35));
                                        } catch (e) {
                                          return const Icon(Icons.broken_image, color: Colors.redAccent, size: 35);
                                        }
                                      }
                                      return const Icon(Icons.landscape, color: Colors.grey, size: 35);
                                    }(),
                                  ),
                                ),
                              ),
                              DataCell(Text(nombre, style: const TextStyle(fontSize: 13))),
                              DataCell(Text('\$$precio', style: const TextStyle(fontSize: 13))),
                              DataCell(Text(cupos, style: const TextStyle(fontSize: 13))),
                              // 🟩 ACCIONES PROGRAMADAS:
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                    tooltip: 'Editar paquete',
                                    onPressed: () => _mostrarFormularioPaquete(idDocumento: idDoc, datosActuales: data),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    tooltip: 'Eliminar paquete',
                                    onPressed: () => _confirmarEliminar(idDoc, nombre),
                                  ),
                                ],
                              )),
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