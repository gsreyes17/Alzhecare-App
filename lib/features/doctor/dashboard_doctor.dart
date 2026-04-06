import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_drawer.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/coordinacion_provider.dart';

class DashboardDoctor extends StatefulWidget {
  const DashboardDoctor({super.key});

  @override
  State<DashboardDoctor> createState() => _DashboardDoctorState();
}

class _DashboardDoctorState extends State<DashboardDoctor> {
  final _searchController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _selectedPatientId;
  DateTime? _selectedFecha;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CoordinacionProvider>(context, listen: false);
      provider.cargarSolicitudesDoctor();
      provider.cargarPacientesDoctor();
      provider.cargarCitasDoctor();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(String patientId) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    final provider = Provider.of<CoordinacionProvider>(context, listen: false);
    final result = await provider.analizarParaPaciente(patientId, File(picked.path));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result == null ? 'No se pudo analizar imagen' : 'Analisis creado: ${result.resultado}'),
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
                  return const Text('Sin diagnosticos registrados.');
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

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      _selectedFecha = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _crearCita() async {
    if (_selectedPatientId == null ||
        _selectedFecha == null ||
        _tituloController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa paciente, titulo, fecha y descripcion.')));
      return;
    }

    final provider = Provider.of<CoordinacionProvider>(context, listen: false);
    final ok = await provider.crearCitaDoctor(
      patientUserId: _selectedPatientId!,
      titulo: _tituloController.text.trim(),
      fechaHora: _selectedFecha!,
      descripcion: _descripcionController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Cita creada correctamente' : provider.errorMessage.isEmpty ? 'No se pudo crear cita' : provider.errorMessage)),
    );
    if (ok) {
      _tituloController.clear();
      _descripcionController.clear();
      setState(() => _selectedFecha = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Doctor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(currentRole: authProvider.userRole, currentUserName: authProvider.userName),
      body: Consumer<CoordinacionProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.cargarSolicitudesDoctor();
              await provider.cargarPacientesDoctor();
              await provider.cargarCitasDoctor();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Hola, ${authProvider.userName}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Buscar paciente y solicitar vinculacion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pacientes vinculados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (provider.pacientesDoctor.isEmpty)
                          const Text('Aun no tienes pacientes vinculados.')
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
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Crear cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedPatientId,
                          items: provider.pacientesDoctor
                              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto)))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedPatientId = value),
                          decoration: const InputDecoration(labelText: 'Paciente'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tituloController,
                          decoration: const InputDecoration(labelText: 'Titulo de cita'),
                          maxLength: 120,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(labelText: 'Descripcion de cita'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedFecha == null
                                    ? 'Sin fecha seleccionada'
                                    : DateFormat('dd/MM/yyyy HH:mm').format(_selectedFecha!),
                              ),
                            ),
                            TextButton(onPressed: _selectDateTime, child: const Text('Seleccionar fecha')),
                            ElevatedButton(onPressed: _crearCita, child: const Text('Crear')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mis citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...provider.citasDoctor.map(
                          (cita) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(cita.titulo),
                            subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(cita.fechaHora)}\n${cita.descripcion}'),
                            trailing: SizedBox(
                              width: 170,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: cita.estado,
                                items: const [
                                  DropdownMenuItem(value: 'programada', child: Text('Programada')),
                                  DropdownMenuItem(value: 'efectuada', child: Text('Efectuada')),
                                  DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.actualizarEstadoCitaDoctor(cita.id, value);
                                  }
                                },
                              ),
                            ),
                            isThreeLine: true,
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
      ),
    );
  }
}
