import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/admin_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_usuarios_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_resenas_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_paquetes_dashboard.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_alojamientos_dashboard.dart';

// Nota: Si no tienes creados estos archivos, puedes comentarlos provisionalmente
// e intercambiarlos por contenedores vacíos en la lista de pantallas.
// import 'package:proyecto_sistemas_info_grupo5/admin/gestion_destinos.dart'; 
// import 'package:proyecto_sistemas_info_grupo5/admin/gestion_comentarios.dart';
// import 'package:proyecto_sistemas_info_grupo5/admin/reportes_analiticas.dart';

class PanelAdmin extends StatefulWidget {
  const PanelAdmin({super.key});

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el TabController para manejar las 5 pestañas de tu captura ideal
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris claro de tu diseño
      appBar: const CustomHeader(), // Encabezado verde de RutasVzla
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Título del Panel
          Padding(
            padding: const EdgeInsets.only(left: 50.0, top: 30.0, right: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel Administrativo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión y análisis de la plataforma',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 25),
                
                // =========================================================
                // 📊 PESTAÑAS HORIZONTALES (IDÉNTICAS A TU CAPTURA 347)
                // =========================================================
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFF009933), // Línea verde inferior activa
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF009933),
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Dashboard'),
                    Tab(icon: Icon(Icons.people_alt_outlined, size: 18), text: 'Usuarios'),
                    Tab(icon: Icon(Icons.card_travel_outlined, size: 18), text: 'Paquetes'),
                    Tab(icon: Icon(Icons.apartment_outlined, size: 18), text: 'Alojamientos'),
                    Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Reseñas'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Cuerpo dinámico donde se cargan los dashboards independientes
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const AdminDashboard(),           // Índice 0: Gráficos principales
                const GestionUsuariosDashboard(),  // Índice 1: Tabla de usuarios
                const GestionPaquetesDashboard(),
                const GestionAlojamientosDashboard(),
                const GestionResenasDashboard(),     // Índice 4: Tabla de reseñas reales
              ],
            ),
          ),
        ],
      ),
    );
  }
}