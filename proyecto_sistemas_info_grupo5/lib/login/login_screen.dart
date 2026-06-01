import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Barra de navegación superior
          Container(
            height: 60,
            color: const Color(0xFF00B14F), // Verde institucional
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Aquí ponemos el logo
                Image.asset('assets/logo_rutas.png', height: 40),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.home, color: Colors.white, size: 18),
                      label: const Text('Inicio', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.white, size: 18),
                      label: const Text('Buscar', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Contenido central (Formulario)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Icono de ubicación (usando tu asset)
                  Image.asset('assets/ubicacion.png', height: 60),
                  const SizedBox(height: 15),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Accede a tu cuenta de EcoRutas', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  
                  // Tarjeta del formulario
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                      ],
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'tu@email.com',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '********',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B14F),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        const Center(child: Text('Acceso rápido de demostración:', style: TextStyle(color: Colors.grey, fontSize: 12))),
                        const SizedBox(height: 10),
                        _buildDemoButton('Demo Viajero', Colors.blue[50]!, Colors.blue),
                        const SizedBox(height: 8),
                        _buildDemoButton('Demo Operador', Colors.purple[50]!, Colors.purple),
                        const SizedBox(height: 8),
                        _buildDemoButton('Demo Admin', Colors.orange[50]!, Colors.orange),
                        const SizedBox(height: 20),
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: TextStyle(color: Colors.black87),
                              children: [
                                TextSpan(text: 'Regístrate aquí', style: TextStyle(color: Color(0xFF00B14F), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Footer Oscuro
          Container(
            color: const Color(0xFF1C2A39),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EcoRutas Venezuela', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Plataforma de turismo económico y\nsostenible para la comunidad Unimet', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enlaces', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Buscar Destinos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Iniciar Sesión', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contacto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Universidad Metropolitana\nCaracas, Venezuela', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    // Agregando el logo de la UNIMET en el footer
                    Image.asset('assets/logo_unimet.png', height: 40), 
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDemoButton(String text, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(5)),
      child: Center(
        child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}