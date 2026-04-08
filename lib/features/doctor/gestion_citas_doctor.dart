import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/drawer.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/coordinacion_provider.dart';

class GestionCitasDoctor extends StatefulWidget {
  final bool showScaffold;

  const GestionCitasDoctor({super.key, this.showScaffold = true});

  @override
  State<GestionCitasDoctor> createState() => _GestionCitasDoctorState();
}

class _GestionCitasDoctorState extends State<GestionCitasDoctor> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _selectedPatientId;
  DateTime? _selectedFecha;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CoordinacionProvider>(context, listen: false);
      provider.cargarPacientesDoctor();
      provider.cargarCitasDoctor();
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa paciente, título, fecha y descripción.')),
      );
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
      SnackBar(
        content: Text(
          ok ? 'Cita creada correctamente' : (provider.errorMessage.isEmpty ? 'No se pudo crear cita' : provider.errorMessage),
        ),
      ),
    );
    if (ok) {
      _tituloController.clear();
      _descripcionController.clear();
      setState(() {
        _selectedPatientId = null;
        _selectedFecha = null;
      });
      await provider.cargarCitasDoctor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final content = Consumer<CoordinacionProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await provider.cargarCitasDoctor();
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
                      const Text('Crear nueva cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (provider.pacientesDoctor.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No tienes pacientes vinculados. Vincula pacientes primero.'),
                        )
                      else
                        Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPatientId,
                              items: provider.pacientesDoctor
                                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto)))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedPatientId = value),
                              decoration: const InputDecoration(
                                labelText: 'Paciente',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _tituloController,
                              decoration: const InputDecoration(
                                labelText: 'Título de cita',
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 120,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descripcionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción de cita',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedFecha == null
                                        ? 'Sin fecha seleccionada'
                                        : DateFormat('dd/MM/yyyy HH:mm').format(_selectedFecha!),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _selectDateTime,
                                  child: const Text('Seleccionar fecha'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _crearCita,
                                child: const Text('Crear cita'),
                              ),
                            ),
                          ],
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
                      const Text('Mis citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (provider.citasDoctor.isEmpty)
                        const Text('No tienes citas programadas.')
                      else
                        ...provider.citasDoctor.map(
                          (cita) => Card(
                            child: ListTile(
                              title: Text(cita.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy HH:mm').format(cita.fechaHora)}\n${cita.descripcion}',
                              ),
                              trailing: SizedBox(
                                width: 130,
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
        title: const Text('Gestión de Citas'),
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
