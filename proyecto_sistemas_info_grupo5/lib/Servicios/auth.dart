//Esta clase es el servicio que se comunicará con Firebase Auth.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> registroConEmail(
      {required String email,
      required String password,
      required String username,
      required String rol}) async {
    try {
      // Validación de dominio
      if (!email.toLowerCase().endsWith('@correo.unimet.edu.ve')) {
        throw Exception(
            'Solo se permiten registros con correos de la Universidad Metropolitana (@correo.unimet.edu.ve).');
      }

      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar datos adicionales en Firestore usando el UID recién creado
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'rol': rol,
        'email': email,
      });

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
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Error en Firebase: ${e.code}");
      rethrow;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
  // NUEVO MÉTODO: Obtener el rol del usuario desde Firestore usando su UID
  Future<String?> obtenerRol(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['rol'] as String?;
      }
      return null;
    } catch (e) {
      print("Error al obtener el rol del usuario desde Firestore: $e");
      return null;
    }
  }
} // Cierre de la clase Auth
