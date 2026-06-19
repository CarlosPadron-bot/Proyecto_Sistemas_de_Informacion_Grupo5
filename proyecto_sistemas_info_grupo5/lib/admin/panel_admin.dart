import 'package:flutter/material.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';
import 'package:proyecto_sistemas_info_grupo5/admin/gestion_usuarios_dashboard.dart'; 
import 'package:fl_chart/fl_chart.dart';

class PanelAdmin extends StatefulWidget {
  const PanelAdmin({super.key});

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: const CustomHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Administrativo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Gestión y análisis de la plataforma',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Barra de Pestañas
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    _buildTabItem('Dashboard', Icons.trending_up, 0),
                    const SizedBox(width: 20),
                    _buildTabItem('Usuarios', Icons.people_outline, 1),
                    const SizedBox(width: 20),
                    _buildTabItem('Paquetes', Icons.inventory_2_outlined, 2),
                    const SizedBox(width: 20),
                    _buildTabItem('Alojamientos', Icons.home_work_outlined, 3),
                    const SizedBox(width: 20),
                    _buildTabItem('Reservas', Icons.book_online_outlined, 4),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- AQUI SE LLAMAN LAS VISTAS SEGÚN LA PESTAÑA ---
              if (_selectedIndex == 0) _buildDashboardView(),
              
              //  Llamamos al nuevo widget que creamos para gestionar usuarios
              if (_selectedIndex == 1) const GestionUsuariosDashboard(), 
              
              if (_selectedIndex > 1) 
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text('Módulo en construcción...', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF00B14F) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(24.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. FILA DE LAS 4 TARJETA SUPERIORES (KPIs)
        LayoutBuilder(
          builder: (context, constraints) {
            double espaciado = 16.0;
            double anchoTarjeta = (constraints.maxWidth - (espaciado * 3)) / 4;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFigmaCard(
                  title: 'Paquetes Activos',
                  value: '5',
                  icon: Icons.widgets_outlined,
                  color: const Color(0xFF00B050), // Verde exacto Figma
                  width: anchoTarjeta,
                ),
                _buildFigmaCard(
                  title: 'Alojamientos',
                  value: '6',
                  icon: Icons.home_outlined,
                  color: const Color(0xFF2B78E4), // Azul exacto Figma
                  width: anchoTarjeta,
                ),
                _buildFigmaCard(
                  title: 'Usuarios Activos',
                  value: '6',
                  icon: Icons.person_outline,
                  color: const Color(0xFF9837F5), // Morado exacto Figma
                  width: anchoTarjeta,
                ),
                _buildFigmaCard(
                  title: 'Ingresos Totales',
                  value: '\$400',
                  icon: Icons.attach_money,
                  color: const Color(0xFFDCA10D), // Oro/Amarillo exacto Figma
                  width: anchoTarjeta,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // 2. FILA DE TARJETAS DE ACCIÓN CENTRALES (50% de ancho cada una)
        LayoutBuilder(
          builder: (context, constraints) {
            double espaciado = 16.0;
            double anchoTarjetaMedio = (constraints.maxWidth - espaciado) / 2;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFigmaActionCard(
                  title: 'Gestionar Usuarios',
                  subtitle: 'Ver, suspender o eliminar cuentas',
                  value: '6',
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF5351FB), // Azul violeta exacto Figma
                  width: anchoTarjetaMedio,
                ),
                _buildFigmaActionCard(
                  title: 'Transacciones del Mes',
                  subtitle: 'Reservas pagadas en abril 2026',
                  value: '2',
                  icon: Icons.trending_up,
                  color: const Color(0xFF00A699), // Turquesa exacto Figma
                  width: anchoTarjetaMedio,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // 3. SECCIÓN DE GRÁFICOS INFERIORES (Distribución en dos columnas)
        LayoutBuilder(
          builder: (context, constraints) {
            double espaciado = 20.0;
            double anchoColumna = (constraints.maxWidth - espaciado) / 2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // COLUMNA IZQUIERDA: Rango de precios y Estado de Reservas
                SizedBox(
                  width: anchoColumna,
                  child: Column(
                    children: [
                      _buildDestinosPrecioCard(),
                      const SizedBox(height: 20),
                      _buildEstadoReservasCard(),
                    ],
                  ),
                ),
                
                // COLUMNA DERECHA: Distribución por Estado e Ingresos Mensuales
                SizedBox(
                  width: anchoColumna,
                  child: Column(
                    children: [
                      _buildDistribucionEstadoCard(),
                      const SizedBox(height: 20),
                      _buildIngresosMensualesCard(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// --- REPLICACIÓN: TARJETAS SUPERIORES PEQUEÑAS ---
Widget _buildFigmaCard({required String title, required String value, required IconData icon, required Color color, required double width}) {
  return Container(
    width: width,
    height: 95,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// --- REPLICACIÓN: TARJETAS MEDIAS DE ACCIÓN ---
Widget _buildFigmaActionCard({required String title, required String subtitle, required String value, required IconData icon, required Color color, required double width}) {
  return Container(
    width: width,
    height: 115,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// --- GRÁFICO 1: DESTINOS POR RANGO DE PRECIO (BARRAS) ---
Widget _buildDestinosPrecioCard() {
  return _buildBaseGraficoCard(
    title: 'Destinos por Rango de Precio',
    child: SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 2, color: const Color(0xFF2B78E4), width: 22, borderRadius: BorderRadius.circular(2))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 0, color: const Color(0xFF2B78E4), width: 22)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: const Color(0xFF2B78E4), width: 22, borderRadius: BorderRadius.circular(2))]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 0, color: const Color(0xFF2B78E4), width: 22)]),
          ],
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
          borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade400), left: BorderSide(color: Colors.grey.shade400))),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 22)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              const labels = ['\$0-\$50', '\$51-\$100', '\$101-\$200', '\$201+'];
              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)));
            })),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
        ),
      ),
    ),
  );
}

// --- GRÁFICO 2: DISTRIBUCIÓN POR ESTADO (PIE CHART) ---
Widget _buildDistribucionEstadoCard() {
  return _buildBaseGraficoCard(
    title: 'Distribución por Estado',
    child: SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 0,
          sections: [
            PieChartSectionData(color: const Color(0xFF2B78E4), value: 25, title: 'Bolívar', radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Color(0xFF2B78E4)), badgeWidget: const Text('Bolívar', style: TextStyle(fontSize: 9, color: Colors.blue))),
            PieChartSectionData(color: const Color(0xFF00B050), value: 20, title: 'Dep. Federales', radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Color(0xFF00B050))),
            PieChartSectionData(color: const Color(0xFF9837F5), value: 15, title: 'Sucre', radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Color(0xFF9837F5))),
            PieChartSectionData(color: const Color(0xFFF14336), value: 20, title: 'Falcón', radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Color(0xFFF14336))),
            PieChartSectionData(color: const Color(0xFFF1A100), value: 20, title: 'Mérida', radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Color(0xFFF1A100))),
          ],
        ),
      ),
    ),
  );
}

// --- GRÁFICO 3: INGRESOS MENSUALES (LÍNEAS) ---
Widget _buildIngresosMensualesCard() {
  return _buildBaseGraficoCard(
    title: 'Ingresos Mensuales',
    child: SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1000,
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100)),
          borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade400), left: BorderSide(color: Colors.grey.shade400))),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 250, reservedSize: 28)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              const labels = ['Ene', 'Feb', 'Mar', 'Abr'];
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                return Text(labels[value.toInt()], style: const TextStyle(fontSize: 11, color: Colors.grey));
              }
              return const Text('');
            })),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 420), FlSpot(1, 700), FlSpot(2, 950), FlSpot(3, 400)],
              isCurved: true,
              color: const Color(0xFF00A699),
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    ),
  );
}

// --- SECCIÓN 4: ESTADO DE RESERVAS ---
Widget _buildEstadoReservasCard() {
  return _buildBaseGraficoCard(
    title: 'Estado de Reservas',
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMiniStatusBox('Solicitadas', '0', const Color(0xFF2B78E4))),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniStatusBox('Aceptadas', '1', const Color(0xFFDCA10D))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMiniStatusBox('Pagadas', '1', const Color(0xFF00B050))),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniStatusBox('Completadas', '1', const Color(0xFF9837F5))),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMiniStatusBox(String label, String value, Color color) {
  return Container(
    height: 65,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(width: 3, height: double.infinity, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBaseGraficoCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}