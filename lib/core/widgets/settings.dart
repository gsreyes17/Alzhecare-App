import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/auth_model.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/theme_provider.dart';
import 'drawer.dart';
import '../../features/global/login_auth.dart';

class Settings extends StatefulWidget {
  final bool showScaffold;

  const Settings({super.key, this.showScaffold = true});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshCurrentUser();
      final user = authProvider.currentUser;
      if (user != null && mounted) {
        _nombreController.text = user.nombre;
        _apellidoController.text = user.apellido;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 960,
        maxHeight: 960,
        imageQuality: 88,
      );

      if (pickedFile == null) return;

      final ok = await authProvider.uploadProfilePhoto(File(pickedFile.path));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Foto actualizada' : authProvider.errorMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_nombreController.text.trim().isEmpty || _apellidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y apellido son obligatorios')),
      );
      return;
    }

    setState(() => _savingProfile = true);

    final ok = await authProvider.updateCurrentUserProfile(
      UserProfileUpdateRequest(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _savingProfile = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Perfil actualizado' : authProvider.errorMessage)),
    );

    if (ok) {
      _passwordController.clear();
    }
  }

  Future<void> _confirmLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Quieres cerrar la sesión actual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await authProvider.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

  Widget _buildContent(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentUser = authProvider.currentUser;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage: currentUser?.profileImageUrl != null && currentUser!.profileImageUrl!.isNotEmpty
                          ? NetworkImage(currentUser.profileImageUrl!)
                          : null,
                      child: currentUser?.profileImageUrl == null || currentUser!.profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 42)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(child: Text('Toca la imagen para actualizarla')),
                const SizedBox(height: 12),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Nueva contraseña (opcional)'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _savingProfile ? null : _saveProfile,
                    icon: _savingProfile
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Modo oscuro'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    final authProvider = context.watch<AuthProvider>();

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}