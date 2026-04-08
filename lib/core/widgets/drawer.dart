import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../features/global/login_auth.dart';
import '../../features/admin/gestion_citas_admin.dart';
import '../../features/admin/gestion_usuarios_admin.dart';
import '../../features/diagnostico/historial_diagnosticos.dart';
import '../../features/diagnostico/subir_imagen.dart';
import '../../features/dashboards/dashboard_paciente.dart';
import '../../features/dashboards/dashboard_doctor.dart';
import '../../features/dashboards/dashboard_admin.dart';
import 'settings.dart';

class AppDrawer extends StatelessWidget {
  final String currentRole;
  final String currentUserName;
  final String? selectedSectionId;
  final ValueChanged<String>? onSectionSelected;

  const AppDrawer({
    super.key,
    required this.currentRole,
    required this.currentUserName,
    this.selectedSectionId,
    this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileImageUrl = authProvider.currentUser?.profileImageUrl;
    final isPatient = currentRole == 'patient';
    final isDoctor = currentRole == 'doctor';
    final isAdmin = currentRole == 'admin';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: (profileImageUrl == null || profileImageUrl.isEmpty)
                      ? Icon(Icons.person, color: Colors.blue, size: 30)
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  currentUserName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentRole,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Main Menu
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text(
              isAdmin
                  ? 'Panel de administración'
                  : isDoctor
                      ? 'Panel clínico'
                      : 'Menú Principal',
            ),
            selected: selectedSectionId == '0',
            onTap: () {
              _handleNavigation(context, '0', () => _navigateToDashboard(context, currentRole));
            },
          ),
  
          Divider(),

          if (isAdmin) ...[
            _buildDrawerItem(
              sectionId: '1',
              icon: Icons.supervised_user_circle,
              title: 'Gestión de Usuarios',
              onTap: () {
                _handleNavigation(
                  context,
                  '1',
                  () => Navigator.pushReplacement(context, _animationRoute(const GestionUsuariosAdmin())),
                );
              },
            ),
            _buildDrawerItem(
              sectionId: '2',
              icon: Icons.calendar_month,
              title: 'Gestión de Citas',
              onTap: () {
                _handleNavigation(
                  context,
                  '2',
                  () => Navigator.pushReplacement(context, _animationRoute(const GestionCitasAdmin())),
                );
              },
            ),
            _buildDrawerItem(
              sectionId: '3',
              icon: Icons.bar_chart,
              title: 'Estadísticas detalladas',
              onTap: () {
                _handleNavigation(context, '3', () {});
              },
            ),
            Divider(),           
          ],
        
          _buildDrawerItem(
            sectionId: isPatient ? '1' : isDoctor ? '1' : '4',
            icon: Icons.upload_file,
            title: 'Subir imagen',
            onTap: () {
              _handleNavigation(
                context,
                isPatient ? '1' : isDoctor ? '1' : '4',
                () => Navigator.pushReplacement(context, _animationRoute(const SubirImagen())),
              );
            },
          ),
          _buildDrawerItem(
            sectionId: isPatient ? '2' : isDoctor ? '2' : '5',
            icon: Icons.history,
            title: 'Historial de diagnósticos',
            onTap: () {
              _handleNavigation(
                context,
                isPatient ? '2' : isDoctor ? '2' : '5',
                () => Navigator.pushReplacement(context, _animationRoute(const HistorialDiagnosticos())),
              );
            },
          ),          

          Divider(),
              
          _buildDrawerItem(
            sectionId: isPatient ? '3' : isDoctor ? '3' : '6',
            icon: Icons.settings,
            title: 'Mi perfil',
            onTap: () {
              _handleNavigation(
                context,
                isPatient ? '3' : isDoctor ? '3' : '6',
                () => Navigator.pushReplacement(context, _animationRoute(const Settings())),
              );
            },
          ),

          Divider(), 
             
          // Cerrar sesión
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, authProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    String? sectionId,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: icon == Icons.logout ? Colors.red : null,
      ),
      title: Text(
        title,
        style: title == 'Cerrar Sesión'
            ? const TextStyle(color: Colors.red)
            : null,
      ),
      selected: sectionId != null && selectedSectionId == sectionId,
      onTap: onTap,
    );
  }

  void _handleNavigation(BuildContext context, String sectionId, VoidCallback fallback) {
    Navigator.pop(context);
    if (onSectionSelected != null) {
      onSectionSelected!(sectionId);
      return;
    }

    fallback();
  }

  Route<dynamic> _animationRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, secondaryAnimation) => page,
      //  transitionDuration: Duration.zero,
      transitionDuration: Duration(microseconds: 300),
      reverseTransitionDuration: Duration(microseconds: 300),
    );
  }

  void _navigateToDashboard(BuildContext context, String role) {
    switch (role) {
      case 'patient':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardPaciente()),
          (route) => false,
        );
        break;
      case 'doctor':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardDoctor()),
          (route) => false,
        );
        break;
      case 'admin':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardAdmin()),
          (route) => false,
        );
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => Login()),
                  (route) => false,
                );
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
