import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_drawer.dart';
import '../../data/models/auth_model.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/providers/auth_provider.dart';
import 'gestion_citas_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  String? _selectedRole;
  bool? _selectedEstado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarUsuarios();
    });
  }

  Future<void> _cargarUsuarios() async {
    await Provider.of<AdminProvider>(context, listen: false).cargarUsuarios(
      role: _selectedRole,
      estado: _selectedEstado,
    );
  }

  Future<void> _abrirCrearUsuario() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => const _UsuarioDialog(mode: _UsuarioDialogMode.create),
    );

    if (resultado == true && mounted) {
      await _cargarUsuarios();
    }
  }

  Future<void> _abrirEditarUsuario(UserResponse user) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => _UsuarioDialog(mode: _UsuarioDialogMode.edit, user: user),
    );

    if (resultado == true && mounted) {
      await _cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarUsuarios,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestionCitasAdmin()),
              );
            },
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: _abrirCrearUsuario,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      drawer: MainDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarUsuarios,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: UserRole.patient, child: Text('Paciente')),
                        DropdownMenuItem(value: UserRole.doctor, child: Text('Doctor')),
                        DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value);
                        _cargarUsuarios();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      value: _selectedEstado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: true, child: Text('Activos')),
                        DropdownMenuItem(value: false, child: Text('Inactivos')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedEstado = value);
                        _cargarUsuarios();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Desde edición admin se actualizan nombre/apellido/estado/rol y contraseña opcional; usuario/correo son solo lectura.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statChip('Usuarios', adminProvider.total.toString()),
                  const SizedBox(width: 12),
                  _statChip('Rol', _selectedRole == null ? 'Todos' : _selectedRole!.roleLabel),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: adminProvider.isLoading && adminProvider.users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.errorMessage.isNotEmpty && adminProvider.users.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(adminProvider.errorMessage, textAlign: TextAlign.center),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: adminProvider.users.length,
                          itemBuilder: (context, index) {
                            final user = adminProvider.users[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: user.estado ? Colors.green : Colors.grey,
                                  child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?'),
                                ),
                                title: Text('${user.nombre} ${user.apellido}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.username),
                                    Text(user.email),
                                    Text('Rol: ${user.roleLabel}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _abrirEditarUsuario(user);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(value),
          ],
        ),
      ),
    );
  }
}

enum _UsuarioDialogMode { create, edit }

class _UsuarioDialog extends StatefulWidget {
  final _UsuarioDialogMode mode;
  final UserResponse? user;

  const _UsuarioDialog({required this.mode, this.user});

  @override
  State<_UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<_UsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _role;
  bool _estado = true;
  bool _isSaving = false;

  bool get _canEditRole {
    final isCreate = widget.mode == _UsuarioDialogMode.create;
    if (isCreate) return true;
    return widget.user?.role != UserRole.patient;
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _nombreController = TextEditingController(text: widget.user?.nombre ?? '');
    _apellidoController = TextEditingController(text: widget.user?.apellido ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _role = widget.user?.role ?? UserRole.doctor;
    _estado = widget.user?.estado ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final isCreate = widget.mode == _UsuarioDialogMode.create;

    return AlertDialog(
      title: Text(isCreate ? 'Crear usuario' : 'Editar usuario'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCreate)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                  )
                else
                  TextFormField(
                    initialValue: widget.user?.username ?? '',
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    enabled: false,
                  ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                if (isCreate)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                  )
                else
                  TextFormField(
                    initialValue: widget.user?.email ?? '',
                    decoration: const InputDecoration(labelText: 'Correo'),
                    enabled: false,
                  ),
                if (isCreate)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                  )
                else
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña (opcional)',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                if (_canEditRole)
                  DropdownButtonFormField<String>(
                    value: (_role == UserRole.doctor || _role == UserRole.admin)
                        ? _role
                        : UserRole.doctor,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(value: UserRole.doctor, child: Text('Doctor')),
                      DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _role = value);
                    },
                  )
                else
                  TextFormField(
                    initialValue: widget.user?.roleLabel ?? 'Paciente',
                    decoration: const InputDecoration(labelText: 'Rol'),
                    enabled: false,
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _estado,
                  onChanged: (value) => setState(() => _estado = value),
                  title: const Text('Usuario activo'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : () async {
            if (!_formKey.currentState!.validate()) return;

            setState(() => _isSaving = true);

            try {
              final payload = isCreate
                  ? AdminCreateUserRequest(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text,
                      nombre: _nombreController.text.trim(),
                      apellido: _apellidoController.text.trim(),
                      email: _emailController.text.trim(),
                      role: _role ?? UserRole.doctor,
                    )
                  : AdminUpdateUserRequest(
                      nombre: _nombreController.text.trim(),
                      apellido: _apellidoController.text.trim(),
                      password: _passwordController.text.trim().isEmpty
                          ? null
                          : _passwordController.text.trim(),
                      estado: _estado,
                      role: _canEditRole ? _role : null,
                    );

              if (isCreate) {
                await adminProvider.crearUsuario(payload as AdminCreateUserRequest);
              } else {
                await adminProvider.actualizarUsuario(widget.user!.id, payload as AdminUpdateUserRequest);
              }

              if (mounted) {
                Navigator.pop(context, true);
              }
            } finally {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            }
          },
          child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }
}
