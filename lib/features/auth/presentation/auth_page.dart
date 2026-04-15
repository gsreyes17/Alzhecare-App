import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? const Color(0xFF08131A) : const Color(0xFFE8F5F8),
              isDark ? const Color(0xFF174957) : const Color(0xFF74C8D6),
              isDark ? const Color(0xFF10252E) : const Color(0xFFF4FBFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.38, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final authCard = SizedBox(
                      width: 460,
                      child: _AuthCard(
                        tabController: _tabController,
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                    );
                    return ListView(
                      children: [
                        const SizedBox(height: 20),
                        authCard,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.tabController,
    required this.colorScheme,
    required this.isDark,
  });

  final TabController tabController;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.94 : 0.98),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF28424B) : const Color(0xFFD2E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bienvenido a Alzhecare',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa con tu rol o crea una cuenta de paciente.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF152C36)
                  : const Color(0xFFEAF5F8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A4651)
                    : const Color(0xFFD4E9EE),
              ),
            ),
            child: TabBar(
              controller: tabController,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.onPrimaryContainer,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Login'),
                Tab(text: 'Registro'),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 580,
            child: TabBarView(
              controller: tabController,
              children: const [_LoginForm(), _RegisterForm()],
            ),
          ),
        ],
      ),
    );
  }
}


class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 15),
              _TextField(
                controller: _usernameController,
                label: 'Usuario',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _TextField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          context.read<AuthCubit>().login(
                            username: _usernameController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                        },
                  child: loading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),
              const _RoleHint(),
            ],
          ),
        );
      },
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return Form(
          key: _formKey,
          child: ListView(
            children: [
              _TextField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _lastnameController,
                label: 'Apellido',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _usernameController,
                label: 'Usuario',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          context.read<AuthCubit>().register(
                            username: _usernameController.text.trim(),
                            password: _passwordController.text.trim(),
                            name: _nameController.text.trim(),
                            lastname: _lastnameController.text.trim(),
                            email: _emailController.text.trim(),
                          );
                        },
                  child: loading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Registrar paciente'),
                ),
              ),
              const SizedBox(height: 16),
              const _RoleHint(),
            ],
          ),
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (keyboardType == TextInputType.emailAddress &&
            !value.contains('@')) {
          return 'Ingresa un email válido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _RoleHint extends StatelessWidget {
  const _RoleHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'El registro esta reservado para pacientes. Administradores y doctores ingresan con credenciales institucionales.',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12.5,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
