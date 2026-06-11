import 'package:flutter/material.dart';
import '../widgets_generales/header_gen.dart';
import 'widgets/sidebar_filtros.dart';
import 'widgets/grid_resultados.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  // El estado del filtro se maneja aquí
  String _tipoBusquedaSeleccionado = 'Todo';
  double _presupuestoMaxSeleccionado = 500.0;
  String _estadoSeleccionado = 'Todos';
  double _calificacionMinSeleccionada = 1.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AQUÍ PONEMOS TU HEADER
      appBar: const CustomHeader(),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar Destinos y Alojamientos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna Izquierda: Filtros
                  SizedBox(
                    width: 300,
                    child: SidebarFiltros(
                      tipoBusquedaActual: _tipoBusquedaSeleccionado,
                      onTipoBusquedaChanged: (nuevoTipo) {
                        setState(() {
                          _tipoBusquedaSeleccionado = nuevoTipo;
                        });
                      },
                      presupuestoMaxActual: _presupuestoMaxSeleccionado,
                      onPresupuestoMaxChanged: (nuevoPrecio) {
                        setState(() {
                          _presupuestoMaxSeleccionado = nuevoPrecio;
                        });
                      },
                      estadoActual: _estadoSeleccionado,
                      onEstadoChanged: (nuevoEstado) {
                        setState(() {
                          _estadoSeleccionado = nuevoEstado;
                        });
                      },
                      calificacionMinActual: _calificacionMinSeleccionada,
                      onCalificacionMinChanged: (nuevaCalificacion) {
                        setState(() {
                          _calificacionMinSeleccionada = nuevaCalificacion;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Columna Derecha: Resultados
                  Expanded(
                    child: GridResultados(
                      categoriaFiltro: _tipoBusquedaSeleccionado,
                      precioMaxFiltro: _presupuestoMaxSeleccionado,
                      estadoFiltro: _estadoSeleccionado,
                      calificacionMinFiltro: _calificacionMinSeleccionada,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
