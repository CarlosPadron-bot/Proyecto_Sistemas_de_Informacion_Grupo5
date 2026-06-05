import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/destino_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/destino_model.dart';

class CargarDestinoPage extends StatefulWidget {
  const CargarDestinoPage({super.key});

  @override
  State<CargarDestinoPage> createState() => _CargarDestinoPageState();
}

class _CargarDestinoPageState extends State<CargarDestinoPage> {
  final _formKey = GlobalKey<FormState>();
  final DestinoService _destinoService = DestinoService();

  // Controladores para capturar los textos
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  // Creamos la instancia del modelo con los datos del formulario
  void _subirDestino() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final nuevoDestino = Destino(
      nombre: _nombreController.text.trim(),
      ubicacion: _ubicacionController.text.trim(),
      precio: double.tryParse(_precioController.text.trim()) ?? 0.0,
      descripcion: _descripcionController.text.trim(),
      urlImagen: _imagenController.text.trim().isEmpty
          ? 'https://via.placeholder.com/150'
          : _imagenController.text.trim(),
    );

    try {
      // Llamamos al servicio (Controlador) para enviarlo a Firestore
      await _destinoService.guardarDestino(nuevoDestino);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Destino turístico cargado con éxito! 🌱'),
            backgroundColor: Color(0xFF009933),
            duration: Duration(seconds: 2), // El banner dura 2 segundos
          ),
        );
        _formKey.currentState!.reset(); // Limpia los campos de texto

        // <<< NUEVA MEJORA DE NAVEGACIÓN >>>
        // Esperamos 2 segundos para que el usuario lea el mensaje de éxito
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Saca esta vista y regresa automáticamente a la HomePage anterior
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Destino EcoRutas'),
        backgroundColor: const Color(0xFF009933),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registrar Opción Económica / Destino',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009933)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre del Destino (ej. Morrocoy)',
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _ubicacionController,
                    decoration: const InputDecoration(
                        labelText: 'Ubicación / Estado',
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Precio Estimado (\$ USD)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ '),
                    validator: (v) {
                      if (v!.isEmpty) return 'Campo obligatorio';
                      if (double.tryParse(v) == null)
                        return 'Ingrese un número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Descripción de la opción sustentable',
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _imagenController,
                    decoration: const InputDecoration(
                        labelText: 'URL de Imagen (Opcional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _cargando ? null : _subirDestino,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009933),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Subir a EcoRutas',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
