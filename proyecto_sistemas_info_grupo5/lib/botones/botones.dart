import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/cargar_destino_page.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';
import 'package:proyecto_sistemas_info_grupo5/login/register_screen.dart';

class Botones extends StatelessWidget {
  const Botones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox
        .shrink(); //Esto se puso para que no se muestren los botones de demostración de la página principal
  }
}

// --- PANTALLA DE INICIO DE SESIÓN ---
class LoginScreen extends StatefulWidget {
  final String rol; // Recibe el rol seleccionado

  const LoginScreen({Key? key, required this.rol}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión como ${widget.rol}'),
        backgroundColor:
            widget.rol == 'Operador' ? Colors.blueAccent : Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¡Hola, ${widget.rol}! Ingresa tus datos',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.rol == 'Operador'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // Aquí simularías la validación con tu base de datos o Firebase.
                // Por ahora, redirige según el rol que traía desde la pantalla anterior.

                if (widget.rol == 'Operador') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CargarDestinoPage(categoriaInicial: ''),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
              child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            // Redirecciona al registro si no tiene cuenta
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(
                  color: widget.rol == 'Operador'
                      ? Colors.blueAccent
                      : Colors.orangeAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
