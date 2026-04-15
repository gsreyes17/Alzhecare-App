import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/basic_user.dart';
import '../../../core/models/user_session.dart';
import '../../admin/data/admin_users_repository.dart';
import '../../../core/theme/theme_provider.dart';
import '../../admin/presentation/admin_appointments_page.dart';
import '../../analysis/presentation/analysis_page.dart';
import '../../analysis/presentation/history_page.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../doctor/presentation/doctor_appointments_page.dart';
import '../../doctor/presentation/doctor_patients_page.dart';
import '../../patient/presentation/patient_notifications_page.dart';
import '../../patient/presentation/patient_appointments_page.dart';
import '../../patient/presentation/patient_requests_page.dart';
import '../../profile/presentation/editable_profile_page.dart';
import '../../patient/presentation/diagnosis_cubit.dart';
import '../../shared/widgets/feature_placeholder_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.session});

  final UserSession session;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiagnosisCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForRole(widget.session.user.role);
    final currentItem = items[_selectedIndex.clamp(0, items.length - 1)];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                widget.session.user.role.label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(
        session: widget.session,
        items: items,
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onLogout: () => context.read<AuthCubit>().logout(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: currentItem.builder(context),
      ),
    );
  }

  List<_DrawerDestination> _itemsForRole(UserRole role) {
    return switch (role) {
      UserRole.paciente => [
        _DrawerDestination(
          title: 'Inicio',
          icon: Icons.dashboard_outlined,
          builder: (_) => PatientOverviewPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Analizar imagen',
          icon: Icons.medical_information_outlined,
          builder: (_) => AnalysisPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Historial',
          icon: Icons.history_outlined,
          builder: (_) => HistoryPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Solicitudes',
          icon: Icons.mark_email_unread_outlined,
          builder: (_) => const PatientRequestsPage(),
        ),
        _DrawerDestination(
          title: 'Notificaciones',
          icon: Icons.notifications_none_outlined,
          builder: (_) => const PatientNotificationsPage(),
        ),
        _DrawerDestination(
          title: 'Citas',
          icon: Icons.event_note_outlined,
          builder: (_) => const PatientAppointmentsPage(),
        ),
        _DrawerDestination(
          title: 'Perfil',
          icon: Icons.person_outline,
          builder: (_) => PatientProfilePage(user: widget.session.user),
        ),
      ],
      UserRole.doctor => [
        _DrawerDestination(
          title: 'Inicio',
          icon: Icons.dashboard_outlined,
          builder: (_) => DoctorOverviewPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Mis análisis',
          icon: Icons.medical_information_outlined,
          builder: (_) => AnalysisPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Mi historial',
          icon: Icons.history_outlined,
          builder: (_) => HistoryPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Pacientes',
          icon: Icons.person_search_outlined,
          builder: (_) => const DoctorPatientsPage(),
        ),
        _DrawerDestination(
          title: 'Citas',
          icon: Icons.event_available_outlined,
          builder: (_) => const DoctorAppointmentsPage(),
        ),
        _DrawerDestination(
          title: 'Notificaciones',
          icon: Icons.notifications_none_outlined,
          builder: (_) => const PatientNotificationsPage(),
        ),
        _DrawerDestination(
          title: 'Perfil',
          icon: Icons.person_outline,
          builder: (_) => DoctorProfilePage(user: widget.session.user),
        ),
      ],
      UserRole.admin => [
        _DrawerDestination(
          title: 'Inicio',
          icon: Icons.dashboard_outlined,
          builder: (_) => AdminOverviewPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Mis análisis',
          icon: Icons.medical_information_outlined,
          builder: (_) => AnalysisPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Mi historial',
          icon: Icons.history_outlined,
          builder: (_) => HistoryPage(user: widget.session.user),
        ),
        _DrawerDestination(
          title: 'Ver análisis de usuarios',
          icon: Icons.admin_panel_settings_outlined,
          builder: (_) => const AdminUsersAnalysisPage(),
        ),
        _DrawerDestination(
          title: 'Citas',
          icon: Icons.event_note_outlined,
          builder: (_) => const AdminAppointmentsPage(),
        ),
        _DrawerDestination(
          title: 'Usuarios',
          icon: Icons.manage_accounts_outlined,
          builder: (_) => const FeaturePlaceholderPage(
            title: 'Administración de usuarios',
            description:
                'Gestiona cuentas de la plataforma desde un entorno centralizado.',
          ),
        ),
        _DrawerDestination(
          title: 'Perfil',
          icon: Icons.person_outline,
          builder: (_) => AdminProfilePage(user: widget.session.user),
        ),
      ],
    };
  }
}

class _DrawerDestination {
  const _DrawerDestination({
    required this.title,
    required this.icon,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.session,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  final UserSession session;
  final List<_DrawerDestination> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10263D), Color(0xFF1A6F8F)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      backgroundImage:
                          session.user.profileImageUrl != null &&
                              session.user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(session.user.profileImageUrl!)
                          : null,
                      child:
                          session.user.profileImageUrl == null ||
                              session.user.profileImageUrl!.isEmpty
                          ? Text(
                              session.user.name.isNotEmpty
                                  ? session.user.name[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      session.user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.user.role.label,
                      style: const TextStyle(color: Color(0xFFDCE7F2)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = index == selectedIndex;
                  return ListTile(
                    selected: selected,
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelected(index);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: _ThemeSelector(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientOverviewPage extends StatelessWidget {
  const PatientOverviewPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _OverviewScaffold(
      user: user,
      title: 'Panel del paciente',
      subtitle: 'Revisa tus resultados y lleva seguimiento de tu progreso.',
      primaryActions: const [
        _QuickActionCard(
          icon: Icons.medical_information_outlined,
          title: 'Analizar imagen',
          subtitle: 'Carga una imagen y obtén tu resultado en segundos.',
        ),
        _QuickActionCard(
          icon: Icons.history_outlined,
          title: 'Historial',
          subtitle: 'Consulta tus análisis anteriores en un solo lugar.',
        ),
      ],
    );
  }
}

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _ProfilePage(user: user, title: 'Perfil de paciente');
  }
}

class DoctorOverviewPage extends StatelessWidget {
  const DoctorOverviewPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _OverviewScaffold(
      user: user,
      title: 'Panel del doctor',
      subtitle: 'Acompaña a tus pacientes y también consulta tus análisis.',
      primaryActions: const [
        _QuickActionCard(
          icon: Icons.medical_information_outlined,
          title: 'Mis análisis',
          subtitle: 'Sube y analiza tus propias imágenes.',
        ),
        _QuickActionCard(
          icon: Icons.person_search_outlined,
          title: 'Pacientes',
          subtitle: 'Busca pacientes y envía solicitudes de vinculación.',
        ),
      ],
    );
  }
}

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _ProfilePage(user: user, title: 'Perfil de doctor');
  }
}

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _OverviewScaffold(
      user: user,
      title: 'Panel administrativo',
      subtitle:
          'Monitorea la plataforma y revisa el estado general del servicio.',
      primaryActions: const [
        _QuickActionCard(
          icon: Icons.medical_information_outlined,
          title: 'Mis análisis',
          subtitle: 'Sube y analiza tus propias imágenes.',
        ),
        _QuickActionCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Ver análisis',
          subtitle: 'Busca un usuario y revisa todos sus análisis.',
        ),
      ],
    );
  }
}

class AdminUsersAnalysisPage extends StatefulWidget {
  const AdminUsersAnalysisPage({super.key});

  @override
  State<AdminUsersAnalysisPage> createState() => _AdminUsersAnalysisPageState();
}

class _AdminUsersAnalysisPageState extends State<AdminUsersAnalysisPage> {
  final _queryController = TextEditingController();
  final _repository = <AdminUsersRepository?>[];

  bool _loading = false;
  List<BasicUser> _results = const [];
  BasicUser? _selectedUser;

  AdminUsersRepository get _adminUsersRepository {
    if (_repository.isEmpty) {
      _repository.add(context.read<AdminUsersRepository>());
    }
    return _repository.first!;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    final text = query.trim();
    if (text.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final users = await _adminUsersRepository.searchUsers(text);
      if (!mounted) return;
      setState(() => _results = users);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible buscar usuarios: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver análisis de usuarios'),
        automaticallyImplyLeading: false,
      ),
      body: _selectedUser != null
          ? HistoryPage(
              user: context.read<AuthCubit>().state.session!.user,
              patientIdToView: _selectedUser!.id,
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Escribe nombre, apellido o usuario para ver su historial.',
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _queryController,
                    onChanged: _searchUsers,
                    decoration: InputDecoration(
                      labelText: 'Buscar usuario',
                      hintText: 'Ej: ana, perez, anapaciente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading) const LinearProgressIndicator(minHeight: 2),
                  if (!_loading &&
                      _queryController.text.trim().length >= 2 &&
                      _results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('No se encontraron usuarios.'),
                    ),
                  if (_results.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(user.fullName),
                            subtitle: Text('@${user.username}'),
                            trailing: OutlinedButton(
                              onPressed: () {
                                setState(() => _selectedUser = user);
                                context
                                    .read<DiagnosisCubit>()
                                    .loadHistoryForPatient(patientId: user.id);
                              },
                              child: const Text('Ver historial'),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedUser = null;
                        _results = const [];
                        _queryController.clear();
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Limpiar búsqueda'),
                  ),
                ],
              ),
            ),
      floatingActionButton: _selectedUser != null
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _selectedUser = null;
                });
              },
              icon: const Icon(Icons.close),
              label: const Text('Cambiar usuario'),
            )
          : null,
    );
  }
}

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _ProfilePage(user: user, title: 'Perfil de administrador');
  }
}

class _OverviewScaffold extends StatelessWidget {
  const _OverviewScaffold({
    required this.user,
    required this.title,
    required this.subtitle,
    required this.primaryActions,
  });

  final AppUser user;
  final String title;
  final String subtitle;
  final List<Widget> primaryActions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _HeaderCard(user: user, title: title, subtitle: subtitle),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: primaryActions.first),
                  const SizedBox(width: 16),
                  Expanded(child: primaryActions.last),
                ],
              );
            }
            return Column(
              children: [
                primaryActions.first,
                const SizedBox(height: 16),
                primaryActions.last,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.user,
    required this.title,
    required this.subtitle,
  });

  final AppUser user;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10263D), Color(0xFF1A6F8F)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFDCE7F2), height: 1.6),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(label: user.fullName),
              _InfoChip(label: user.role.label),
              _InfoChip(label: user.username),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.user, required this.title});

  final AppUser user;
  final String title;

  @override
  Widget build(BuildContext context) {
    return EditableProfilePage(initialUser: user, title: title);
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) {
        return ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Tema'),
          subtitle: Text(themeProvider.themeLabel()),
          trailing: DropdownButton<ThemeMode>(
            value: themeProvider.themeMode,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
            ],
          ),
        );
      },
    );
  }
}
