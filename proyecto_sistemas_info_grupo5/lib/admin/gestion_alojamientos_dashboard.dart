import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionAlojamientosDashboard extends StatefulWidget {
  const GestionAlojamientosDashboard({super.key});

  @override
  State<GestionAlojamientosDashboard> createState() => _GestionAlojamientosDashboardState();
}

class _GestionAlojamientosDashboardState extends State<GestionAlojamientosDashboard> {
  
  // =========================================================================
  // 🟩 FUNCIÓN PARA ELIMINAR UN ALOJAMIENTO (APUNTA A "DESTINOS")
  // =========================================================================
  void _confirmarEliminar(String idDocumento, String nombreAlojamiento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar alojamiento?'),
          content: Text('Esta acción eliminará permanentemente la infraestructura de "$nombreAlojamiento".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Conectado a "destinos"
                  await FirebaseFirestore.instance.collection('destinos').doc(idDocumento).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alojamiento eliminado'), backgroundColor: Colors.redAccent),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
  // 📝 FORMULARIO FLOTANTE (EDITA Y CREA DENTRO DE "DESTINOS")
  // =========================================================================
  void _mostrarFormularioAlojamiento({String? idDocumento, Map<String, dynamic>? datosActuales}) {
    final bool esEdicion = idDocumento != null && datosActuales != null;

    final TextEditingController nombreController = TextEditingController(
      text: esEdicion ? datosActuales['nombre']?.toString() : ''
    );
    // Usamos 'ubicacion' o lo mapeamos a 'nombre' si es necesario
    final TextEditingController ubicacionController = TextEditingController(
      text: esEdicion ? (datosActuales['ubicacion']?.toString() ?? '') : ''
    );
    final TextEditingController precioController = TextEditingController(
      text: esEdicion ? (datosActuales['precio']?.toString() ?? '') : ''
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

            Future<void> _guardarAlojamiento() async {
              if (nombreController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es obligatorio'), backgroundColor: Colors.orange),
                );
                return;
              }

              setDialogState(() => subiendo = true);

              // Armamos el mapa respetando los campos de tu colección destinos
              final Map<String, dynamic> datosAlojamiento = {
                'nombre': nombreController.text.trim(),
                'ubicacion': ubicacionController.text.trim().isEmpty ? 'No especificada' : ubicacionController.text.trim(),
                'precio': double.tryParse(precioController.text.trim()) ?? 0.0,
                'urlImagen': imagenBase64,
                // Le agregamos una bandera por si en el futuro quieres filtrar paquetes vs hoteles
                'tipo': 'alojamiento' 
              };

              try {
                if (esEdicion) {
                  await FirebaseFirestore.instance.collection('destinos').doc(idDocumento).update(datosAlojamiento);
                } else {
                  await FirebaseFirestore.instance.collection('destinos').add(datosAlojamiento);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(esEdicion ? 'Alojamiento actualizado 🔄' : 'Alojamiento agregado 🎉'), backgroundColor: Colors.green),
                );
              } catch (e) {
                setDialogState(() => subiendo = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(esEdicion ? 'Editar Alojamiento' : 'Nuevo Alojamiento', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: subiendo 
                ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: Color(0xFF009933))))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: const InputDecoration(labelText: 'Nombre del Alojamiento/Hotel *', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: ubicacionController,
                          decoration: const InputDecoration(labelText: 'Ubicación / Estado (Opcional)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: precioController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio por noche (\$) (Opcional)', prefixText: '\$ ', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6), color: Colors.grey.shade50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(imagenBase64.isEmpty ? Icons.image_outlined : Icons.check_circle, color: imagenBase64.isEmpty ? Colors.grey : Colors.green),
                              Text(imagenBase64.isEmpty ? 'Sin imagen seleccionada' : '¡Imagen Lista!'),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                                onPressed: _seleccionarImagenWeb,
                                child: const Text('Subir Foto'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
              actions: subiendo ? [] : [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009933), foregroundColor: Colors.white),
                  onPressed: _guardarAlojamiento, 
                  child: const Text('Guardar'),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Mismo decodificador de imágenes inteligente
  Widget _construirImagenAlojamiento(String urlImg) {
    if (urlImg.startsWith('http')) {
      return Image.network(urlImg, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40));
    }
    if (urlImg.startsWith('base64,')) {
      try {
        final String base64Limpio = urlImg.replaceFirst('base64,', '').trim();
        return Image.memory(Uri.parse('data:image/jpeg;base64,$base64Limpio').data!.contentAsBytes(), fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 40);
      }
    }
    if (urlImg.isNotEmpty && urlImg.length > 100) {
      try {
        return Image.memory(Uri.parse('data:image/jpeg;base64,${urlImg.trim()}').data!.contentAsBytes(), fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 40);
      }
    }
    return const Center(child: Icon(Icons.apartment, size: 40, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 25.0),
        child: Container(
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
                    'Infraestructura y Alojamientos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009933), foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Alojamiento'),
                    onPressed: () => _mostrarFormularioAlojamiento(),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              // 🟩 CONECTADO EN TIEMPO REAL A "DESTINOS"
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF009933)));
                  }

                  var docs = snapshot.data!.docs;

                  // 💡 FILTRO OPCIONAL: Si guardas los alojamientos con la propiedad tipo: 'alojamiento'
                  // puedes descomentar la siguiente línea para que solo muestre los hoteles en esta pestaña:
                  // docs = docs.where((doc) => (doc.data() as Map)['tipo'] == 'alojamiento').toList();

                  if (docs.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('No hay alojamientos registrados en destinos.', style: TextStyle(color: Colors.grey))));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>?;
                      String idDoc = docs[index].id;

                      String nombre = data != null && data.containsKey('nombre') ? data['nombre'] : 'Sin nombre';
                      // Si en destinos no tienes el campo 'ubicacion', puedes usar otra variable o dejarla por defecto
                      String ubicacion = data != null && data.containsKey('ubicacion') ? data['ubicacion'] : 'Destino';
                      String urlImg = data != null && data.containsKey('urlImagen') ? data['urlImagen'] : '';
                      String precio = data != null && data.containsKey('precio') ? '\$${data['precio']}' : '';

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: _construirImagenAlojamiento(urlImg),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(precio.isNotEmpty ? '$ubicacion • $precio' : ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                                        onPressed: () => _mostrarFormularioAlojamiento(idDocumento: idDoc, datosActuales: data),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                        onPressed: () => _confirmarEliminar(idDoc, nombre),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}