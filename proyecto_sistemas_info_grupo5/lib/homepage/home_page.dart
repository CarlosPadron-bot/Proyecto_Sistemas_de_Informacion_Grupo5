import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_screen.dart';
import 'DetalleDestinoPage.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Principal Informativo
            const BannerPrincipal(),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN 1: PAQUETES DESTACADOS ---
                  const SectionTitle(title: 'Paquetes Destacados'),
                  const SizedBox(height: 12),
                  const HorizontalCarousel(isAccommodation: false),
                  
                  const SizedBox(height: 24),
                  
                  // --- SECCIÓN 2: ALOJAMIENTOS ECONÓMICOS ---
                  const SectionTitle(title: 'Alojamientos Económicos'),
                  const SizedBox(height: 12),
                  const HorizontalCarousel(isAccommodation: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==========================================
// WIDGET CARRUSEL HORIZONTAL (CON LISTAS REALES)
// ==========================================
class HorizontalCarousel extends StatelessWidget {
  final bool isAccommodation;


  const HorizontalCarousel({super.key, required this.isAccommodation});


  @override
  Widget build(BuildContext context) {
    // 1. Lista Real para la sección de Paquetes
    final List<Map<String, dynamic>> paquetesDestacados = [
      {
        'titulo': 'Aventura Los Roques 3 Días',
        'ubicacion': 'Los Roques, Dependencias Federales',
        'info': '3 días · 6 cupos',
        'precio': '280',
        'tipo': '/persona',
        'calificacion': 4.9,
        'resenas': 56,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/isla_la_tortuga.png',
      },
      {
        'titulo': 'Salto Ángel Express 2 Días',
        'ubicacion': 'Canaima, Bolívar',
        'info': '2 días · 12 cupos',
        'precio': '195',
        'tipo': '/persona',
        'calificacion': 4.7,
        'resenas': 43,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/salto_angel.png',
      },
      {
        'titulo': 'Ruta Andina Económica 4 Días',
        'ubicacion': 'Mérida, Mérida',
        'info': '4 días · 15 cupos',
        'precio': '165',
        'tipo': '/persona',
        'calificacion': 4.6,
        'resenas': 38,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/merida.png',
      },
      {
        'titulo': 'Morrocoy Fin de Semana',
        'ubicacion': 'Parque Nacional Morrocoy',
        'info': '2 días · 10 cupos',
        'precio': '120',
        'tipo': '/persona',
        'calificacion': 5.0,
        'resenas': 91,
        'categoria': 'Paquete',
        'rutaImagen': 'assets/morrocoy.png',
      },
    ];


    // 2. Lista Real para la sección de Alojamientos
    final List<Map<String, dynamic>> alojamientosEconomicos = [
      {
        'titulo': 'Posada Los Roques Paradise',
        'ubicacion': 'Gran Roque, Los Roques',
        'info': 'Hasta 6 personas',
        'precio': '45',
        'tipo': '/noche',
        'calificacion': 4.8,
        'resenas': 24,
        'categoria': 'Posada',
        'rutaImagen': 'assets/los_roques.png',
      },
      {
        'titulo': 'Camping Canaima',
        'ubicacion': 'Parque Nacional Canaima',
        'info': 'Hasta 4 personas',
        'precio': '15',
        'tipo': '/noche',
        'calificacion': 4.5,
        'resenas': 18,
        'categoria': 'Camping',
        'rutaImagen': 'assets/posada.png',
      },
      {
        'titulo': 'Cabaña Montaña Mérida',
        'ubicacion': 'Los Nevados, Mérida',
        'info': 'Hasta 8 personas',
        'precio': '35',
        'tipo': '/noche',
        'calificacion': 4.4,
        'resenas': 31,
        'categoria': 'Cabaña',
        'rutaImagen': 'assets/caba_merida.png',
      },
    ];


    // Selecciona la lista adecuada basándose en el booleano
    final listaAUsar = isAccommodation ? alojamientosEconomicos : paquetesDestacados;


    return SizedBox(
      height: 350, // Altura óptima para contener todo el diseño flexible
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listaAUsar.length,
        itemBuilder: (context, index) {
          final destino = listaAUsar[index];
          
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16.0, bottom: 8.0), // Margen inferior para respirar
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleDestinoPage(
                      title: destino['titulo'],
                      location: destino['ubicacion'],
                      price: destino['precio'],
                      priceSuffix: destino['tipo'],
                      rating: destino['calificacion'].toString(),
                      reviewCount: destino['resenas'].toString(),
                      imageUrl: destino['rutaImagen'],
                      description: 'Disfruta de una experiencia ecológica única explorando de cerca el destino ${destino['titulo']}. Incluye guías locales certificados y hospedaje sustentable.',
                      includes: const [
                        'Traslados ecológicos',
                        'Hospedaje Sustentable',
                        'Guía local certificado'
                      ],
                    ),
                  ),
                );
              },
              child: ItemCard(
                titulo: destino['titulo'],
                ubicacion: destino['ubicacion'],
                infoExtra: destino['info'],
                precio: destino['precio'],
                tipoPrecio: destino['tipo'],
                calificacion: destino['calificacion'],
                resenas: destino['resenas'],
                categoria: destino['categoria'],
                rutaImagen: destino['rutaImagen'],
              ),
            ),
          );
        },
      ),
    );
  }
}


// ==========================================
// WIDGET CARD DE ÍTEM INDIVIDUAL (DISEÑO ANTI-OVERFLOW - CORREGIDO)
// ==========================================
class ItemCard extends StatelessWidget {
  final String titulo;
  final String ubicacion;
  final String infoExtra;
  final String precio;
  final String tipoPrecio;
  final double calificacion;
  final int resenas;
  final String categoria;
  final String rutaImagen;


  const ItemCard({
    super.key,
    required this.titulo,
    required this.ubicacion,
    required this.infoExtra,
    required this.precio,
    required this.tipoPrecio,
    required this.calificacion,
    required this.resenas,
    required this.categoria,
    required this.rutaImagen,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sección superior de Imagen con etiqueta fija
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  rutaImagen,
                  height: 125, // Reducido sutilmente para maximizar el área de textos
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 125,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          
          // 2. Sección inferior de textos (CORREGIDO: sin Expanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Empuja precios al fondo
              children: [
                // Bloque de información descriptiva
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Corta títulos largos con (...)
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ubicacion,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      infoExtra,
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                // Bloque de fila inferior: Precio y Calificación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$precio$tipoPrecio',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(
                          ' $calificacion ($resenas)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// OTROS WIDGETS AUXILIARES REUTILIZADOS
// ==========================================
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});


  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}


class BannerPrincipal extends StatelessWidget {
  const BannerPrincipal({super.key});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Explora la majestuosidad de Venezuela!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Encuentra las mejores eco-rutas, posadas sustentables y campings para tu próxima aventura respetuosa con el medio ambiente.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});


  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20),
      automaticallyImplyLeading: false,
      title: const Row(
        mainAxisSize: MainAxisSize.min, // Evita que la fila ocupe todo el ancho
        children: [
          Icon(Icons.terrain, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'RutasVzla', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
          builder: (context, snapshot) {
            String username = 'Usuario';
            if (snapshot.hasData && snapshot.data!.exists) {
              username = snapshot.data!['nombre'] ?? 'Usuario';
            }
            
            // Usamos un contenedor flexible para los botones de la derecha
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre del Usuario optimizado
                  Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 16),
                  const SizedBox(width: 4),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80), // Limita el ancho del nombre
                    child: Text(
                      username,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Si el nombre es largo, pone "..."
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Botón Salir más compacto
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                    tooltip: 'Salir',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}