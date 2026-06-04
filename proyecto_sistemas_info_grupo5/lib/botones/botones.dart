import 'package:flutter/material.dart';

class Botones extends StatelessWidget {
  const Botones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        children: [
          const Text(
            'Selecciona tu rol para ingresar:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // Botón de Operador
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.storefront),
                  label: const Text('Operador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    // Llevamos al Login pasando el rol de 'Operador'
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen(rol: 'Operador'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              // Botón de Viajero
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flight_takeoff),
                  label: const Text('Viajero'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    // Llevamos al Login pasando el rol de 'Viajero'
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(rol: 'Viajero'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                      builder: (context) => const VistaOperadorScreen(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VistaViajeroScreen(),
                    ),
                  );
                }
              },
              child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- VISTAS FINALES SIMULADAS ---

class VistaOperadorScreen extends StatelessWidget {
  const VistaOperadorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Operador')),
      body: const Center(
        child: Text(
          'Aquí se muestran TUS PAQUETES REGISTRADOS 📦',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class VistaViajeroScreen extends StatelessWidget {
  const VistaViajeroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Viajes')),
      body: const Center(
        child: Text(
          'Aquí se muestran los PAQUETES QUE QUIERES COMPRAR ✈️',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
