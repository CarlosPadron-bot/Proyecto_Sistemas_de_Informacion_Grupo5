import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GestionUsuariosDashboard extends StatefulWidget {
  const GestionUsuariosDashboard({Key? key}) : super(key: key);

  @override
  State<GestionUsuariosDashboard> createState() =>
      _GestionUsuariosDashboardState();
}

class _GestionUsuariosDashboardState extends State<GestionUsuariosDashboard> {
  String _searchQuery = '';
  String _selectedRolFilter = 'Todos los roles';

  // 1. CREAMOS UNA VARIABLE PARA EL STREAM
  late Stream<QuerySnapshot> _usuariosStream;

  @override
  void initState() {
    super.initState();
    // 2. INICIALIZAMOS EL STREAM AQUÍ (Para que no se reinicie al escribir en el buscador)
    _usuariosStream =
        FirebaseFirestore.instance.collection('usuarios').snapshots();
  }

  // --- CUADRO DE DIÁLOGO DE CONFIRMACIÓN ---
  Future<bool?> _mostrarConfirmacion(
      String titulo, String mensaje, Color colorBoton) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title:
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: colorBoton),
              child: const Text('Estoy seguro',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- LÓGICA PARA SUSPENDER USUARIO ---
  Future<void> _suspenderUsuario(
      String uid, String username, bool estaSuspendido) async {
    String accion = estaSuspendido ? 'Reactivar' : 'Suspender';
    bool? confirmar = await _mostrarConfirmacion(
      '$accion Usuario',
      '¿Estás seguro de que deseas ${accion.toLowerCase()} a $username?',
      estaSuspendido ? Colors.green : Colors.orange,
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .update({'activo': estaSuspendido ? true : false});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Usuario ${estaSuspendido ? 'reactivado' : 'suspendido'} exitosamente'),
              backgroundColor:
                  estaSuspendido ? const Color(0xFF00B14F) : Colors.orange,
            ),
          );
        }
      } catch (e) {
        _mostrarError('Error al $accion: $e');
      }
    }
  }

  // --- LÓGICA PARA ELIMINAR USUARIO ---
  Future<void> _eliminarUsuario(String uid, String username) async {
    bool? confirmar = await _mostrarConfirmacion(
      'Eliminar Usuario',
      '¿Estás seguro de que deseas eliminar permanentemente a $username? Esta acción borrará sus datos de la tabla y no se puede deshacer.',
      Colors.red,
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .update({
              'activo': false,
              'eliminado': true, // Este es el campo que bloqueará el login
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Usuario eliminado exitosamente de la base de datos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _mostrarError('Error al eliminar: $e');
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usuariosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF00B14F))),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No se encontraron usuarios en el sistema.'));
        }

        final allUsers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['eliminado'] != true; // Excluye usuarios eliminados
        }).toList();

        int viajerosCount = 0;
        int operadoresCount = 0;

        for (var doc in allUsers) {
          final data = doc.data() as Map<String, dynamic>;
          final rol = (data['rol'] ?? 'viajero').toString().toLowerCase();
          if (rol == 'operador') {
            operadoresCount++;
          } else if (rol == 'viajero') {
            viajerosCount++;
          }
        }
        int totalUsuarios = allUsers.length;

        // --- FILTRADO DINÁMICO (AQUÍ USAMOS "username" EXACTO) ---
        final filteredUsers = allUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final name = (data['username'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? doc.id).toString().toLowerCase();
          final rol = (data['rol'] ?? 'viajero').toString().toLowerCase();

          final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
              email.contains(_searchQuery.toLowerCase());

          bool matchesFilter = true;
          if (_selectedRolFilter == 'Viajeros') {
            matchesFilter = (rol == 'viajero');
          } else if (_selectedRolFilter == 'Operadores') {
            matchesFilter = (rol == 'operador');
          }

          return matchesSearch && matchesFilter;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestión de Usuarios',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra cuentas y asigna roles en el sistema',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // TARJETAS DE MÉTRICAS
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = (constraints.maxWidth - 32) / 3;
                  if (constraints.maxWidth < 600)
                    cardWidth = constraints.maxWidth;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildMetricCard(
                          title: 'Viajeros Registrados',
                          value: '$viajerosCount',
                          color: const Color(0xFF1A73E8),
                          icon: Icons.people_alt,
                          width: cardWidth),
                      _buildMetricCard(
                          title: 'Operadores Activos',
                          value: '$operadoresCount',
                          color: const Color(0xFFA142F4),
                          icon: Icons.shield_outlined,
                          width: cardWidth),
                      _buildMetricCard(
                          title: 'Total de Usuarios',
                          value: '$totalUsuarios',
                          color: const Color(0xFF00B14F),
                          icon: Icons.group_add,
                          width: cardWidth),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // BÚSQUEDA Y FILTRADO
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre o email...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRolFilter,
                        items: ['Todos los roles', 'Viajeros', 'Operadores']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null)
                            setState(() => _selectedRolFilter = newValue);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TABLA DE USUARIOS
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(cardColor: Colors.white),
                  child: DataTable(
                    // ACTUALIZACIÓN DE WIDGET PARA QUITAR LA ADVERTENCIA AZUL
                    headingRowColor:
                        WidgetStateProperty.all(Colors.grey.shade50),
                    columns: const [
                      DataColumn(
                          label: Text('Usuario',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Email',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Rol',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Acciones',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredUsers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String uid = doc.id;

                      // Leemos "username" para mostrarlo en la tabla
                      final String username = data['username'] ?? 'Sin nombre';
                      final String email = data['email'] ?? 'Sin correo';
                      final bool isActivo = data['activo'] ?? true;

                      String rol =
                          (data['rol'] ?? 'viajero').toString().toLowerCase();
                      if (rol == 'administrador') rol = 'admin';

                      bool esAdmin = (rol == "admin");

                      return DataRow(cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                // ACTUALIZACIÓN PARA QUITAR LA ADVERTENCIA AZUL
                                backgroundColor: isActivo
                                    ? _getRolColor(rol).withValues(alpha: 0.2)
                                    : Colors.grey.shade300,
                                child: Text(
                                  username.isNotEmpty
                                      ? username[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                      color: isActivo
                                          ? _getRolColor(rol)
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(username,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      decoration: isActivo
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      color: isActivo
                                          ? Colors.black
                                          : Colors.grey)),
                            ],
                          ),
                        ),
                        DataCell(Text(email,
                            style: TextStyle(
                                color:
                                    isActivo ? Colors.black87 : Colors.grey))),
                        DataCell(_buildEtiquetaRol(rol, isActivo)),
                        DataCell(
                          esAdmin 
                            ? const Row(
                                children: [
                                  Icon(Icons.security, color: Colors.grey, size: 18),
                                  SizedBox(width: 6),
                                  Text('Protegido', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
                                ],
                              )
                            : Row(
                              children: [
                              IconButton(
                                icon: Icon(
                                    isActivo
                                        ? Icons.block
                                        : Icons.check_circle_outline,
                                    color:
                                        isActivo ? Colors.orange : Colors.green,
                                    size: 20),
                                tooltip: isActivo ? 'Suspender' : 'Reactivar',
                                onPressed: () =>
                                    _suspenderUsuario(uid, username, !isActivo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                tooltip: 'Eliminar permanentemente',
                                onPressed: () =>
                                    _eliminarUsuario(uid, username),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildMetricCard(
      {required String title,
      required String value,
      required Color color,
      required IconData icon,
      required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 40),
        ],
      ),
    );
  }

  // 🛠️ NUEVO WIDGET: Reemplaza la funcionalidad de DropdownButton por una etiqueta visual de lectura limpia
  Widget _buildEtiquetaRol(String rolActual, bool isActivo) {
    Color baseColor = isActivo ? _getRolColor(rolActual) : Colors.grey;
    String textoRol = ['admin', 'operador', 'viajero'].contains(rolActual)
        ? rolActual
        : 'viajero';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        textoRol.toUpperCase(),
        style: TextStyle(
            color: baseColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'admin':
        return Colors.orange.shade700;
      case 'operador':
        return Colors.purple;
      default:
        return Colors.blue.shade600;
    }
  }
}
