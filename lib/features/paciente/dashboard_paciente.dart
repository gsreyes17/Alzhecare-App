import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_drawer.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/coordinacion_provider.dart';
import '../../data/providers/diagnostico_provider.dart';
import 'historial_diagnosticos.dart';
import 'subir_imagen.dart';

class DashboardPaciente extends StatefulWidget {
  const DashboardPaciente({super.key});

  @override
  State<DashboardPaciente> createState() => _DashboardPacienteState();
}

class _DashboardPacienteState extends State<DashboardPaciente> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiagnosticoProvider>(context, listen: false).cargarHistorial();
      final coordinacion = Provider.of<CoordinacionProvider>(context, listen: false);
      coordinacion.cargarSolicitudesPaciente();
      coordinacion.cargarNotificacionesPaciente();
      coordinacion.cargarCitasPaciente();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final diagnosticoProvider = Provider.of<DiagnosticoProvider>(context);
    final coordinacionProvider = Provider.of<CoordinacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Paciente'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: RefreshIndicator(
        onRefresh: () => diagnosticoProvider.cargarHistorial(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hola, ${authProvider.userName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Rol: ${authProvider.userRoleLabel}'),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              icon: Icons.upload_file,
              title: 'Nuevo análisis',
              subtitle: 'Sube una imagen para ejecutar el modelo de IA',
              buttonLabel: 'Subir imagen',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubirImagen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.history,
              title: 'Historial de diagnósticos',
              subtitle: 'Revisa tus análisis anteriores',
              buttonLabel: 'Ver historial',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistorialDiagnosticos()),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitudes de médicos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (coordinacionProvider.solicitudesPaciente.isEmpty)
                      const Text('No hay solicitudes pendientes.')
                    else
                      ...coordinacionProvider.solicitudesPaciente.map(
                        (s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Doctor: ${s.doctorNombre ?? s.doctorUserId}'),
                          subtitle: Text('Estado: ${s.estado}'),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () => coordinacionProvider.responderSolicitudPaciente(s.id, 'denegar'),
                                child: const Text('Denegar'),
                              ),
                              ElevatedButton(
                                onPressed: () => coordinacionProvider.responderSolicitudPaciente(s.id, 'aceptar'),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citas programadas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (coordinacionProvider.citasPaciente.isEmpty)
                      const Text('No tienes citas registradas.')
                    else
                      ...coordinacionProvider.citasPaciente.take(3).map(
                        (cita) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(cita.titulo),
                          subtitle: Text(
                            '${cita.doctorNombre ?? 'Doctor'} · ${DateFormat('dd/MM/yyyy HH:mm').format(cita.fechaHora)}\n${cita.descripcion}',
                          ),
                          trailing: Text(cita.estado),
                          isThreeLine: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (coordinacionProvider.notificacionesPaciente.isEmpty)
                      const Text('Sin notificaciones.')
                    else
                      ...coordinacionProvider.notificacionesPaciente.take(5).map(
                        (n) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(n.leida ? Icons.mark_email_read : Icons.mark_email_unread),
                          title: Text(n.titulo),
                          subtitle: Text(n.mensaje),
                          trailing: n.leida
                              ? null
                              : TextButton(
                                  onPressed: () => coordinacionProvider.marcarNotificacionLeida(n.id),
                                  child: const Text('Marcar leída'),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Últimos diagnósticos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (diagnosticoProvider.isLoadingHistorial && diagnosticoProvider.diagnosticos.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ))
                    else if (diagnosticoProvider.diagnosticos.isEmpty)
                      const Text('Todavía no tienes diagnósticos registrados.')
                    else
                      ...diagnosticoProvider.diagnosticos.take(3).map(
                            (diagnostico) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.12),
                                child: const Icon(Icons.medical_information, color: Colors.blue),
                              ),
                              title: Text(diagnostico.resultado),
                              subtitle: Text(
                                '${(diagnostico.confianza * 100).toStringAsFixed(1)}% · ${diagnostico.fechaFormateada}',
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
