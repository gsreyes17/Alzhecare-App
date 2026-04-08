import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/auth_provider.dart';
import '../../features/admin/estadisticas_detalladas.dart';
import '../../features/admin/gestion_citas_admin.dart';
import '../../features/admin/gestion_usuarios_admin.dart';
import '../../features/dashboards/dashboard_admin.dart';
import '../../features/dashboards/dashboard_doctor.dart';
import '../../features/dashboards/dashboard_paciente.dart';
import '../../features/diagnostico/historial_diagnosticos.dart';
import '../../features/diagnostico/subir_imagen.dart';
import '../../features/doctor/gestion_citas_doctor.dart';
import '../../features/doctor/gestion_pacientes_doctor.dart';
import 'drawer.dart';
import 'settings.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Panel Paciente',
    'Subir Imagen',
    'Historial de Diagnósticos',
    'Mi perfil',
  ];

  void _selectIndex(int index) {
    if (_selectedIndex == index) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final sections = [
      DashboardPaciente(
        showScaffold: false,
        onOpenSubirImagen: () => _selectIndex(1),
        onOpenHistorial: () => _selectIndex(2),
      ),
      const SubirImagen(showScaffold: false),
      const HistorialDiagnosticos(showScaffold: false),
      const Settings(showScaffold: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
        selectedSectionId: _selectedIndex.toString(),
        onSectionSelected: (sectionId) => _selectIndex(int.parse(sectionId)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: sections,
      ),
    );
  }
}

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Panel Clínico',    
    'Gestión de Pacientes',
    'Gestión de Citas',
    'Subir Imagen',
    'Historial de Diagnósticos',
    'Mi perfil',
  ];

  void _selectIndex(int index) {
    if (_selectedIndex == index) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final sections = [
      DashboardDoctor(showScaffold: false),
      const GestionPacientesDoctor(showScaffold: false),
      const GestionCitasDoctor(showScaffold: false),
      const SubirImagen(showScaffold: false),
      const HistorialDiagnosticos(showScaffold: false),
      const Settings(showScaffold: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
        selectedSectionId: _selectedIndex.toString(),
        onSectionSelected: (sectionId) => _selectIndex(int.parse(sectionId)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: sections,
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Panel de administración',
    'Administración de usuarios',
    'Gestión de citas',
    'Estadísticas detalladas',    
    'Mi perfil',
  ];

  void _selectIndex(int index) {
    if (_selectedIndex == index) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final sections = [
      DashboardAdmin(
        showScaffold: false,
        onOpenGestionUsuarios: () => _selectIndex(1),
        onOpenGestionCitas: () => _selectIndex(2),
        onOpenEstadisticas: () => _selectIndex(3),
      ),
      const GestionUsuariosAdmin(showScaffold: false),
      const GestionCitasAdmin(showScaffold: false),
      const EstadisticasDetalladas(showScaffold: false),
      const Settings(showScaffold: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
        selectedSectionId: _selectedIndex.toString(),
        onSectionSelected: (sectionId) => _selectIndex(int.parse(sectionId)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: sections,
      ),
    );
  }
}