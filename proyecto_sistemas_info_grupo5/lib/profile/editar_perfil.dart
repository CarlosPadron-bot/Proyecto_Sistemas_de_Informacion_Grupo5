import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _biografiaController = TextEditingController();

  bool _cargandoDatos = true;
  bool _guardando = false;
  String? _currentPhotoUrl;
  String _userRole =
      'viajero'; // 🛠️ Guardamos el rol para pintar el badge correcto
  String _inicialNombre = 'U';

  Uint8List? _webImageBytes;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('usuarios').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? '';
          _telefonoController.text = data['telefono'] ?? '';
          _direccionController.text = data['direccion'] ?? '';
          _biografiaController.text = data['biografia'] ?? '';
          _currentPhotoUrl = data['photoUrl'];
          _userRole = data['rol'] ?? 'viajero'; // 🛠️ Obtenemos el rol original

          if (_usernameController.text.isNotEmpty) {
            _inicialNombre = _usernameController.text[0].toUpperCase();
          }
        }
      } catch (e) {
        print("Error al cargar datos: $e");
      }
    }
    setState(() => _cargandoDatos = false);
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _pickedFile = image;
        });
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final user = _auth.currentUser;

    if (user != null) {
      try {
        String? finalPhotoUrl = _currentPhotoUrl;

        if (kIsWeb && _webImageBytes != null) {
          final String base64String = base64Encode(_webImageBytes!);
          finalPhotoUrl = 'base64,$base64String';
        }

        await _firestore.collection('usuarios').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'direccion': _direccionController.text.trim(),
          'biografia': _biografiaController.text.trim(),
          'photoUrl': finalPhotoUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Perfil actualizado con éxito!'),
              backgroundColor: Color(0xFF009933),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al guardar cambios: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _guardando = false);
        }
      }
    } else {
      setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  ImageProvider? _obtenerImagenPerfil() {
    if (_webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    }

    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      if (_currentPhotoUrl!.startsWith('base64,')) {
        try {
          final String cadenaLimpia =
              _currentPhotoUrl!.replaceFirst('base64,', '');
          return MemoryImage(base64Decode(cadenaLimpia));
        } catch (e) {
          return null;
        }
      } else {
        return NetworkImage(_currentPhotoUrl!);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Configuración del Sistema',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF009933),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _cargandoDatos
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009933)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 24.0),
                child: Container(
                  width: 750,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Editar Perfil',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Actualiza tu información personal y cómo te verán los demás usuarios.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Divider(height: 40, thickness: 1.2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor:
                                      const Color(0xFF009933).withOpacity(0.1),
                                  backgroundImage: _obtenerImagenPerfil(),
                                  child: _webImageBytes == null &&
                                          _currentPhotoUrl == null
                                      ? Text(
                                          _inicialNombre,
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF009933)),
                                        )
                                      : null,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFCC00),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: _seleccionarImagen,
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.black87, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _usernameController.text.isNotEmpty
                                        ? _usernameController.text
                                        : "Usuario",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _auth.currentUser?.email ?? '',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildRoleBadge(_userRole),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Nombre de Usuario'),
                                  TextFormField(
                                    controller: _usernameController,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isNotEmpty) {
                                          _inicialNombre =
                                              value[0].toUpperCase();
                                        }
                                      });
                                    },
                                    decoration: _buildInputDecoration(
                                        'Tu nombre de perfil'),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'El nombre es obligatorio'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Correo Institucional'),
                                  TextFormField(
                                    initialValue: _auth.currentUser?.email,
                                    enabled: false,
                                    style: const TextStyle(color: Colors.grey),
                                    decoration:
                                        _buildInputDecoration('').copyWith(
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          size: 16, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Teléfono de Contacto'),
                                  TextFormField(
                                    controller: _telefonoController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    decoration: _buildInputDecoration(
                                        'Ej. 04121112233'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null;
                                      }
                                      if (value.length != 11) {
                                        return 'El número debe tener exactamente 11 dígitos';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Dirección de Residencia'),
                                  TextFormField(
                                    controller: _direccionController,
                                    decoration: _buildInputDecoration(
                                        'Ej. Urb. Terrazas del Ávila, Caracas'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Biografía / Presentación Personal'),
                        TextFormField(
                          controller: _biografiaController,
                          maxLines: 4,
                          maxLength: 200,
                          decoration: _buildInputDecoration(
                              'Escribe una breve descripción para que la comunidad te conozca...'),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 48,
                              width: 130,
                              child: OutlinedButton(
                                onPressed: _guardando
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Cancelar',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                        fontSize: 15)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 48,
                              width: 180,
                              child: ElevatedButton(
                                onPressed: _guardando ? null : _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009933),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 1,
                                ),
                                child: _guardando
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Text('Guardar Cambios',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrador':
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        label = 'Administrador';
        break;
      case 'operator':
      case 'operador':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        label = 'Operador';
        break;
      default:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        label = 'Viajero';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF009933), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }
}
