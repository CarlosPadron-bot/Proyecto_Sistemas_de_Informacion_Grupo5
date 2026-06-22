import 'package:flutter/material.dart';

// =========================================================================
// 📊 GRÁFICO 1: DESTINOS POR RANGO DE PRECIO (BARRAS ESTILIZADAS)
// =========================================================================
Widget graficoRangoPrecios({required int economico, required int moderado, required int premium}) {
  int maxValor = [economico, moderado, premium, 1].reduce((curr, next) => curr > next ? curr : next);
  
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(22),
      height: 280, // 💡 Incrementado de 260 a 280 para dar más espacio vertical
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Destinos por Rango de Precio', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const Text(
            'Segmentación basada en costos de paquetes', 
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            height: 160, // 💡 Ajustado para albergar cómodamente las barras y etiquetas
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _barraVertical('Económico\n(<\$100)', economico, maxValor, const Color(0xFF2E7D32)),
                _barraVertical('Moderado\n(\$100-\$300)', moderado, maxValor, const Color(0xFFEF6C00)),
                _barraVertical('Premium\n(>\$300)', premium, maxValor, const Color(0xFFC62828)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _barraVertical(String etiqueta, int valor, int maxValor, Color color) {
  double porcentajeAltura = valor / maxValor;
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        '$valor', 
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
      ),
      const SizedBox(height: 6),
      Container(
        width: 32,
        height: (90 * porcentajeAltura).clamp(8.0, 90.0), // 💡 Reducido levemente el máximo para evitar empujar el texto
        decoration: BoxDecoration(
          color: color, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color, color.withOpacity(0.8)],
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        etiqueta, 
        textAlign: TextAlign.center, 
        style: const TextStyle(fontSize: 10.5, color: Colors.black54, height: 1.1), // 💡 Fuente optimizada a 10.5
      ),
    ],
  );
}

// =========================================================================
// 🍩 GRÁFICO 2: DISTRIBUCIÓN POR ESTADO (DONA MODERNA CON SCROLL DE LEYENDAS)
// =========================================================================
Widget graficoDistribucionEstados({required Map<String, int> datosEstados}) {
  final List<Color> paletaColores = [
    const Color(0xFF1565C0), const Color(0xFF6A1B9A), const Color(0xFFAD1457),
    const Color(0xFF00838F), const Color(0xFF2E7D32), const Color(0xFFEF6C00),
    const Color(0xFF4527A0), const Color(0xFFD84315), const Color(0xFF37474F)
  ];

  int totalItems = datosEstados.values.fold(0, (sum, val) => sum + val);

  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(22),
      height: 280, // 💡 Homologado a 280 para mantener simetría perfecta con las barras
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por Estado', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: datosEstados.isEmpty
                ? const Center(child: Text('Sin datos geográficos', style: TextStyle(color: Colors.grey)))
                : Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 16,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$totalItems', 
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const Text(
                                  'Destinos', 
                                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 6,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: datosEstados.length,
                            itemBuilder: (context, index) {
                              String estado = datosEstados.keys.elementAt(index);
                              int cantidad = datosEstados.values.elementAt(index);
                              Color colorAsignado = paletaColores[index % paletaColores.length];
                              double porcentaje = totalItems > 0 ? (cantidad / totalItems) * 100 : 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10, 
                                      height: 10, 
                                      decoration: BoxDecoration(color: colorAsignado, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        estado, 
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${porcentaje.toStringAsFixed(0)}%', 
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

// =========================================================================
// 🟢 GRÁFICO 3: ESTADO DE RESERVAS (ANILLO SEGMENTADO Y COMPACTO)
// =========================================================================
Widget graficoEstadoReservas({required int confirmadas, required int pendientes, required int canceladas}) {
  int total = confirmadas + pendientes + canceladas;
  
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(22),
      height: 280, // 💡 Homologado a 280
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de Reservas', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: total > 0 ? (confirmadas / total) : 0.0,
                        strokeWidth: 18,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)), 
                      ),
                    ),
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: CircularProgressIndicator(
                        value: total > 0 ? (pendientes / total) : 0.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBC02D)), 
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _indicadorFila(const Color(0xFF2E7D32), 'Confirmadas', confirmadas),
                    _indicadorFila(const Color(0xFFFBC02D), 'Pendientes', pendientes),
                    _indicadorFila(const Color(0xFFD32F2F), 'Canceladas', canceladas),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _indicadorFila(Color color, String leyenda, int valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            leyenda, 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.64)),
          ),
        ),
        Text(
          '$valor', 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    ),
  );
}

// =========================================================================
// 📈 GRÁFICO 4: EVOLUCIÓN DE INGRESOS MENSUALES (LÍNEAS LIGERAS)
// =========================================================================
Widget graficoIngresosMensuales({required double ingresos}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    height: 280, // 💡 Homologado a 280
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03), 
          blurRadius: 10, 
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresos Mensuales', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
        const Text(
          'Historial de flujo de caja acumulado', 
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Spacer(),
        SizedBox(
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('\$0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '\$${ingresos.toStringAsFixed(2)}', 
                      style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('Ene', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                  Text('Mar', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                  Text('May', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                  Text('Jun', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ],
    ),
  );
}