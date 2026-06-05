import 'package:flutter/material.dart';
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
  final Auth _authService = Auth();

  String _rolSeleccionado = 'Viajero';

  void _handleRegister() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    try {
      //El controlador valida y registra en Firebase.
      await _authService.registroConEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) {
        // 1. Avisamos al usuario que se creó la cuenta
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Cuenta UNIMETANA creada con éxito! :D')),
        );

        // 2. Evaluamos el rol para redirigir a la pantalla correspondiente
        if (_rolSeleccionado == 'Operador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CargarDestinoPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
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
