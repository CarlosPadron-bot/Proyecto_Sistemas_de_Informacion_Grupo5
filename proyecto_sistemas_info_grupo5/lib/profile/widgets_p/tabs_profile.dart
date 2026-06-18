import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/resena_service.dart';
import 'package:proyecto_sistemas_info_grupo5/Servicios/reserva_service.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/resena_model.dart';
import 'package:proyecto_sistemas_info_grupo5/modelos/reserva_model.dart';
import 'emptystate.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({Key? key}) : super(key: key);

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  int _activeTabIndex = 0;
  final ReservaService _reservaService = ReservaService();
  final ResenaService _resenaService = ResenaService();

  Widget _buildImagenDestino(String ruta, {double? width, double? height}) {
    if (ruta.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey);
    }

    if (ruta.contains('base64')) {
      try {
        final String cadenaLimpia =
            ruta.contains(',') ? ruta.split(',')[1] : ruta;
        return Image.memory(
          base64Decode(cadenaLimpia.trim()),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );
      } catch (e) {
        return const Icon(Icons.broken_image_outlined, color: Colors.red);
      }
    }

    if (ruta.startsWith('http://') || ruta.startsWith('https://')) {
      return Image.network(
        ruta,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    } else {
      final rutaCompleta = ruta.startsWith('assets/') ? ruta : 'assets/$ruta';
      return Image.asset(
        rutaCompleta,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botones de Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: _buildToggleButton(
                    0, 'Mis Reservas', Icons.calendar_month)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildToggleButton(
                    1, 'Mis Reseñas', Icons.star_border_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _buildToggleButton(2, 'Historial', Icons.history)),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: () {
            if (_activeTabIndex == 0) return _buildReservasTab();
            if (_activeTabIndex == 1) return _buildResenasTab();
            if (_activeTabIndex == 2) return _buildHistorialTab();
            return const SizedBox.shrink();
          }(),
        ),
      ],
    );
  }

  Widget _buildToggleButton(int index, String label, IconData icon) {
    bool isActive = _activeTabIndex == index;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF009933) : Colors.grey[100],
        foregroundColor: isActive ? Colors.white : Colors.black87,
        elevation: isActive ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _activeTabIndex = index),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _mostrarPopUpResena(
      BuildContext context, Reserva reserva, StateSetter parentSetState) {
    int calificacionSeleccionada = 0;
    String? errorEstrellas;
    final TextEditingController comentarioController = TextEditingController();
    final _formKeyResena = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKeyResena,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Escribir Reseña',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¿Qué te pareció tu experiencia en ${reserva.destinoNombre}?',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        int valorEstrella = index + 1;
                        return IconButton(
                          icon: Icon(
                            calificacionSeleccionada >= valorEstrella
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFCC00),
                            size: 36,
                          ),
                          onPressed: () {
                            setModalState(() {
                              calificacionSeleccionada = valorEstrella;
                              errorEstrellas = null;
                            });
                          },
                        );
                      }),
                    ),
                    if (errorEstrellas != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          errorEstrellas!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: comentarioController,
                      maxLines: 5,
                      maxLength: 350,
                      decoration: InputDecoration(
                        hintText:
                            'Cuéntanos los detalles de tu viaje... (Límite 350 palabras)',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF009933)),
                        ),
                        counterText: "",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor escribe un comentario.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: comentarioController,
                      builder: (context, value, child) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: Text(
                            '${value.text.length} / 350 palabras',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009933),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final formValido =
                            _formKeyResena.currentState!.validate();

                        if (calificacionSeleccionada == 0) {
                          setModalState(() {
                            errorEstrellas =
                                'Por favor selecciona una calificación en estrellas.';
                          });
                          return;
                        }

                        if (!formValido) return;

                        try {
                          final user = FirebaseAuth.instance.currentUser!;
                          String nombreRealUsuario = 'Viajero';
                          try {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(user.uid)
                                .get();

                            if (userDoc.exists && userDoc.data() != null) {
                              final data = userDoc.data()!;
                              nombreRealUsuario = data['nombre'] ??
                                  data['username'] ??
                                  data['displayName'] ??
                                  'Viajero';
                            } else {
                              nombreRealUsuario = user.displayName ?? 'Viajero';
                            }
                          } catch (e) {
                            nombreRealUsuario = user.displayName ?? 'Viajero';
                          }

                          final nuevaResena = Resena(
                            usuarioId: user.uid,
                            usuarioNombre: nombreRealUsuario,
                            destinoId: reserva.destinoId,
                            destinoNombre: reserva.destinoNombre,
                            urlImagenDestino: reserva.urlImagen,
                            calificacion: calificacionSeleccionada,
                            comentario: comentarioController.text.trim(),
                            fechaResena: DateTime.now(),
                          );

                          await _resenaService.publicarResena(nuevaResena);
                          await _reservaService
                              .marcarReservaComoCompleta(reserva.id);

                          Navigator.pop(context);
                          parentSetState(() {
                            _activeTabIndex = 1;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '¡Reseña publicada con éxito! Ya puedes verla en la sección de reseñas.'),
                              backgroundColor: Color(0xFF009933),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al publicar reseña: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('PUBLICAR RESEÑA',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildReservasTab() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child:
            Center(child: Text('Debes iniciar sesión para ver tus reservas.')),
      );
    }

    return StreamBuilder<List<Reserva>>(
      stream: _reservaService.obtenerReservasPorUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFF009933))),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('Hubo un error al cargar tus reservas.')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            title: "No tienes reservas",
            subtitle: "Explora nuestros destinos y comienza tu aventura",
            icon: Icons.calendar_month,
          );
        }

        final listaReservas = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: listaReservas.length,
          itemBuilder: (context, index) {
            final reserva = listaReservas[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: _buildImagenDestino(reserva.urlImagen,
                                width: 100, height: 100),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reserva.destinoNombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: ${reserva.fechaCompra.day}/${reserva.fechaCompra.month}/${reserva.fechaCompra.year}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${reserva.precioTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: InkWell(
                      onTap: () =>
                          _mostrarPopUpResena(context, reserva, setState),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: const Color(0xFFFFCC00),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review,
                                color: Colors.black87, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Escribir Reseña',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResenasTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const EmptyState(
          title: "Inicia sesión",
          subtitle: "Para ver tus reseñas",
          icon: Icons.lock_outline);
    }

    return StreamBuilder<List<Resena>>(
      stream: _resenaService.obtenerResenasPorUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF009933))));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            title: "No tienes reseñas",
            subtitle:
                "Aquí se mostrarán las opiniones que compartas sobre tus viajes",
            icon: Icons.star_border_rounded,
          );
        }

        final listaResenas = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: listaResenas.length,
          itemBuilder: (context, index) {
            final resena = listaResenas[index];
            return _buildCardResenaEstilizada(resena);
          },
        );
      },
    );
  }

  Widget _buildHistorialTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const EmptyState(
          title: "Inicia sesión",
          subtitle: "Para ver tu historial",
          icon: Icons.lock_outline);
    }

    return StreamBuilder<List<Reserva>>(
      stream: _reservaService.obtenerHistorialPorUsuario(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF009933))));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            title: "No has visitado ningún destino",
            subtitle:
                "Aquí se mostrarán los destinos que hayas visitado y reseñado",
            icon: Icons.history,
          );
        }

        final listaHistorial = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: listaHistorial.length,
          itemBuilder: (context, index) {
            final reservaCompleta = listaHistorial[index];
            return _buildCardHistorialEstilizada(reservaCompleta);
          },
        );
      },
    );
  }

  Widget _buildCardResenaEstilizada(Resena resena) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[100]!)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[100],
                      child: _buildImagenDestino(resena.urlImagenDestino,
                          width: 100, height: 100)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resena.destinoNombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < resena.calificacion
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFCC00),
                            size: 25,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(resena.comentario,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHistorialEstilizada(Reserva reserva) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey[100],
                  // 🛠️ ACTUALIZADO: Soportando Base64 dinámicamente
                  child: _buildImagenDestino(reserva.urlImagen,
                      width: 110, height: 110)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva.destinoNombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visitado: ${reserva.fechaCompra.day}/${reserva.fechaCompra.month}/${reserva.fechaCompra.year}',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF009933),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('COMPLETADO',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
