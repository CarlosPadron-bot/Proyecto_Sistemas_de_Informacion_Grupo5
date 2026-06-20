import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraficoPrecios extends StatelessWidget {
  const GraficoPrecios({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destinos por Rango de Precio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                int economicos = 0; // $0 - $50
                int medios = 0;     // $51 - $100
                int premium = 0;    // $101+

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  int precio = data['precio'] ?? 0;
                  if (precio <= 50) {
                    economicos++;
                  } else if (precio <= 100) {
                    medios++;
                  } else {
                    premium++;
                  }
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (economicos > medios ? (economicos > premium ? economicos : premium) : (medios > premium ? medios : premium)).toDouble() + 2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0: return const Text('\$0-\$50', style: TextStyle(fontSize: 10));
                              case 1: return const Text('\$51-\$100', style: TextStyle(fontSize: 10));
                              case 2: return const Text('\$101+', style: TextStyle(fontSize: 10));
                              default: return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: economicos.toDouble(), color: Colors.blue, width: 16, borderRadius: BorderRadius.circular(4))]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: medios.toDouble(), color: Colors.blueAccent, width: 16, borderRadius: BorderRadius.circular(4))]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: premium.toDouble(), color: Colors.indigo, width: 16, borderRadius: BorderRadius.circular(4))]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GraficoEstados extends StatelessWidget {
  const GraficoEstados({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución por Estado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('destinos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                Map<String, int> conteoEstados = {};
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String estado = data['estado'] ?? 'Otros';
                  conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
                }

                List<Color> colores = [Colors.orange, Colors.deepOrange, Colors.amber, Colors.redAccent, Colors.yellow];
                int colorIndex = 0;

                List<PieChartSectionData> sections = conteoEstados.entries.map((entry) {
                  final section = PieChartSectionData(
                    color: colores[colorIndex % colores.length],
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n(${entry.value})',
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                  colorIndex++;
                  return section;
                }).toList();

                if (sections.isEmpty) return const Center(child: Text("No hay datos"));

                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sections,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GraficoIngresos extends StatelessWidget {
  const GraficoIngresos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos Mensuales (\$)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reservas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<FlSpot> puntosDeIngreso = const [
                  FlSpot(0, 300),
                  FlSpot(1, 550),
                  FlSpot(2, 420),
                  FlSpot(3, 800),
                ];

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0: return const Text('Mar', style: TextStyle(fontSize: 10));
                              case 1: return const Text('Abr', style: TextStyle(fontSize: 10));
                              case 2: return const Text('May', style: TextStyle(fontSize: 10));
                              case 3: return const Text('Jun', style: TextStyle(fontSize: 10));
                              default: return const Text('');
                            }
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: puntosDeIngreso,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}