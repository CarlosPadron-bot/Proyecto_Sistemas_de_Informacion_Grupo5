import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';

class CargarDestinoPage extends StatefulWidget {
  final String categoriaInicial;
  final Destino? destinoAEditar;

  const CargarDestinoPage({
    super.key,
    required this.categoriaInicial,
    this.destinoAEditar,
  });

  @override
  State<CargarDestinoPage> createState() => _CargarDestinoPageState();
}

class _CargarDestinoPageState extends State<CargarDestinoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _infoExtraController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _incluyeItemController = TextEditingController();

  String _categoriaSeleccionada = 'Paquetes Turísticos';
  String _estadoSeleccionado = 'Disponible';
  String _base64Image = '';
  List<String> _queIncluyeList = [];
  bool _isLoading = false;

  // =========================================================
  // 🛠️ ¡CORREGIDO!: Ciclo de vida initState estructurado correctamente
  // =========================================================
  @override
  void initState() {
    super.initState(); // Se ejecuta primero y una sola vez
    
    _categoriaSeleccionada = widget.categoriaInicial;
    
    // Si estamos editando un destino existente, precargamos los datos
    if (widget.destinoAEditar != null) {
      final d = widget.destinoAEditar!;
      _nombreController.text = d.nombre;
      _ubicacionController.text = d.ubicacion;
      _precioController.text = d.precio.toString();
      _descripcionController.text = d.descripcion;
      _infoExtraController.text = d.infoExtra;
      _duracionController.text = d.duracion;
      _categoriaSeleccionada = d.categoria;
      _estadoSeleccionado = d.estado;
      _base64Image = d.urlImagen;
      _queIncluyeList = List<String>.from(d.queIncluye);
    }
  }

  // Liberamos memoria de los controladores al destruir el widget
  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _infoExtraController.dispose();
    _duracionController.dispose();
    _incluyeItemController.dispose();
    super.dispose();
  }

  // FUNCIÓN PARA SELECCIONAR IMAGEN Y CONVERTIRLA A BASE64
  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  // ACCIÓN DE AGREGAR ITEM A LA LISTA "QUÉ INCLUYE"
  void _agregarIncluyeItem() {
    final texto = _incluyeItemController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _queIncluyeList.add(texto);
        _incluyeItemController.clear();
      });
    }
  }

  // FUNCIÓN PRINCIPAL PARA GUARDAR O ACTUALIZAR EN FIRESTORE
  Future<void> _guardarDestino() async {
    if (!_formKey.currentState!.validate()) return;
    if (_base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una imagen para el servicio.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String uidOperador = user?.uid ?? '';

      // Creamos la instancia estructurada del objeto Destino
      final nuevoDestino = Destino(
        id: widget.destinoAEditar?.id, 
        nombre: _nombreController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        urlImagen: _base64Image,
        categoria: _categoriaSeleccionada,
        descripcion: _descripcionController.text.trim(),
        infoExtra: _infoExtraController.text.trim(),
        queIncluye: _queIncluyeList,
        estado: _estadoSeleccionado,
        duracion: _duracionController.text.trim().isNotEmpty ? _duracionController.text.trim() : 'No definida',
        calificacion: widget.destinoAEditar?.calificacion ?? 5.0, 
        operadorId: widget.destinoAEditar?.operadorId ?? uidOperador, 
      );

      if (widget.destinoAEditar == null) {
        // OPERACIÓN: CREAR NUEVO
        await FirebaseFirestore.instance.collection('destinos').add(nuevoDestino.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio publicado con éxito.'), backgroundColor: Colors.green),
          );
        }
      } else {
        // OPERACIÓN: EDITAR EXISTENTE
        await FirebaseFirestore.instance
            .collection('destinos')
            .doc(widget.destinoAEditar!.id)
            .update(nuevoDestino.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio actualizado con éxito.'), backgroundColor: Colors.blue),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el servicio: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.destinoAEditar != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF009933)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esEdicion ? 'Editar Servicio' : 'Publicar Nuevo Servicio',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text('Completa los campos informativos para actualizar la plataforma.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COLUMNA IZQUIERDA: FORMULARIO
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildTextField('Nombre del servicio o destino', _nombreController, Icons.title),
                              const SizedBox(height: 15),
                              _buildTextField('Ubicación exacta', _ubicacionController, Icons.location_on_outlined),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('Precio (\$ USD)', _precioController, Icons.attach_money, isNumber: true)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildTextField('Duración (Ej: 3 días / Por Noche)', _duracionController, Icons.timer_outlined)),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildTextField('Descripción general', _descripcionController, Icons.description_outlined, maxLines: 3),
                              const SizedBox(height: 15),
                              _buildTextField('Información extra / Requisitos', _infoExtraController, Icons.assignment_outlined, maxLines: 2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),

                        // COLUMNA DERECHA: IMAGEN, CATEGORÍA Y ADICIONALES
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Categoría del Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              DropdownButtonFormField<String>(
                                value: _categoriaSeleccionada,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Paquetes Turísticos', child: Text('Paquetes Turísticos')),
                                  DropdownMenuItem(value: 'Alojamientos', child: Text('Alojamientos')),
                                ],
                                onChanged: (value) => setState(() => _categoriaSeleccionada = value!),
                              ),
                              const SizedBox(height: 20),

                              const Text('Estado de Visibilidad', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              DropdownButtonFormField<String>(
                                value: _estadoSeleccionado,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
                                  DropdownMenuItem(value: 'Agotado', child: Text('Agotado')),
                                  DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                                ],
                                onChanged: (value) => setState(() => _estadoSeleccionado = value!),
                              ),
                              const SizedBox(height: 25),

                              const Text('Imagen de Portada', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _seleccionarImagen,
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: _base64Image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            base64Decode(_base64Image.contains(',') ? _base64Image.split(',')[1] : _base64Image),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                                            SizedBox(height: 5),
                                            Text('Presiona para subir imagen', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),

                    const Text('¿Qué incluye este servicio? (Items individuales)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _incluyeItemController,
                            decoration: InputDecoration(
                              hintText: 'Ej: Guía bilingüe, Desayuno buffet, Traslado ida y vuelta...',
                              prefixIcon: const Icon(Icons.add_task_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _agregarIncluyeItem,
                          child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _queIncluyeList.map((item) {
                        return Chip(
                          backgroundColor: Colors.green.shade50,
                          side: BorderSide(color: Colors.green.shade200),
                          label: Text(item, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                          deleteIcon: const Icon(Icons.cancel, size: 16, color: Colors.green),
                          onDeleted: () {
                            setState(() {
                              _queIncluyeList.remove(item);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009933),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _guardarDestino,
                          child: Text(
                            esEdicion ? 'Actualizar Cambios' : 'Publicar Servicio',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (isNumber && double.tryParse(value.trim()) == null) {
          return 'Ingresa un valor numérico válido';
        }
        return null;
      },
    );
  }
}