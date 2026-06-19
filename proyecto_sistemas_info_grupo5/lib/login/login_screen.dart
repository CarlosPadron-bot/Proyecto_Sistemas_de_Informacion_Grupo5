import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/homepage/home_page.dart';
import 'package:proyecto_sistemas_info_grupo5/login/register_screen.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/auth.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/admin_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/operador/operador_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_sistemas_info_grupo5/buscar/buscar_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Auth _authService = Auth();
  String? _errorCredenciales;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    setState(() {
      _errorCredenciales = null;
    });

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, introduce tu correo y contraseña.')),
      );
      return;
    }

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
      // 1. Intentar iniciar sesión en Firebase Auth
      UserCredential? userCredential =
          await _authService.loginConEmail(email, password);

      if (userCredential != null && userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // 🔥 --- NUEVA VERIFICACIÓN: DETECTAR BORRADO LÓGICO --- 🔥
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          final bool estaEliminado = data?['eliminado'] ?? false;

          // Si el usuario tiene la marca de eliminado, frenamos el acceso en seco
          if (estaEliminado) {
            await FirebaseAuth.instance.signOut(); // Lo expulsamos de las sesiones activas
            if (mounted) {
              setState(() {
                _errorCredenciales = 'Esta cuenta ha sido eliminada por la administración.';
              });
            }
            return; // Cortamos la función para que no avance hacia los dashboards ni la homepage
          }
        }

        // 2. Consultar el rol en Firestore antes de redirigir
        String? rol = await _authService.obtenerRol(uid);

        if (mounted) {
          // 3. Redirección inteligente basada en el rol guardado
          // Usamos .toLowerCase() para evitar errores si lo guardaste como "admin", "Admin", etc.
          String rolNormalizado = rol?.toLowerCase() ?? 'viajero';

          Widget pantallaDestino;
          if (rolNormalizado == 'admin') {
            pantallaDestino = const AdminDashboard();
          } else if (rolNormalizado == 'operador') {
            pantallaDestino = const OperadorDashboard();
          } else {
            pantallaDestino = const HomePage(); // Rol 'viajero' o por defecto
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => pantallaDestino),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String errorStr = e.toString().toLowerCase();

          // Detecta si hay algún error de inicio de sesión
          if (errorStr.contains('invalid-credential') ||
              errorStr.contains('wrong-password') ||
              errorStr.contains('user-not-found') ||
              errorStr.contains('invalid-email')) {
            _errorCredenciales = 'Correo o Contraseña incorrecta';
          } else {
            // Esto por si es un error diferente
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al iniciar sesión: ${e.toString()}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        });
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BuscarPage()), // Ajusta si el nombre de tu clase es distinto
                        );
                      },
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                              errorText: _errorCredenciales != null ? '' : null,
                              errorStyle:
                                  const TextStyle(height: 0, fontSize: 0),
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
                              errorText:
                                  _errorCredenciales, //Para mostrar el error de las credenciales
                              errorStyle: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
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
