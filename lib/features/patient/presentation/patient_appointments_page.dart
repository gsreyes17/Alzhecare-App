import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/appointment_record.dart';
import '../data/patient_appointments_repository.dart';

class PatientAppointmentsPage extends StatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  State<PatientAppointmentsPage> createState() => _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage> {
  bool _loading = true;
  String _statusFilter = 'programada';
  List<AppointmentRecord> _appointments = const [];

  PatientAppointmentsRepository get _repository =>
      context.read<PatientAppointmentsRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);
    try {
      final items = await _repository.listAppointments(status: _statusFilter);
      if (!mounted) return;
      setState(() => _appointments = items);
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mis citas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              DropdownButton<String>(
                value: _statusFilter,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _statusFilter = value);
                    _loadAppointments();
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No tienes citas para este estado.'),
              ),
            )
          else
            ..._appointments.map((appointment) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(appointment.title),
                  subtitle: Text(
                    '${appointment.doctorName ?? appointment.doctorUserId} • ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}',
                  ),
                  trailing: Chip(
                    label: Text(_labelForStatus(appointment.status)),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _labelForStatus(String status) {
    return switch (status.toLowerCase()) {
      'programada' => 'Programada',
      'realizada' => 'Realizada',
      'cancelada' => 'Cancelada',
      _ => status,
    };
  }
}
