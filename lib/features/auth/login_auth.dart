import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../data/providers/auth_provider.dart';
import '../paciente/dashboard_paciente.dart';
import '../doctor/dashboard_doctor.dart';
import '../admin/dashboard_admin.dart';
import 'register_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _currentBackend = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadCurrentBackend();
  }

  void _loadCurrentBackend() {
    setState(() {
      _currentBackend = ApiService.getCurrentUrlName();
    });
  }

  void _handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      _navigateToDashboard(context, authProvider.userRole);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage)));
    }
  }

  void _navigateToDashboard(BuildContext context, String role) {
    Widget destination;
    switch (role) {
      case 'patient':
        destination = DashboardPaciente();
        break;
      case 'doctor':
        destination = DashboardDoctor();
        break;
      case 'admin':
        destination = DashboardAdmin();
        break;
      default:
        destination = DashboardPaciente();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  void _showBackendSelector(BuildContext context) {
    final Map<String, String> availableUrls = ApiService.getAvailableUrls();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.blue),
              SizedBox(width: 8),
              Text('Seleccionar Backend'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableUrls.entries.map((entry) {
                final isSelected = ApiService.baseUrl == entry.value;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[700] : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue[600] : Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      _changeBackendUrl(entry.value, context);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeBackendUrl(String newUrl, BuildContext context) async {
    await ApiService.changeBaseUrl(newUrl);
    setState(() {
      _currentBackend = ApiService.getCurrentUrlName();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backend cambiado a: $_currentBackend'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Botón discreto en la esquina superior derecha
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => _showBackendSelector(context),
                      icon: Icon(Icons.settings, size: 16),
                      label: Text(
                        _currentBackend,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.blue[700],
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'images/icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("Accede a tu cuenta de AlzheCare"),
                SizedBox(height: 20),

                if (authProvider.errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      authProvider.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                if (authProvider.isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    child: Text("Iniciar Sesión"),
                  ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Register()),
                    );
                  },
                  child: Text("Crear cuenta nueva"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
