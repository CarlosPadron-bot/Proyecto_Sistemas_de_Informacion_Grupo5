import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';

class CargarDestinoPage extends StatefulWidget {
  final String categoriaInicial; // 'Paquetes Turisticos' o 'Alojamientos'

  const CargarDestinoPage({super.key, required this.categoriaInicial});

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
  final TextEditingController _urlImagenController = TextEditingController();
  final TextEditingController _infoExtraController = TextEditingController();
  final TextEditingController _incluyeController =
      TextEditingController(); // Separados por comas

  String _estadoSeleccionado = 'Caracas';
  bool _cargando = false;

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

  void _publicarDestino() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    // Procesar lista de lo que incluye
    List<String> incluyeList = _incluyeController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      double precioDouble =
          double.tryParse(_precioController.text.trim()) ?? 0.0;

      Destino nuevoDestino = Destino(
        nombre: _nombreController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
        precio: precioDouble,
        descripcion: _descripcionController.text.trim(),
        urlImagen: _urlImagenController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7' // Fallback elegante
            : _urlImagenController.text.trim(),
        categoria: widget.categoriaInicial,
        infoExtra: _infoExtraController.text.trim().isEmpty
            ? (widget.categoriaInicial == 'Alojamientos'
                ? 'Por noche'
                : 'Cupos limitados')
            : _infoExtraController.text.trim(),
        queIncluye: incluyeList.isEmpty ? ['Hospedaje o Guía'] : incluyeList,
        estado: _estadoSeleccionado,
      );

      await _destinoService.guardarDestino(nuevoDestino);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Servicio turístico publicado con éxito!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volver al panel anterior
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
                'Publicar ${widget.categoriaInicial == 'Alojamientos' ? 'Alojamiento' : 'Paquete Turístico'}',
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
                    child: TextFormField(
                      controller: _infoExtraController,
                      decoration: const InputDecoration(
                          labelText: 'Disponibilidad (Ej: 3 días · 2 cupos)',
                          border: OutlineInputBorder()),
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
              TextFormField(
                controller: _urlImagenController,
                decoration: const InputDecoration(
                    labelText: 'URL de la imagen de portada',
                    border: OutlineInputBorder()),
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
                      : const Text('PUBLICAR AHORA',
                          style: TextStyle(
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
