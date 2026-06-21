import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraficoPrecios extends StatelessWidget {
  const GraficoPrecios({super.key});

  @override
  Widget build(BuildContext context) {
    final String operadorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
              stream: FirebaseFirestore.instance
                  .collection('destinos')
                  .where('operadorId', isEqualTo: operadorUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                int economicos = 0; // $0 - $50
                int medios = 0; // $51 - $100
                int premium = 0; // $101+

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  double precio = (data['precio'] ?? 0.0).toDouble();

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
                    maxY: (economicos > medios
                                ? (economicos > premium ? economicos : premium)
                                : (medios > premium ? medios : premium))
                            .toDouble() +
                        2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('\$0-\$50',
                                    style: TextStyle(fontSize: 10));
                              case 1:
                                return const Text('\$51-\$100',
                                    style: TextStyle(fontSize: 10));
                              case 2:
                                return const Text('\$101+',
                                    style: TextStyle(fontSize: 10));
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: economicos.toDouble(),
                            color: Colors.blue,
                            width: 16,
                            borderRadius: BorderRadius.circular(4))
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: medios.toDouble(),
                            color: Colors.blueAccent,
                            width: 16,
                            borderRadius: BorderRadius.circular(4))
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: premium.toDouble(),
                            color: Colors.indigo,
                            width: 16,
                            borderRadius: BorderRadius.circular(4))
                      ]),
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
    final String operadorUid = FirebaseAuth.instance.currentUser?.uid ?? '';

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
          const Text('Tus Destinos por Estado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('destinos')
                  .where('operadorId', isEqualTo: operadorUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aún no tienes destinos"));
                }

                Map<String, int> conteoEstados = {};
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String estado = data['estado'] ?? 'Otros';
                  conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
                }

                List<Color> colores = [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.red
                ];
                int index = 0;

                List<PieChartSectionData> sections =
                    conteoEstados.entries.map((entry) {
                  final section = PieChartSectionData(
                    color: colores[index % colores.length],
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n${entry.value}',
                    radius: 50,
                    titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                  index++;
                  return section;
                }).toList();

                return PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
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
    final String operadorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
          const Text('Tus Ingresos Mensuales (\$)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 2. Filtramos reservas por el operadorId
              stream: FirebaseFirestore.instance
                  .collection('reservas')
                  .where('operadorId', isEqualTo: operadorUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map<int, double> ingresosPorMes = {0: 0, 1: 0, 2: 0, 3: 0};
                DateTime ahora = DateTime.now();

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  double precio =
                      (data['precioTotal'] ?? data['precio'] ?? 0.0).toDouble();

                  DateTime? fechaReserva;

                  if (data['fechaCompra'] is Timestamp) {
                    fechaReserva = (data['fechaCompra'] as Timestamp).toDate();
                  } else if (data['fechaCompra'] is String) {
                    // Intenta convertir el string a DateTime
                    fechaReserva =
                        DateTime.tryParse(data['fechaCompra'] as String);
                  }

                  if (fechaReserva != null) {
                    DateTime ahora = DateTime.now();
                    int diferenciaMeses =
                        (ahora.year - fechaReserva.year) * 12 +
                            (ahora.month - fechaReserva.month);

                    if (diferenciaMeses >= 0 && diferenciaMeses < 4) {
                      int indice = 3 - diferenciaMeses;
                      ingresosPorMes[indice] =
                          (ingresosPorMes[indice] ?? 0) + precio;
                    }
                  }
                }

                List<FlSpot> puntosDeIngreso = ingresosPorMes.entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList();

                return LineChart(
                  LineChartData(
                    gridData:
                        const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            // Etiquetas dinámicas para los meses
                            List<String> meses = [
                              'Mar',
                              'Abr',
                              'May',
                              'Jun'
                            ]; // Ajustar según necesidad
                            return Text(meses[value.toInt()],
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: puntosDeIngreso,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                            show: true, color: Colors.green.withOpacity(0.2)),
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

BarChartGroupData _makeGroupData(int x, double y, Color color) {
  return BarChartGroupData(x: x, barRods: [
    BarChartRodData(
      toY: y,
      color: color,
      width: 20,
      borderRadius: BorderRadius.circular(4),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 5, // Ajusta según el promedio esperado
        color: Colors.grey.shade100,
      ),
    ),
  ]);
}
