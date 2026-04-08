import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/admin_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../admin/estadisticas_detalladas.dart';
import '../admin/gestion_citas_admin.dart';
import '../admin/gestion_usuarios_admin.dart';

class DashboardAdmin extends StatefulWidget {
  final bool showScaffold;
  final VoidCallback? onOpenGestionUsuarios;
  final VoidCallback? onOpenGestionCitas;
  final VoidCallback? onOpenEstadisticas;

  const DashboardAdmin({
    super.key,
    this.showScaffold = true,
    this.onOpenGestionUsuarios,
    this.onOpenGestionCitas,
    this.onOpenEstadisticas,
  });

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarResumen();
    });
  }

  Future<void> _cargarResumen() async {
    await Provider.of<AdminProvider>(context, listen: false).cargarUsuarios();
  }

  void _openGestionUsuarios() {
    if (widget.onOpenGestionUsuarios != null) {
      widget.onOpenGestionUsuarios!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GestionUsuariosAdmin()),
    );
  }

  void _openGestionCitas() {
    if (widget.onOpenGestionCitas != null) {
      widget.onOpenGestionCitas!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GestionCitasAdmin()),
    );
  }

  void _openEstadisticas() {
    if (widget.onOpenEstadisticas != null) {
      widget.onOpenEstadisticas!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EstadisticasDetalladas()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final content = RefreshIndicator(
      onRefresh: _cargarResumen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF164B7A), Color(0xFF2B7BBB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${authProvider.userName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Resumen de administración. Usa las secciones para abrir la gestión completa.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statChip('Usuarios', adminProvider.total.toString()),
                    const SizedBox(width: 12),
                    _statChip('Rol', 'Admin'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _quickActionCard(
            icon: Icons.supervised_user_circle,
            title: 'Gestion de usuarios',
            subtitle: 'Alta, edición y estado de usuarios.',
            onPressed: _openGestionUsuarios,
          ),
          const SizedBox(height: 12),
          _quickActionCard(
            icon: Icons.calendar_month,
            title: 'Gestion de citas',
            subtitle: 'Revisa y modifica la agenda clínica.',
            onPressed: _openGestionCitas,
          ),
          const SizedBox(height: 12),
          _quickActionCard(
            icon: Icons.bar_chart,
            title: 'Estadisticas detalladas',
            subtitle: 'Abre métricas y tableros de detalle.',
            onPressed: _openEstadisticas,
          ),
        ],
      ),
    );

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de administración'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarResumen,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.12),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }
}