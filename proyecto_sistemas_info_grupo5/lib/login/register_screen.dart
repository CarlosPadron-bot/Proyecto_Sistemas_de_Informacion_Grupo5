import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/auth.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final Auth _authService = Auth();
  String _rolSeleccionado = 'Viajero';

  void _handleRegister() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim();

    // Se agregó validación para que no dejen el nombre vacío
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    try {
      // El controlador valida y registra en Firebase.
      await _authService.registroConEmail(
        email: email,
        password: password,
        username: username,
        rol: _rolSeleccionado,
      );

      // --- INICIO DE LA SOLUCIÓN DEL NOMBRE ---
      // Obtenemos al usuario que se acaba de crear y loguear
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 1. Actualiza el nombre en Firebase Auth (Para que el header lo lea rápido)
        await currentUser.updateDisplayName(username);

        // 2. Aseguramos que se guarde en Firestore bajo el campo 'username'
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .set(
                {
              'username': username,
              'email': email,
              'rol': _rolSeleccionado,
              'createdAt': FieldValue.serverTimestamp(),
            },
                SetOptions(
                    merge:
                        true)); // 'merge' evita borrar datos si _authService ya había creado el documento
      }
      // --- FIN DE LA SOLUCIÓN DEL NOMBRE ---

      if (mounted) {
        // Avisa al usuario que se creó la cuenta
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Cuenta UNIMETANA creada con éxito! :D')),
        );

        // Evaluamos el rol para redirigir a la pantalla correspondiente
        if (_rolSeleccionado == 'Operador') {
          // Usamos pushAndRemoveUntil para que no puedan darle "Atrás" y volver al registro
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const CargarDestinoPage(
                categoriaInicial: 'Paquetes Turisticos',
              ),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      String mensajeError = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController
        .dispose(); // Es buena práctica limpiar todos los controladores
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Barra superior
            Container(
              height: 60,
              color: const Color(0xFF00B14F),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Crear Cuenta - EcoRutas',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Contenedor Central de Registro
            Center(
              child: Container(
                width: 400,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Icono o Logo pequeño
                    const Icon(Icons.person_add_alt_1,
                        size: 50, color: Color(0xFF00B14F)),
                    const SizedBox(height: 20),
                    const Text(
                      "Registro Universitario",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Usa tu correo @correo.unimet.edu.ve",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 30),

                    // Campo Usuario
                    TextFormField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Nombre de Usuario',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B14F), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo Correo
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Institucional',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B14F), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo Contraseña
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B14F), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _rolSeleccionado,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Usuario / Rol',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B14F), width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Viajero',
                            child: Text('Viajero / Estudiante')),
                        DropdownMenuItem(
                            value: 'Operador',
                            child: Text('Operador Turístico')),
                      ],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _rolSeleccionado = nuevoValor!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // Botón de Acción
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _handleRegister,
                        child: const Text(
                          'REGISTRARSE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
