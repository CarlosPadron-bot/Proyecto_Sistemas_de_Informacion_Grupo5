// ==========================================
// PROYECTO: RutasVzla
// MÓDULO: Homepage / Pantalla Principal
// ==========================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_sistemas_info_grupo5/Servicios/reserva_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/reserva_model.dart';
import '../login/login_screen.dart';
import '../buscar/buscar_page.dart';
import '../profile/profile_screen.dart';
import 'DetalleDestinoPage.dart';
import 'dart:convert';
import 'dart:html' as html;

// ==========================================
// MÓDULO: HOMEPAGE (CON SALUDO PERSONALIZADO)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _procesandoPagoGlobal = false;
  final ReservaService _reservaService = ReservaService();

  static const String _clientId =
      "AQrCoKvqDCye6ty5CJIxAUDMujXmScsnoDgpesG6NTOSeHVfNwxYdLxsb1J9OvRV3YU40ubOxRLd_DjL";
  static const String _secretKey =
      "EGtlnnLGI5ckxe9Z5zz-cLfcZs_f-GZ6a5cu7wsFS-Ncxz4pRgNDSaANGNZWkH1Qp50z6-7Bvit1YfGp";

  @override
  void initState() {
    super.initState();
    // Apenas pise la aplicación, revisamos si viene con tokens de PayPal en la URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarPagoDesdeRaiz();
    });
  }

  Future<void> _verificarPagoDesdeRaiz() async {
    final Uri uri = Uri.parse(html.window.location.href.replaceFirst('#/', ''));
    final String? tokenOrden = uri.queryParameters['token'];
    final String? payerId = uri.queryParameters['PayerID'];

    if (tokenOrden != null && payerId != null && !_procesandoPagoGlobal) {
      if (!mounted) return;
      setState(() {
        _procesandoPagoGlobal = true;
      });

      try {
        // 1. Obtener token de acceso de PayPal
        final authTokenResponse = await http.post(
          Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$_clientId:$_secretKey'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'grant_type': 'client_credentials'},
        );

        if (authTokenResponse.statusCode != 200) throw Exception("Error OAuth");
        final String accessToken =
            jsonDecode(authTokenResponse.body)['access_token'];

        // 2. Consultar detalles en PayPal para saber qué destino se compró y su monto
        final detailsResponse = await http.get(
          Uri.parse(
              'https://api-m.sandbox.paypal.com/v2/checkout/orders/$tokenOrden'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (detailsResponse.statusCode != 200)
          throw Exception("Error Detalles");
        final dataDetalles = jsonDecode(detailsResponse.body);

        final String destinoNombre = dataDetalles['purchase_units'][0]
                ['custom_id'] ??
            'Destino Turístico';
        final String totalValue =
            dataDetalles['purchase_units'][0]['amount']['value'] ?? '0.0';

        // 3. Capturar el cobro real de la orden
        final captureResponse = await http.post(
          Uri.parse(
              'https://api-m.sandbox.paypal.com/v2/checkout/orders/$tokenOrden/capture'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        final dataOrden = jsonDecode(captureResponse.body);

        if (captureResponse.statusCode == 200 ||
            captureResponse.statusCode == 201) {
          if (dataOrden['status'] == 'COMPLETED') {
            final user = FirebaseAuth.instance.currentUser;
            String operadorIdDelDestino = '';
            String imagenDelDestino = '';
            try {
              final destinoQuery = await FirebaseFirestore.instance
                  .collection('destinos')
                  .where('nombre', isEqualTo: destinoNombre)
                  .limit(1)
                  .get();

              if (destinoQuery.docs.isNotEmpty) {
                // ASIGNAMOS VALORES A LAS VARIABLES DECLARADAS
                final docDestino = destinoQuery.docs.first;
                final dataDestino = docDestino.data();

                imagenDelDestino = dataDestino['urlImagen'] ?? '';
                operadorIdDelDestino =
                    dataDestino['operadorId'] ?? ''; // Ahora esto funciona

                // Realizamos la transacción usando la referencia del documento
                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {
                  DocumentSnapshot snapshotDestino =
                      await transaction.get(docDestino.reference);
                  if (snapshotDestino.exists) {
                    Map<String, dynamic> data =
                        snapshotDestino.data() as Map<String, dynamic>;
                    String infoExtraActual = data['infoExtra'] ?? '';

                    if (infoExtraActual.contains('|')) {
                      List<String> partes = infoExtraActual.split('|');
                      int cuposActuales = int.tryParse(partes[0]
                              .trim()
                              .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;

                      if (cuposActuales > 0) {
                        String nuevaInfoExtra =
                            '${cuposActuales - 1} Cupos | ${partes[1].trim()}';
                        transaction.update(docDestino.reference,
                            {'infoExtra': nuevaInfoExtra});
                      }
                    }
                  }
                });
              }
            } catch (e) {
              debugPrint("Error en lógica de destino: $e");
            }

            // 4. Instanciamos la nueva reserva con el operadorId obtenido
            final nuevaReserva = Reserva(
              id: '',
              usuarioId: user?.uid ?? 'anonimo',
              destinoId: destinoNombre,
              destinoNombre: destinoNombre,
              precioTotal: double.tryParse(totalValue) ?? 0.0,
              fechaCompra: DateTime.now(),
              urlImagen: imagenDelDestino,
              operadorId: operadorIdDelDestino,
              completa: false,
            );

            // 5. Guardar en Firebase de una vez
            await FirebaseFirestore.instance.collection('reservas').add({
              ...nuevaReserva.toMap(),
              'estado': 'Pagada',
              'operadorId': operadorIdDelDestino,
              'precio': double.tryParse(totalValue) ?? 0.0,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Pago Exitoso! Tu destino ya está guardado.'),
                backgroundColor: Color(0xFF009933),
              ),
            );

            if (mounted) {
              setState(() {
                _procesandoPagoGlobal = false;
              });

              // Limpiamos de raíz la barra de direcciones del navegador
              final String rutaLimpia = "${html.window.location.origin}/#/";
              html.window.history.replaceState({}, '', rutaLimpia);

              // Redirigimos de inmediato a la pantalla del perfil para que vea sus reservas
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }
          }
        }
      } catch (e) {
        // En caso de fallo limpiamos la barra para que no se tranque en bucle
        final String rutaLimpia = "${html.window.location.origin}/#/";
        html.window.history.replaceState({}, '', rutaLimpia);
        if (mounted) {
          setState(() {
            _procesandoPagoGlobal = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_procesandoPagoGlobal) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF2E7D32)),
              SizedBox(height: 20),
              Text(
                'Confirmando tu transacción con PayPal...',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor, espera un momento mientras creamos tu reserva.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    // Obtenemos el ID del usuario autenticado actualmente
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo claro neutro
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Principal Verde (Sección Informativa)
            const BannerPrincipal(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BLOQUE DE BIENVENIDA PERSONALIZADA (PROTEGIDO) ---
                  if (uid.isNotEmpty)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String username =
                            'Viajero'; // Nombre por defecto si está cargando

                        // Validación defensiva estricta para evitar barras rojas en la interfaz
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            username = data['nombre'] ??
                                data['username'] ??
                                data['displayName'] ??
                                'Viajero';
                          }
                        }

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 20.0, top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.waving_hand,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '¡Hola, $username!',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

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
// WIDGET CARRUSEL HORIZONTAL DINÁMICO (FILTRADO EN FLUTTER)
// ==========================================
class HorizontalCarousel extends StatelessWidget {
  final bool isAccommodation;

  const HorizontalCarousel({super.key, required this.isAccommodation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Altura para quepa el nuevo boton
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(isAccommodation
                    ? 'No hay alojamientos.'
                    : 'No hay paquetes.'));
          }

          // Filtramos primero
          final todosLosDestinos = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String categoria = data['categoria'] ?? '';
            final String infoExtra = data['infoExtra'] ?? '';

            int cupos = 1;
            if (infoExtra.contains('|')) {
              cupos = int.tryParse(infoExtra
                      .split('|')[0]
                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0;
            }
            if (cupos <= 0) return false;

            return isAccommodation
                ? categoria == 'Alojamientos'
                : categoria != 'Alojamientos';
          }).toList();

          if (todosLosDestinos.isEmpty) {
            return Center(
                child: Text(isAccommodation
                    ? 'No hay alojamientos disponibles.'
                    : 'No hay paquetes disponibles.'));
          }

          final destinosParaMostrar = todosLosDestinos.take(6).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinosParaMostrar.length,
                  itemBuilder: (context, index) {
                    final data = destinosParaMostrar[index].data()
                        as Map<String, dynamic>;

                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16.0),
                      child: ItemCardConResenas(
                        titulo: data['nombre'] ?? 'Sin título',
                        ubicacion: data['ubicacion'] ?? 'Ubicación desconocida',
                        infoExtra: data['infoExtra'] ?? '',
                        precio: data['precio']?.toString() ?? '0',
                        tipoPrecio: isAccommodation ? '/noche' : '/persona',
                        categoria: isAccommodation ? 'Alojamiento' : 'Paquete',
                        rutaImagen: data['urlImagen'] ?? '',
                        destinoData: data,
                        incluye: (data['queIncluye'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ??
                            [],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BuscarPage()),
                    );
                  },
                  child: Text(
                    isAccommodation
                        ? 'Ver todos los alojamientos'
                        : 'Ver todos los paquetes',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// WIDGET INTERMEDIO: CALCULA LAS RESEÑAS EN TIEMPO REAL
// ==========================================
class ItemCardConResenas extends StatelessWidget {
  final String titulo;
  final String ubicacion;
  final String infoExtra;
  final String precio;
  final String tipoPrecio;
  final String categoria;
  final String rutaImagen;
  final Map<String, dynamic> destinoData;
  final List<String> incluye;

  const ItemCardConResenas({
    super.key,
    required this.titulo,
    required this.ubicacion,
    required this.infoExtra,
    required this.precio,
    required this.tipoPrecio,
    required this.categoria,
    required this.rutaImagen,
    required this.destinoData,
    required this.incluye,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resenas')
          .where('destinoId', isEqualTo: titulo)
          .snapshots(),
      builder: (context, snapshot) {
        double promedioRating = 0.0;
        int cantidadResenas = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final resenasDocumentos = snapshot.data!.docs;
          cantidadResenas = resenasDocumentos.length;

          double sumaCalificaciones = 0;
          for (var doc in resenasDocumentos) {
            var data = doc.data() as Map<String, dynamic>;
            sumaCalificaciones += (data['calificacion'] ?? 0).toDouble();
          }
          promedioRating = sumaCalificaciones / cantidadResenas;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleDestinoPage(
                  title: titulo,
                  location: ubicacion,
                  price: precio,
                  infoExtra: infoExtra,
                  rating: promedioRating.toString(),
                  reviewCount: cantidadResenas.toString(),
                  imageUrl: rutaImagen,
                  description: destinoData['descripcion'] ??
                      'Disfruta de una experiencia única explorando $titulo.',
                  includes: incluye.isEmpty
                      ? const ['Traslados', 'Hospedaje', 'Guía local']
                      : incluye,
                ),
              ),
            );
          },
          child: ItemCard(
            titulo: titulo,
            ubicacion: ubicacion,
            infoExtra: infoExtra,
            precio: precio,
            tipoPrecio: tipoPrecio,
            calificacion: promedioRating,
            resenas: cantidadResenas,
            categoria: categoria,
            rutaImagen: rutaImagen,
          ),
        );
      },
    );
  }
}

// ==========================================
// WIDGET CARD INDIVIDUAL (CON CONTROL DE OVERFLOW)
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
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child:
                    _buildImage(), // Llama a la nueva función que creamos abajo
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ubicacion,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        infoExtra,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.blueGrey),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 13),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(
                            ' ${resenas == 0 ? '0.0' : calificacion.toStringAsFixed(1)} ($resenas)',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
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

  // --- NUEVA FUNCIÓN PARA RENDERIZAR LA IMAGEN CORRECTAMENTE ---
  Widget _buildImage() {
    // Si la ruta viene vacía por alguna razón, mostramos el cuadro de error
    if (rutaImagen.isEmpty) {
      return _errorPlaceholder();
    }

    // 1. Validamos si es una imagen en texto Base64
    if (rutaImagen.startsWith('base64,')) {
      try {
        return Image.memory(
          base64Decode(rutaImagen.substring(7)), // Quitamos el 'base64,'
          height: 125,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
        );
      } catch (e) {
        return _errorPlaceholder();
      }
    }
    // 2. Si no es Base64, asumimos que es un Link de Internet (Network)
    else {
      return Image.network(
        rutaImagen,
        height: 125,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      );
    }
  }

  // Cuadro gris de repuesto si la imagen falla al cargar
  Widget _errorPlaceholder() {
    return Container(
      height: 125,
      width: double.infinity,
      color: Colors.grey[300],
      child:
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
    );
  }
}

// Títulos de Sección
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}

// Banner Principal con el botón "Explorar Destinos"
// ==========================================
// Banner Principal con el botón "Explorar Destinos"
// ==========================================
class BannerPrincipal extends StatelessWidget {
  const BannerPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      color: const Color(0xFF2E7D32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Descubre Venezuela sin Gastar de Más',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Turismo económico, auténtico y sostenible al alcance de todos',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // LÓGICA DE NAVEGACIÓN AÑADIDA AQUÍ
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuscarPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  const Color(0xFF2E7D32), // Corregido al verde clarito
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
// COMPONENTE: HEADER SUPERIOR ESTÁTICO (COLOR ACTUALIZADO)
// ==========================================
class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          const Color(0xFF2E7D32), // Verde claro de inicio uniforme
      elevation: 0,
      automaticallyImplyLeading: false,

      title: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LADO IZQUIERDO: Logo y Nombre
            Row(
              children: [
                Image.asset(
                  'assets/logo_rutas.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.terrain, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                const Text(
                  'RutasVzla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            // LADO DERECHO: Menú de Navegación y Auth integrados directamente aquí
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    html.window.location.href =
                        "${html.window.location.origin}/#/";
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.home, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Inicio',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BuscarPage()),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Buscar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Bloque del usuario o botón de inicio de sesión
                _buildAuthButton(context),
              ],
            ),
          ],
        ),
      ),
      // Dejamos actions vacío ya que ordenamos todo limpiamente en el title expandido
      actions: const [SizedBox.shrink()],
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          );
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            }

            String username = 'Usuario';
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              username =
                  userData['nombre'] ?? userData['username'] ?? 'Usuario';
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.person,
                        size: 16), // Ícono sólido idéntico a la captura
                    label: Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                  label: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
