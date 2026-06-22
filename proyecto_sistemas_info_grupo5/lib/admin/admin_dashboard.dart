import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importamos el archivo de componentes de gráficos que creamos en el Paso 1
import 'componentes_graficos.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('destinos').snapshots(),
        builder: (context, snapshotDestinos) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('reservas').snapshots(),
            builder: (context, snapshotReservas) {
              
              if (snapshotDestinos.connectionState == ConnectionState.waiting ||
                  snapshotReservas.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF009933)));
              }

              var docsDestinos = snapshotDestinos.hasData ? snapshotDestinos.data!.docs : [];
              var docsReservas = snapshotReservas.hasData ? snapshotReservas.data!.docs : [];

              // 1. Cálculo de Paquetes y Alojamientos
              int totalPaquetes = docsDestinos.where((doc) {
                final d = doc.data() as Map<String, dynamic>?;
                return d == null || d['tipo'] != 'alojamiento';
              }).length;

              int totalAlojamientos = docsDestinos.where((doc) {
                final d = doc.data() as Map<String, dynamic>?;
                return d != null && d['tipo'] == 'alojamiento';
              }).length;

              // 2. Cálculo de Ingresos Totales (sumando el campo 'precio')
              double ingresosTotales = 0.0;
              for (var doc in docsReservas) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('precio')) {
                  ingresosTotales += double.tryParse(data['precio'].toString()) ?? 0.0;
                }
              }

              // =========================================================================
              // 📊 CÁLCULO DE MÉTRICAS PARA LOS GRÁFICOS
              // =========================================================================
              
              // Rango de Precios
              int economico = 0;
              int moderado = 0;
              int premium = 0;
              for (var doc in docsDestinos) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('precio')) {
                  double p = double.tryParse(data['precio'].toString()) ?? 0.0;
                  if (p < 100) economico++;
                  else if (p <= 300) moderado++;
                  else premium++;
                }
              }

              // Distribución por Estado
              Map<String, int> conteoEstados = {};
              for (var doc in docsDestinos) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null) {
                  String estado = data['ubicacion']?.toString() ?? data['estado']?.toString() ?? 'Otros';
                  conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
                }
              }

              // Estados de las Reservas
              int confirmadas = 0;
              int pendientes = 0;
              int canceladas = 0;
              for (var doc in docsReservas) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('estado')) {
                  String est = data['estado'].toString().toLowerCase();
                  if (est.contains('confir') || est.contains('paga')) confirmadas++;
                  else if (est.contains('pendi')) pendientes++;
                  else canceladas++;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Panel Administrativo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Gestión y análisis de la plataforma en tiempo real', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 30),

                    // Tarjetas Métricas Superiores
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double anchoTarjeta = (constraints.maxWidth - 60) / 4;
                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _construirTarjetaMetrica('Paquetes Activos', '$totalPaquetes', const Color(0xFF009933), Icons.grid_view_rounded, anchoTarjeta),
                            _construirTarjetaMetrica('Alojamientos', '$totalAlojamientos', const Color(0xFF1976D2), Icons.apartment_rounded, anchoTarjeta),
                            
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore.collection('usuarios').snapshots(),
                              builder: (context, snapUsers) {
                                int totalUsers = snapUsers.hasData ? snapUsers.data!.docs.length : 0;
                                return _construirTarjetaMetrica('Usuarios Activos', '$totalUsers', const Color(0xFF7B1FA2), Icons.person_outline_rounded, anchoTarjeta);
                              },
                            ),
                            
                            _construirTarjetaMetrica('Ingresos Totales', '\$${ingresosTotales.toStringAsFixed(0)}', const Color(0xFFC67C00), Icons.attach_money_rounded, anchoTarjeta),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // =========================================================================
                    // 📈 AQUÍ SE DIBUJAN NUEVAMENTE LOS GRÁFICOS EN FILA (YA CONECTADOS)
                    // =========================================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        graficoRangoPrecios(economico: economico, moderado: moderado, premium: premium),
                        const SizedBox(width: 20),
                        graficoDistribucionEstados(datosEstados: conteoEstados),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        graficoEstadoReservas(confirmadas: confirmadas, pendientes: pendientes, canceladas: canceladas),
                        const SizedBox(width: 20),
                        Expanded(child: graficoIngresosMensuales(ingresos: ingresosTotales)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _construirTarjetaMetrica(String titulo, String valor, Color color, IconData icono, double ancho) {
    return Container(
      width: ancho < 220 ? 220 : ancho,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icono, color: Colors.white70, size: 28),
              Text(valor, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Text(titulo, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}