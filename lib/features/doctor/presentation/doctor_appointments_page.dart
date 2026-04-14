import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/appointment_record.dart';
import '../../../core/models/basic_user.dart';
import '../data/doctor_repository.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _statusFilter = 'programada';
  // String _statusToSet = 'programada';
  String? _selectedPatientId;
  DateTime? _selectedDateTime;

  bool _loading = true;
  bool _creating = false;

  List<BasicUser> _patients = const [];
  List<AppointmentRecord> _appointments = const [];

  DoctorRepository get _repository => context.read<DoctorRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final patients = await _repository.listLinkedPatients();
      final appointments = await _repository.listAppointments(
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _appointments = appointments;
        _selectedPatientId =
            _selectedPatientId ??
            (patients.isNotEmpty ? patients.first.id : null);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible cargar citas: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refreshAppointments() async {
    try {
      final appointments = await _repository.listAppointments(
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() => _appointments = appointments);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar citas: $error')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createAppointment() async {
    if (_selectedPatientId == null ||
        _titleController.text.trim().isEmpty ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa paciente, título y fecha/hora')),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      await _repository.createAppointment(
        patientUserId: _selectedPatientId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime!,
      );
      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _selectedDateTime = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita creada y notificación enviada')),
      );
      await _refreshAppointments();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible crear la cita: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _updateStatus(
    AppointmentRecord appointment,
    String status,
  ) async {
    try {
      await _repository.updateAppointmentStatus(
        appointmentId: appointment.id,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
      await _refreshAppointments();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar: $error')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear cita',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPatientId,
                    decoration: const InputDecoration(labelText: 'Paciente'),
                    items: _patients
                        .map(
                          (patient) => DropdownMenuItem(
                            value: patient.id,
                            child: Text(
                              '${patient.fullName} (@${patient.username})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPatientId = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Contenido'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(
                      _selectedDateTime == null
                          ? 'Seleccionar fecha y hora'
                          : DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(_selectedDateTime!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _creating ? null : _createAppointment,
                      icon: _creating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_task_outlined),
                      label: Text(_creating ? 'Creando...' : 'Crear cita'),
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
                      const Expanded(
                        child: Text(
                          'Mis citas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _statusFilter,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _statusFilter = value);
                            _refreshAppointments();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'programada',
                            child: Text('Programada'),
                          ),
                          DropdownMenuItem(
                            value: 'realizada',
                            child: Text('Realizada'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelada',
                            child: Text('Cancelada'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_appointments.isEmpty)
                    const Text('No hay citas para este estado')
                  else
                    ..._appointments.map((appointment) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(appointment.title),
                        subtitle: Text(
                          '${appointment.patientName ?? appointment.patientUserId} · ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}',
                        ),
                        trailing: DropdownButton<String>(
                          value: appointment.status,
                          onChanged: (value) {
                            if (value != null && value != appointment.status) {
                              _updateStatus(appointment, value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'programada',
                              child: Text('Programada'),
                            ),
                            DropdownMenuItem(
                              value: 'realizada',
                              child: Text('Realizada'),
                            ),
                            DropdownMenuItem(
                              value: 'cancelada',
                              child: Text('Cancelada'),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
