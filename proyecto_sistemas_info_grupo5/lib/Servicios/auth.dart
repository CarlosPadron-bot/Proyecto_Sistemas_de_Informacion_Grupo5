//Esta clase es el servicio que se comunicará con Firebase Auth.
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  // Se instancia el Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // El Stream sirve para escuchar si el usuario ya está logueado o no para saber si aparecer en
  //la pantalla de inicio o en la de inicio de sesión
  //Firebase esta avisando si el usuario esta logueado o no
  //entonces al abrir la app, si encuentra un token guardado, devuelve el usuario
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Función para Iniciar Sesión (Ahora funciona solo para correo Unimet)
  Future<UserCredential?> registroConEmail(
      String email, String password) async {
    try {
      // Validación previa de dominio
      if (!email.toLowerCase().endsWith('@correo.unimet.edu.ve')) {
        throw Exception(
            'Solo se permiten registros con correos de la Universidad Metropolitana (@correo.unimet.edu.ve).');
      }
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Error nativo en Registro Firebase: ${e.code}");
      rethrow;
    } catch (e) {
      print("Error de validación: ${e.toString()}");
      rethrow;
    }
  }

  Future<UserCredential?> loginConEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
      //Aquí se manejan los errores como la contraseña incorrecta.
    } on FirebaseAuthException catch (e) {
      print("Error en Firebase: ${e.code}");
      rethrow;
    }
  }

  // Función para cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
