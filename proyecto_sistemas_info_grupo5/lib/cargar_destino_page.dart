import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CargarDestinoPage extends StatefulWidget {
  final String categoriaInicial;
  final Destino? destinoAEditar;

  const CargarDestinoPage(
      {super.key, required this.categoriaInicial, this.destinoAEditar});

  @override
  State<CargarDestinoPage> createState() => _CargarDestinoPageState();
}

class _CargarDestinoPageState extends State<CargarDestinoPage> {
  final _formKey = GlobalKey<FormState>();
  final DestinoService _destinoService = DestinoService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _infoExtraController = TextEditingController();
  final TextEditingController _incluyeController = TextEditingController();

  String _estadoSeleccionado = 'Caracas';
  bool _cargando = false;
  DateTime? _fechaSeleccionada;

  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  final List<String> _estados = [
    'Mérida',
    'Caracas',
    'Falcón',
    'Sucre',
    'Bolívar',
    'Anzoátegui',
    'Nueva Esparta',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.destinoAEditar != null) {
      _nombreController.text = widget.destinoAEditar!.nombre;
      _ubicacionController.text = widget.destinoAEditar!.ubicacion;
      _precioController.text = widget.destinoAEditar!.precio.toString();
      _descripcionController.text = widget.destinoAEditar!.descripcion;
      _incluyeController.text = widget.destinoAEditar!.queIncluye.join(', ');

      String infoRaw = widget.destinoAEditar!.infoExtra;
      if (infoRaw.contains('|')) {
        String parteCupos = infoRaw.split('|')[0].trim();
        _infoExtraController.text =
            parteCupos.replaceAll(RegExp(r'[^0-9]'), '');
      } else {
        _infoExtraController.text = infoRaw.replaceAll(RegExp(r'[^0-9]'), '');
      }

      if (_estados.contains(widget.destinoAEditar!.estado)) {
        _estadoSeleccionado = widget.destinoAEditar!.estado;
      }
    }
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = imagen;
      });
    }
  }

  Future<Uint8List> _comprimirBytes(Uint8List bytesOriginales) async {
    try {
      final Uint8List bytesComprimidos =
          await FlutterImageCompress.compressWithList(
        bytesOriginales,
        minWidth: 800,
        minHeight: 600,
        quality: 75,
        format: CompressFormat.jpeg,
      );
      return bytesComprimidos;
    } catch (e) {
      debugPrint("Error en compresión avanzada: $e");
      return bytesOriginales;
    }
  }

  void _publicarDestino() async {
    if (!_formKey.currentState!.validate()) return;

    final String? operadorUid = FirebaseAuth.instance.currentUser?.uid;
    if (operadorUid == null || operadorUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: No se encontró una sesión de operador activa.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _cargando = true);

    List<String> incluyeList = _incluyeController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      double precioDouble =
          double.tryParse(_precioController.text.trim()) ?? 0.0;

      String imagenBase64 = widget.destinoAEditar?.urlImagen ??
          'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7';

      if (_imagenSeleccionada != null) {
        final bytesOriginales = await _imagenSeleccionada!.readAsBytes();
        final bytesOptimizados = await _comprimirBytes(bytesOriginales);
        String base64String = base64Encode(bytesOptimizados);
        imagenBase64 = 'base64,$base64String';
      }

      String cuposIngresados = _infoExtraController.text.trim();
      String infoExtraFormateada = '';

      // Normalización estricta de categorías para evitar descalces en el String de Firestore
      String categoriaNormalizada = widget.categoriaInicial;
      if (categoriaNormalizada.contains('Paquete')) {
        categoriaNormalizada = 'Paquetes Turisticos';
      }

      if (cuposIngresados.isEmpty) {
        infoExtraFormateada = (categoriaNormalizada == 'Alojamientos'
            ? 'Por noche'
            : 'Cupos limitados');
      } else {
        String soloNumeroCupos =
            cuposIngresados.replaceAll(RegExp(r'[^0-9]'), '');
        infoExtraFormateada = '$soloNumeroCupos Cupos';
      }

      if (_fechaSeleccionada != null) {
        String fechaString =
            '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}';
        infoExtraFormateada = '$infoExtraFormateada | $fechaString';
      } else if (widget.destinoAEditar != null &&
          widget.destinoAEditar!.infoExtra.contains('|')) {
        String fechaVieja =
            widget.destinoAEditar!.infoExtra.split('|')[1].trim();
        infoExtraFormateada = '$infoExtraFormateada | $fechaVieja';
      } else {
        infoExtraFormateada = '$infoExtraFormateada | Fecha por programar';
      }

      Destino nuevoDestino = Destino(
        id: widget.destinoAEditar?.id,
        nombre: _nombreController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
        precio: precioDouble,
        descripcion: _descripcionController.text.trim(),
        urlImagen: imagenBase64,
        categoria: categoriaNormalizada,
        infoExtra: infoExtraFormateada,
        queIncluye: incluyeList.isEmpty ? ['Hospedaje o Guía'] : incluyeList,
        estado: _estadoSeleccionado,
        operadorId: widget.destinoAEditar?.operadorId ?? operadorUid,
      );

      if (widget.destinoAEditar != null) {
        await _destinoService.actualizarDestino(nuevoDestino);
      } else {
        await _destinoService.guardarDestino(nuevoDestino);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.destinoAEditar != null
                  ? '¡Servicio actualizado con éxito!'
                  : '¡Servicio turístico publicado con éxito!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.destinoAEditar != null;

    return Scaffold(
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${esEdicion ? 'Editar' : 'Publicar'} ${widget.categoriaInicial == 'Alojamientos' ? 'Alojamiento' : 'Paquete Turístico'}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                    labelText: 'Título del destino / hospedaje',
                    border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingrese el título'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ubicacionController,
                      decoration: const InputDecoration(
                          labelText: 'Ubicación específica (Ej: Chichiriviche)',
                          border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Ingrese la ubicación'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      decoration: const InputDecoration(
                          labelText: 'Estado político',
                          border: OutlineInputBorder()),
                      items: _estados
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _estadoSeleccionado = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioController,
                      decoration: const InputDecoration(
                          labelText: 'Precio (\$ USD)',
                          border: OutlineInputBorder(),
                          prefixText: '\$ '),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Precio inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _infoExtraController,
                            decoration: const InputDecoration(
                                hintText: 'Solo números',
                                labelText: 'Cupos disponibles',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: Colors.grey[600]!),
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _fechaSeleccionada = picked;
                                  });
                                }
                              },
                              child: Text(
                                _fechaSeleccionada == null
                                    ? 'Selecciona la fecha de tu experiencia'
                                    : 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incluyeController,
                decoration: const InputDecoration(
                    labelText:
                        '¿Qué incluye? (Separa los elementos por comas ",")',
                    border: OutlineInputBorder(),
                    hintText: 'Traslado, Almuerzos, Paseo en lancha'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                    labelText: 'Descripción detallada de la experiencia',
                    border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                esEdicion
                    ? 'Actualizar imagen de portada (Opcional)'
                    : 'Imagen de portada',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _seleccionarImagen,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imagenSeleccionada == null
                      ? (esEdicion &&
                              widget.destinoAEditar!.urlImagen
                                  .startsWith('base64,'))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(widget.destinoAEditar!.urlImagen
                                    .split(',')[1]),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Haz clic para subir una imagen',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(_imagenSeleccionada!.path,
                                  fit: BoxFit.cover)
                              : Image.file(File(_imagenSeleccionada!.path),
                                  fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009933)),
                  onPressed: _cargando ? null : _publicarDestino,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          esEdicion ? 'ACTUALIZAR CAMBIOS' : 'PUBLICAR AHORA',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
