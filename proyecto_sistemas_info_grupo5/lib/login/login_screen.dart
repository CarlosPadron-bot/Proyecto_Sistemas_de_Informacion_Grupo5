import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';
import 'package:proyecto_sistemas_info_grupo5/login/register_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Auth _authService = Auth();

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, introduce tu correo y contraseña.')),
      );
      return;
    }

    // Validación de seguridad local
    if (!email.toLowerCase().endsWith('@correo.unimet.edu.ve')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Acceso denegado. Solo se permiten correos institucionales @correo.unimet.edu.ve'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Intentar iniciar sesión en Firebase
      await _authService.loginConEmail(email, password);

      // Si la autenticación es exitosa se redirige a la HomePage
      if (mounted) {
        Navigator.pushReplacement(
          // Se usa pushReplacement para que no puedan volver al login con el botón de atrás.
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Si Firebase devuelve un error como contraseña incorrecta o si no existe un usuario.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Limpiamos los controladores de memoria al cerrar la pantalla
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Barra de navegación superior
          Container(
            height: 60,
            color: const Color(0xFF00B14F),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                children: [
                  Image.asset('assets/logo_rutas.png', height: 60),
                  const SizedBox(width: 10),
                  const Text(
                    'RutasVzla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      },
                      icon:
                          const Icon(Icons.home, color: Colors.white, size: 20),
                      label: const Text('Inicio',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search,
                          color: Colors.white, size: 18),
                      label: const Text('Buscar',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: const Text('Iniciar Sesión',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Contenido central 
          Expanded(
            child: SingleChildScrollView(
              // El padding se mueve al Container hijo para que el ScrollView toque los bordes
              child: Container(
                width: double.infinity, // Esto empuja la barra a la derecha
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset('assets/ubicacion.png', height: 60),
                    const SizedBox(height: 15),
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Accede a tu cuenta de EcoRutas',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    // Tarjeta del formulario
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Email',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // 3. ASIGNAR CONTROLLER AL CAMPO EMAIL
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'tu@correo.unimet.edu.ve',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Contraseña',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // 4. ASIGNAR CONTROLLER AL CAMPO CONTRASEÑA
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '**********',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(height: 25),
                          // 5. ENLAZAR ACCIÓN AL BOTÓN DE LOGUEO
                          ElevatedButton.icon(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B14F),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: const Text('Iniciar Sesión',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                          
                          const SizedBox(height: 25),
                          
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: '¿No tienes cuenta? ',
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 14),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterScreen()),
                                        );
                                      },
                                      child: const Text(
                                        'Regístrate aquí',
                                        style: TextStyle(
                                          color: Color(0xFF00B14F),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
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
                    const SizedBox(height: 40),
                  ],
                ),
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
                    Text('EcoRutas Venezuela',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                        'Plataforma de turismo económico y\nsostenible para la comunidad Unimet',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enlaces',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Buscar Destinos',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Iniciar Sesión',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contacto',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Universidad Metropolitana\nCaracas, Venezuela',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
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
}
