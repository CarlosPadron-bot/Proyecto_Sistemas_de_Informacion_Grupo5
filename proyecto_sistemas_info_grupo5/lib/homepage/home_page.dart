import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_screen.dart';
import 'DetalleDestinoPage.dart';


//=============================
// Vista principal con diseño responsivo, carruseles horizontales
// y barra de navegación optimizada integrada con Firebase.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(), // El AppBar Verde exacto de la imagen
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Principal Verde con el botón de "Explorar Destinos"
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

    // Selección lógica de la fuente de datos según la propiedad recibida
    final listaAUsar = isAccommodation ? alojamientosEconomicos : paquetesDestacados;

    return SizedBox(
      height: 350, // Altura calculada para evitar desbordes
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listaAUsar.length,
        itemBuilder: (context, index) {
          final destino = listaAUsar[index];
          
          return Container(
            width: 280, //Ancho fijado estandar
            margin: const EdgeInsets.only(right: 16.0, bottom: 8.0), 
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
// WIDGET CARD DE ÍTEM INDIVIDUAL (SOLUCIÓN FLEXIBLE)
// ==========================================
// ItemCard es para implementar un diseño anti overflow
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  rutaImagen,
                  height: 125, 
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
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, 
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
          ),
        ],
      ),
    );
  }
}

// ==========================================
// COMPONENTES DE INTERFAZ AUXILIARES
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

// ==========================================
// BANNER PRINCIPAL 
// ==========================================
class BannerPrincipal extends StatelessWidget {
  const BannerPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      color: const Color(0xFF2E7D32), // Color verde exacto del banner de fondo
      child: Column(
        // Línea corregida:
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Descubre Venezuela sin Gastar de Más',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Turismo económico, auténtico y sostenible al alcance de todos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Botón blanco central "Explorar Destinos"
          ElevatedButton.icon(
            onPressed: () {
              // Acción para explorar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.search, size: 18),
            label: const Text(
              'Explorar Destinos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// COMPONENTE DE LA BARRA DE NAVEGACIÓN
// ==========================================
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20), // Color verde oscuro de la barra
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
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
        // 1. Botón "Inicio" con icono de casa blanco
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.home, color: Colors.white, size: 16),
          label: const Text(
            'Inicio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        const SizedBox(width: 4),

        // 2. Botón "Buscar" con icono de lupa blanco
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Colors.white, size: 16),
          label: const Text(
            'Buscar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        const SizedBox(width: 4),

        // 3. Botón dinámico del Usuario (Muestra "Freddy F" o el real desde Firestore de forma segura)
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
          builder: (context, snapshot) {
            String username = 'Freddy F'; // Valor por defecto idéntico a tu mockup
            
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                // Intenta mapear dinámicamente cualquier campo que contenga el nombre en tu Firestore
                username = data['nombre'] ?? data['username'] ?? data['displayName'] ?? 'Freddy F';
              }
            }
            
            return TextButton.icon(
              onPressed: () {
                // Acción para ir al perfil
              },
              icon: const Icon(Icons.person_outline, color: Colors.white, size: 16),
              label: Container(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 4),

        // 4. Botón "Salir" con icono de logout blanco
        TextButton.icon(
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
          icon: const Icon(Icons.logout, color: Colors.white, size: 16),
          label: const Text(
            'Salir',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}