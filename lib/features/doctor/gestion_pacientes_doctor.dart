import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/drawer.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/coordinacion_provider.dart';

class GestionPacientesDoctor extends StatefulWidget {
  final bool showScaffold;

  const GestionPacientesDoctor({super.key, this.showScaffold = true});

  @override
  State<GestionPacientesDoctor> createState() => _GestionPacientesDoctorState();
}

class _GestionPacientesDoctorState extends State<GestionPacientesDoctor> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CoordinacionProvider>(context, listen: false);
      provider.cargarPacientesDoctor();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(String patientId) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    if (!mounted) return;

    final provider = Provider.of<CoordinacionProvider>(context, listen: false);
    final result = await provider.analizarParaPaciente(patientId, File(picked.path));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result == null ? 'No se pudo analizar imagen' : 'Análisis creado: ${result.resultado}'),
      ),
    );
  }

  Future<void> _showHistorial(String patientId) async {
    final provider = Provider.of<CoordinacionProvider>(context, listen: false);
    await provider.cargarHistorialPaciente(patientId);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Historial del paciente'),
          content: SizedBox(
            width: 500,
            child: Consumer<CoordinacionProvider>(
              builder: (context, p, _) {
                if (p.isLoading) return const Center(child: CircularProgressIndicator());
                if (p.historialPacienteSeleccionado.isEmpty) {
                  return const Text('Sin diagnósticos registrados.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: p.historialPacienteSeleccionado.length,
                  itemBuilder: (context, index) {
                    final d = p.historialPacienteSeleccionado[index];
                    return ListTile(
                      title: Text(d.resultado),
                      subtitle: Text('${(d.confianza * 100).toStringAsFixed(1)}% - ${d.fechaFormateada} ${d.horaFormateada}'),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final content = Consumer<CoordinacionProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await provider.cargarPacientesDoctor();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buscar paciente y solicitar vinculación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Nombre, apellido, usuario o email',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => provider.buscarPacientes(_searchController.text),
                          ),
                        ),
                        onSubmitted: provider.buscarPacientes,
                      ),
                      const SizedBox(height: 12),
                      if (provider.searchPacientes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Comienza a buscar pacientes por nombre, usuario o email'),
                        )
                      else
                        ...provider.searchPacientes.map(
                          (p) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(p.nombreCompleto),
                            subtitle: Text('${p.username} · ${p.email}'),
                            trailing: ElevatedButton(
                              onPressed: () => provider.enviarSolicitudVinculacion(p.id),
                              child: const Text('Solicitar'),
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
                      const Text('Pacientes vinculados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (provider.pacientesDoctor.isEmpty)
                        const Text('Aún no tienes pacientes vinculados.')
                      else
                        ...provider.pacientesDoctor.map(
                          (p) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(p.nombreCompleto),
                            subtitle: Text(p.email),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showHistorial(p.id),
                                  child: const Text('Historial'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _pickAndAnalyze(p.id),
                                  child: const Text('Analizar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pacientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: content,
    );
  }
}
