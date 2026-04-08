import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/drawer.dart';
import '../../data/providers/_index_.dart';

class GestionCitasAdmin extends StatefulWidget {
  final bool showScaffold;

  const GestionCitasAdmin({super.key, this.showScaffold = true});

  @override
  State<GestionCitasAdmin> createState() => _GestionCitasAdminState();
}

class _GestionCitasAdminState extends State<GestionCitasAdmin> {
  String? _estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoordinacionProvider>(context, listen: false).cargarCitasAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final content = Consumer<CoordinacionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String?>(
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: 'programada', child: Text('Programada')),
                  DropdownMenuItem(value: 'efectuada', child: Text('Efectuada')),
                  DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                ],
                onChanged: (value) {
                  setState(() => _estado = value);
                  provider.cargarCitasAdmin(estado: value);
                },
              ),
            ),
            if (provider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.citasAdmin.length,
                  itemBuilder: (context, index) {
                    final cita = provider.citasAdmin[index];
                    return Card(
                      child: ListTile(
                        title: Text(cita.titulo),
                        subtitle: Text(
                          '${cita.patientNombre ?? 'Paciente'} · ${DateFormat('dd/MM/yyyy HH:mm').format(cita.fechaHora)}\n${cita.descripcion}',
                        ),
                        trailing: DropdownButton<String>(
                          value: cita.estado,
                          items: const [
                            DropdownMenuItem(value: 'programada', child: Text('Programada')),
                            DropdownMenuItem(value: 'efectuada', child: Text('Efectuada')),
                            DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              provider.actualizarEstadoCitaAdmin(cita.id, value);
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de citas'),
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
