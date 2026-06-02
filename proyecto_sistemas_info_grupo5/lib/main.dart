import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDn6HXszsc_m3z824S4JxBr2TUyumxPp3A",
      authDomain: "ecorutasvzla-fbb2d.firebaseapp.com",
      projectId: "ecorutasvzla-fbb2d",
      storageBucket: "ecorutasvzla-fbb2d.firebasestorage.app",
      messagingSenderId: "167300911659",
      appId: "1:167300911659:web:01e54a10f7b6b6f3cd106e",
      measurementId: "G-HE9N1YD5W5",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Sistemas Info Grupo 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009933)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
