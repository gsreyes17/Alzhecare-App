import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/appointment_record.dart';
import '../data/admin_appointments_repository.dart';

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  bool _loading = true;
  String _statusFilter = 'programada';
  List<AppointmentRecord> _appointments = const [];

  AdminAppointmentsRepository get _repository =>
      context.read<AdminAppointmentsRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);
    try {
      final appointments = await _repository.listAppointments(
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() => _appointments = appointments);
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
      await _loadAppointments();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar: $error')),
      );
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
                  'Citas globales',
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
                child: Text('No hay citas para este estado'),
              ),
            )
          else
            ..._appointments.map((appointment) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(appointment.title),
                  subtitle: Text(
                    '${appointment.doctorName ?? appointment.doctorUserId} → ${appointment.patientName ?? appointment.patientUserId}\n${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}',
                  ),
                  isThreeLine: true,
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
                ),
              );
            }),
        ],
      ),
    );
  }
}
