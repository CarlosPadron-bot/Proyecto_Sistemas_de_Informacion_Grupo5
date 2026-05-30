//Esta clase es el servicio que se comunicará con Firebase Auth.

import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  // Se instancia el Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // El Stream sirve para escuchar si el usuario ya está logueado o no para saber si aparecer en
  //la pantalla de inicio o en la de inicio de sesión
  Stream<User?> get userStatus {
    return _auth.authStateChanges();
  }

  // Función para Iniciar Sesión
  Future<UserCredential?> loginConEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      //Aquí se manejaran los distintos errores que se puedan tener como la contraseña incorrecta
      print("Error en Firebase: ${e.code}");
      rethrow;
    }
  }

  // Función para cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
