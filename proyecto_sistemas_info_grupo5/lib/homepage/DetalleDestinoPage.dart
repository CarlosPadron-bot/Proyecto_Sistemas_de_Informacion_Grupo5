import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets_generales/header_gen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- AÑADIDO: Import para validar estado en la BD
import '../login/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import '../Servicios/reserva_service.dart';
import '../modelos/reserva_model.dart';

class DetalleDestinoPage extends StatefulWidget {
  final String title;
  final String location;
  final String price;
  final String priceSuffix;
  final String rating;
  final String reviewCount;
  final String imageUrl;
  final String description;
  final List<String> includes;

  const DetalleDestinoPage({
    Key? key,
    required this.title,
    required this.location,
    required this.price,
    required this.priceSuffix,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.includes,
  }) : super(key: key);

  @override
  State<DetalleDestinoPage> createState() => _DetalleDestinoPageState();
}

class _DetalleDestinoPageState extends State<DetalleDestinoPage>
    with WidgetsBindingObserver {
  int _cantidadViajeros = 1;
  bool _cargandoPago = false;
  final ReservaService _reservaService = ReservaService();

  static const String _clientId =
      "AQrCoKvqDCye6ty5CJIxAUDMujXmScsnoDgpesG6NTOSeHVfNwxYdLxsb1J9OvRV3YU40ubOxRLd_DjL";
  static const String _secretKey =
      "EGtlnnLGI5ckxe9Z5zz-cLfcZs_f-GZ6a5cu7wsFS-Ncxz4pRgNDSaANGNZWkH1Qp50z6-7Bvit1YfGp";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarYRegistrarPago();
    }
  }

  Future<void> _verificarYRegistrarPago() async {
    final Uri uri = Uri.parse(html.window.location.href.replaceFirst('#/', ''));
    final String? tokenOrden = uri.queryParameters['token'];
    final String? payerId = uri.queryParameters['PayerID'];

    if (tokenOrden != null && payerId != null && !_cargandoPago) {
      if (!mounted) return;

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

        if (authTokenResponse.statusCode != 200) return;
        final String accessToken =
            jsonDecode(authTokenResponse.body)['access_token'];

        // 2. Consultar los detalles de la orden en PayPal ANTES de capturar
        final detailsResponse = await http.get(
          Uri.parse(
              'https://api-m.sandbox.paypal.com/v2/checkout/orders/$tokenOrden'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (detailsResponse.statusCode != 200) return;
        final dataDetalles = jsonDecode(detailsResponse.body);

        // Extraemos el custom_id que guardamos al iniciar el pago
        final String destinoIdEnOrden =
            dataDetalles['purchase_units'][0]['custom_id'] ?? '';

        if (destinoIdEnOrden != widget.title) {
          final String rutaLimpia =
              "${html.window.location.origin}/#${html.window.location.pathname}";
          html.window.history.pushState({}, '', rutaLimpia);
          return;
        }

        // Si el destino coincide, procedemos a realizar la captura de forma legítima
        setState(() {
          _cargandoPago = true;
        });

        _mostrarSnackBar(
            'Procesando y confirming tu pago con PayPal...', Colors.blue);

        // 3. Capturar el pago de la orden
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
            double precioIndividual = double.tryParse(widget.price) ?? 280.0;
            double totalCalculado = precioIndividual * _cantidadViajeros;

            final nuevaReserva = Reserva(
              id: '',
              usuarioId: user?.uid ?? 'anonimo',
              destinoId: widget.title,
              destinoNombre: widget.title,
              precioTotal: totalCalculado,
              fechaCompra: DateTime.now(),
              urlImagen: widget.imageUrl,
            );

            // 4. Persistencia en Firebase exitosa
            await _reservaService.registrarReserva(nuevaReserva);

            _mostrarSnackBar(
                '¡Pago Completado! Tu destino se ha guardado en tus reservas.',
                const Color(0xFF009933));

            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              setState(() {
                _cargandoPago = false;
              });

              final String rutaActualLimpia =
                  "${html.window.location.origin}/#${html.window.location.pathname}";
              html.window.history.pushState({}, '', rutaActualLimpia);
            }
          }
        }
      } catch (e) {
        final String rutaLimpia =
            "${html.window.location.origin}/#${html.window.location.pathname}";
        html.window.history.pushState({}, '', rutaLimpia);
        if (mounted) setState(() => _cargandoPago = false);
      }
    }
  }

  Future<void> _iniciarPagoPayPal(double totalAmount) async {
    setState(() => _cargandoPago = true);

    // Guardamos la URL exacta con hash para que regrese a la vista de detalle
    final String currentUrl = html.window.location.href.split('?')[0];
    final String returnUrl = currentUrl;
    final String cancelUrl = "${html.window.location.origin}/#/";

    try {
      final authTokenResponse = await http.post(
        Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_secretKey'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (authTokenResponse.statusCode != 200) {
        throw Exception("Error de autenticación con PayPal");
      }

      final String accessToken =
          jsonDecode(authTokenResponse.body)['access_token'];

      final orderResponse = await http.post(
        Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "intent": "CAPTURE",
          "purchase_units": [
            {
              "amount": {
                "currency_code": "USD",
                "value": totalAmount.toStringAsFixed(2)
              },
              "description": "Compra de paquete turístico: ${widget.title}",
              "custom_id": widget.title
            }
          ],
          "application_context": {
            "return_url": returnUrl,
            "cancel_url": cancelUrl,
            "user_action": "PAY_NOW"
          }
        }),
      );

      if (orderResponse.statusCode != 201) {
        throw Exception("No se pudo crear la orden de pago");
      }

      final data = jsonDecode(orderResponse.body);

      String approveUrl = "";
      for (var link in data['links']) {
        if (link['rel'] == 'approve') {
          approveUrl = link['href'];
          break;
        }
      }

      if (approveUrl.isNotEmpty) {
        _mostrarSnackBar(
            'Redirigiendo a PayPal para completar el pago...', Colors.blue);
        await Future.delayed(const Duration(seconds: 1));
        html.window.location.href = approveUrl;
        return;
      }
    } catch (e) {
      _mostrarSnackBar('Ocurrió un error con PayPal: $e', Colors.redAccent);
      setState(() => _cargandoPago = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  //  Nueva funcion para abrir la ubicacion en Google Maps
  Future<void> _abrirEnGoogleMaps() async {
    // Une la ubicación actual con el país para mayor precisión
    final String busquedaCodificada = Uri.encodeComponent('${widget.location}, Venezuela');
    
    // URL universal de búsqueda en Google Maps
    final Uri urlMaps = Uri.parse('https://www.google.com/maps/search/?api=1&query=$busquedaCodificada');

    try {
      if (await canLaunchUrl(urlMaps)) {
        await launchUrl(urlMaps, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el mapa.';
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('Error: No se pudo abrir Google Maps.', Colors.red);
      }
    }
  }

  // AÑADIDO: Diálogo estético para advertir la suspensión
  void _mostrarAlertaSuspendido(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.gpp_bad_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Cuenta Suspendida', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tu cuenta de viajero se encuentra temporalmente suspendida por la administración. '
            'No puedes realizar compras de paquetes ni reservas en este momento.\n\n'
            'Si crees que se trata de un error, comunícate con soporte.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    double precioIndividual = double.tryParse(widget.price) ?? 280.0;
    double total = precioIndividual * _cantidadViajeros;
    bool esPantallaAncha = MediaQuery.of(context).size.width > 900;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resenas')
          .where('destinoId', isEqualTo: widget.title)
          .snapshots(),
      builder: (context, snapshot) {
        double promedioRating = 0.0;
        int cantidadResenas = 0;
        List<QueryDocumentSnapshot> resenasDocumentos = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          resenasDocumentos = snapshot.data!.docs;
          cantidadResenas = resenasDocumentos.length;

          double sumaCalificaciones = 0;
          for (var doc in resenasDocumentos) {
            var data = doc.data() as Map<String, dynamic>;
            sumaCalificaciones += (data['calificacion'] ?? 0).toDouble();
          }
          promedioRating = sumaCalificaciones / cantidadResenas;
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: const CustomHeader(),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (esPantallaAncha)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: _buildContenidoIzquierdo(promedioRating,
                                  cantidadResenas, resenasDocumentos)),
                          const SizedBox(width: 40),
                          Expanded(
                              flex: 1,
                              child:
                                  _buildCajaReserva(precioIndividual, total)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildContenidoIzquierdo(promedioRating,
                              cantidadResenas, resenasDocumentos),
                          const SizedBox(height: 24),
                          _buildCajaReserva(precioIndividual, total),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContenidoIzquierdo(double rating, int totalResenas,
      List<QueryDocumentSnapshot> docsResenas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 420,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: _buildImage(widget.imageUrl),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.title,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            Text(widget.location,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.calendar_today_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            const Text('3 días',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.people_outline, color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            const Text('Hasta 8 personas',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(totalResenas == 0 ? '0.0' : rating.toStringAsFixed(1),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(' ($totalResenas reseñas)',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 15),
            const Icon(Icons.check, color: Color(0xFF009933), size: 16),
            const SizedBox(width: 4),
            const Text('6 cupos disponibles',
                style: TextStyle(
                    color: Color(0xFF009933),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        const SizedBox(height: 30),
        _buildCuadroInformativo(
          titulo: 'Descripción',
          child: Text(
            widget.description,
            style: const TextStyle(
                fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 20),
        _buildCuadroInformativo(
          titulo: '¿Qué incluye?',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 6,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.includes.map((item) {
              return Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFF009933), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _buildCuadroInformativo(
          titulo: 'Ubicación',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.location,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Venezuela', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _abrirEnGoogleMaps,
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text('Ver en Google Maps',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009933),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCuadroInformativo(
          titulo: 'Reseñas ($totalResenas)',
          child: docsResenas.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Aún no hay reseñas para este paquete turístico.',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docsResenas.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 30),
                  itemBuilder: (context, index) {
                    var data =
                        docsResenas[index].data() as Map<String, dynamic>;
                    String usuarioNombre =
                        data['usuarioNombre'] ?? 'Viajero EcoRutas';
                    String comentario = data['comentario'] ?? '';
                    int calificacionEstrellas = data['calificacion'] ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      const Color(0xFF009933).withOpacity(0.1),
                                  child: Text(
                                    usuarioNombre.isNotEmpty
                                        ? usuarioNombre[0].toUpperCase()
                                        : 'V',
                                    style: const TextStyle(
                                        color: Color(0xFF009933),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  usuarioNombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < calificacionEstrellas
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 25,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 42.0),
                          child: Text(
                            comentario,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16, height: 1.4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildImage(String rutaImagen) {
    if (rutaImagen.isEmpty) {
      return const Center(
          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey));
    }

    if (rutaImagen.startsWith('base64,')) {
      try {
        return Image.memory(
          base64Decode(rutaImagen.substring(7)),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 420,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported,
                  size: 80, color: Colors.grey)),
        );
      } catch (e) {
        return const Center(
            child:
                Icon(Icons.image_not_supported, size: 80, color: Colors.grey));
      }
    } else {
      return Image.network(
        rutaImagen,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 420,
        errorBuilder: (context, error, stackTrace) => const Center(
            child:
                Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
      );
    }
  }

  Widget _buildCajaReserva(double precioIndividual, double total) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('\$$precioIndividual',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009933))),
                const SizedBox(width: 4),
                const Text('por persona',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const Divider(height: 30),
            const Text('Número de viajeros (máx. 6)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _cantidadViajeros > 1
                        ? () => setState(() => _cantidadViajeros--)
                        : null,
                  ),
                  Text('$_cantidadViajeros',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: _cantidadViajeros < 6
                        ? () => setState(() => _cantidadViajeros++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio por persona',
                    style: TextStyle(color: Colors.black87)),
                Text('\$$precioIndividual',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cantidad de personas',
                    style: TextStyle(color: Colors.black87)),
                Text('x $_cantidadViajeros',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('\$$total',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009933))),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                // CAMBIADO A ASYNC: Lógica de validación de suspensión integrada aquí
                onPressed: _cargandoPago
                    ? null
                    : () async {
                        final usuarioActual = FirebaseAuth.instance.currentUser;

                        if (usuarioActual == null) {
                          _mostrarSnackBar(
                              'Debes iniciar sesión para poder adquirir un paquete. :)',
                              Colors.orangeAccent);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                          return;
                        }

                        // Activamos el spinner visual preventivamente mientras consultamos Firestore
                        setState(() => _cargandoPago = true);

                        try {
                          // Consultamos de forma asíncrona el documento del usuario directo en Firestore
                          DocumentSnapshot userDoc = await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(usuarioActual.uid)
                              .get();

                          if (userDoc.exists) {
                            final data = userDoc.data() as Map<String, dynamic>?;
                            final bool estaActivo = data?['activo'] ?? true;

                            //  SI EL VIAJERO ESTÁ SUSPENDIDO: Detenemos todo, apagamos spinner y alertamos
                            if (!estaActivo) {
                              setState(() => _cargandoPago = false);
                              _mostrarAlertaSuspendido(context);
                              return; 
                            }
                          }
                        } catch (e) {
                          setState(() => _cargandoPago = false);
                          _mostrarSnackBar('Error al verificar el estado de tu cuenta: $e', Colors.redAccent);
                          return;
                        }

                        // Si pasó la prueba de fuego y está activo, procesa el pago normal
                        _iniciarPagoPayPal(total);
                      },
                child: _cargandoPago
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Comprar Paquete',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCuadroInformativo(
      {required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}