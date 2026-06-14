import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_sistemas_info_grupo5/widgets_generales/header_gen.dart';

class PanelAdmin extends StatefulWidget {
  const PanelAdmin({super.key});

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> {
  int _selectedIndex = 0;

  final CollectionReference _usuariosRef =
      FirebaseFirestore.instance.collection('usuarios');

  Future<void> _actualizarRol(String uid, String nuevoRol) async {
    try {
      await _usuariosRef.doc(uid).update({'rol': nuevoRol});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol actualizado a $nuevoRol exitosamente'),
            backgroundColor: const Color(0xFF00B14F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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

              if (_selectedIndex == 0) _buildDashboardView(),
              if (_selectedIndex == 1) _buildUserManagementView(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildStatCard('Paquetes Activos', '5', Icons.inventory_2, const Color(0xFF10B981)),
            _buildStatCard('Alojamientos', '6', Icons.home, const Color(0xFF3B82F6)),
            _buildStatCard('Usuarios Activos', '6', Icons.person, const Color(0xFFA855F7)),
            _buildStatCard('Ingresos Totales', '\$400', Icons.attach_money, const Color(0xFFEAB308)),
            
            InkWell(
              onTap: () => setState(() => _selectedIndex = 1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.manage_accounts, color: Colors.white, size: 30),
                        Text('6', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Gestionar Usuarios', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Ver, asignar roles o suspender cuentas', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            Container(
              width: 480,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.show_chart, color: Colors.white, size: 30),
                      Text('2', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Transacciones del Mes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('Reservas pagadas en el mes actual', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildUserManagementView() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      child: StreamBuilder<QuerySnapshot>(
        stream: _usuariosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userDoc = snapshot.data!.docs[index];
              var userData = userDoc.data() as Map<String, dynamic>;
              
              String uid = userDoc.id;
              String email = userData['email'] ?? 'Sin correo';
              String rolActual = userData['rol'] ?? 'viajero';
              bool esElAdminActual = uid == FirebaseAuth.instance.currentUser?.uid;

              return Card(
                elevation: 0,
                color: Colors.grey[100],
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD1FAE5),
                    child: Icon(Icons.person, color: Color(0xFF059669)),
                  ),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rol actual: ${rolActual.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                  trailing: esElAdminActual
                      ? const Chip(label: Text('TÚ (Admin)'), backgroundColor: Colors.amber)
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ['admin', 'operador', 'viajero'].contains(rolActual.toLowerCase()) 
                                  ? rolActual.toLowerCase() 
                                  : 'viajero',
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                                DropdownMenuItem(value: 'operador', child: Text('Operador')),
                                DropdownMenuItem(value: 'viajero', child: Text('Viajero')),
                              ],
                              onChanged: (nuevoRol) {
                                if (nuevoRol != null && nuevoRol != rolActual) {
                                  _actualizarRol(uid, nuevoRol);
                                }
                              },
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}