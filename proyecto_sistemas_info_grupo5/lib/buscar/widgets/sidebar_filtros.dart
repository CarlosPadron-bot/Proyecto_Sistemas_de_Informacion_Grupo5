import 'package:flutter/material.dart';

class SidebarFiltros extends StatefulWidget {
  final String tipoBusquedaActual;
  final Function(String) onTipoBusquedaChanged;
  final double presupuestoMaxActual;
  final Function(double) onPresupuestoMaxChanged;
  final String estadoActual;
  final Function(String) onEstadoChanged;
  final double calificacionMinActual;
  final Function(double) onCalificacionMinChanged;

  const SidebarFiltros({
    super.key,
    required this.tipoBusquedaActual,
    required this.onTipoBusquedaChanged,
    required this.presupuestoMaxActual,
    required this.onPresupuestoMaxChanged,
    required this.estadoActual,
    required this.onEstadoChanged,
    required this.calificacionMinActual,
    required this.onCalificacionMinChanged,
  });

  @override
  State<SidebarFiltros> createState() => _SidebarFiltrosState();
}

class _SidebarFiltrosState extends State<SidebarFiltros> {
  // ================= OTROS ESTADOS DE LOS FILTROS =================
  String estadoPais = 'Todos';
  double calificacionMin = 1.5;
  bool soloTransportePublico = false;

  final List<String> estadosVenezuela = [
    'Todos',
    'Mérida',
    'Caracas',
    'Falcón',
    'Sucre',
    'Bolívar'
  ];

  // ================= ESTADO DE LA CALCULADORA =================
  int numeroPersonas = 10;
  int diasViaje = 14;
  double costoAlojamiento = 100.0;
  double costoComida = 50.0;
  double costoTransporte = 200.0;
  double costoActividades = 100.0;

  double get costoPorPersona {
    return (costoAlojamiento * diasViaje) +
        (costoComida * diasViaje) +
        costoTransporte +
        costoActividades;
  }

  double get costoTotal => costoPorPersona * numeroPersonas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltrosSection(),
            const Divider(height: 40, thickness: 1, color: Colors.black12),
            _buildCalculadoraSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.filter_alt_outlined, color: Colors.green),
            SizedBox(width: 8),
            Text('Filtros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Tipo de Búsqueda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        _buildTipoBusquedaButton('Todo'),
        _buildTipoBusquedaButton('Paquetes Turisticos'),
        _buildTipoBusquedaButton('Alojamientos'),
        const SizedBox(height: 20),

        Text('Presupuesto Máximo: \$${widget.presupuestoMaxActual.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Slider(
          value: widget.presupuestoMaxActual,
          min: 10,
          max: 1000,
          activeColor: Colors.green,
          onChanged: (value) {
            widget.onPresupuestoMaxChanged(value);
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$10', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('\$1000', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 20),

        // Estado del País
        const Text('Estado del País',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.estadoActual,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              items: estadosVenezuela.map((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onEstadoChanged(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
            'Calificación Mínima: ${widget.calificacionMinActual.toStringAsFixed(1)} ★',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Slider(
          value: widget.calificacionMinActual,
          min: 1.0,
          max: 5.0,
          divisions: 40,
          activeColor: Colors.green,
          inactiveColor: Colors.grey.shade300,
          onChanged: (value) => widget.onCalificacionMinChanged(value),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Todas', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('5 ★', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: soloTransportePublico,
                activeColor: Colors.green,
                onChanged: (value) =>
                    setState(() => soloTransportePublico = value ?? false),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Solo con transporte público',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              widget.onTipoBusquedaChanged('Todo');
              widget.onPresupuestoMaxChanged(500.0);
              widget.onEstadoChanged('Todos');
              widget.onCalificacionMinChanged(4.0);
              setState(() {
                soloTransportePublico = false;
              });
            },
            child: const Text('Limpiar Filtros',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoBusquedaButton(String titulo) {
    bool isSelected = widget.tipoBusquedaActual == titulo;
    return GestureDetector(
      onTap: () => widget.onTipoBusquedaChanged(titulo),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCalculadoraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.calculate_outlined,
                  color: Colors.green, size: 20),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calculadora de\nPresupuesto',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                  Text('Planifica tu viaje',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSliderConIcono(
            Icons.people_outline,
            'Número de personas: $numeroPersonas',
            numeroPersonas.toDouble(),
            1,
            30,
            (v) => setState(() => numeroPersonas = v.toInt())),
        _buildSliderConIcono(
            Icons.calendar_today_outlined,
            'Días de viaje: $diasViaje',
            diasViaje.toDouble(),
            1,
            30,
            (v) => setState(() => diasViaje = v.toInt())),
        const SizedBox(height: 10),
        const Text('Costos estimados por día:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        _buildSliderSimple(
            'Alojamiento por noche: \$${costoAlojamiento.toInt()}',
            costoAlojamiento,
            0,
            500,
            (v) => setState(() => costoAlojamiento = v)),
        _buildSliderSimple('Comida por día: \$${costoComida.toInt()}',
            costoComida, 0, 200, (v) => setState(() => costoComida = v)),
        const SizedBox(height: 10),
        const Text('Costos únicos:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        _buildSliderSimple(
            'Transporte: \$${costoTransporte.toInt()}',
            costoTransporte,
            0,
            1000,
            (v) => setState(() => costoTransporte = v)),
        _buildSliderSimple(
            'Actividades: \$${costoActividades.toInt()}',
            costoActividades,
            0,
            500,
            (v) => setState(() => costoActividades = v)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Por persona:', style: TextStyle(fontSize: 13)),
                  Text('\$${costoPorPersona.toInt()}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total del viaje:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('\$${costoTotal.toInt()}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 11, color: Colors.blue.shade800, height: 1.3),
                    children: const [
                      TextSpan(
                          text: 'Consejo: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              'Los precios en nuestra plataforma están verificados por la comunidad para mayor transparencia.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildSliderConIcono(IconData icono, String titulo, double valor,
      double min, double max, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icono, size: 16, color: Colors.black54),
            const SizedBox(width: 8),
            Text(titulo,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        Slider(
          value: valor,
          min: min,
          max: max,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderSimple(String titulo, double valor, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 12, color: Colors.black87)),
        Slider(
          value: valor,
          min: min,
          max: max,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
