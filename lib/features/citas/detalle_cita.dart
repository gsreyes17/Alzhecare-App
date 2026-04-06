import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/citas_provider.dart';
import '../../data/models/cita_model.dart';
import 'formulario_cita.dart';

class DetalleCita extends StatefulWidget {
  final int citaId;

  const DetalleCita({super.key, required this.citaId});

  @override
  State<DetalleCita> createState() => _DetalleCitaState();
}

class _DetalleCitaState extends State<DetalleCita> {
  @override
  void initState() {
    super.initState();
    _cargarCita();
  }

  void _cargarCita() {
    Future.microtask(() {
      Provider.of<CitasProvider>(context, listen: false)
          .obtenerCita(widget.citaId);
    });
  }

  Future<void> _cambiarEstado(BuildContext context, CitaModel cita) async {
    final estados = ['programada', 'completada', 'cancelada', 'reprogramada'];
    final estadosFormateados = {
      'programada': 'Programada',
      'completada': 'Completada',
      'cancelada': 'Cancelada',
      'reprogramada': 'Reprogramada',
    };

    String? estadoSeleccionado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((estado) {
            return ListTile(
              title: Text(estadosFormateados[estado]!),
              leading: Radio<String>(
                value: estado,
                groupValue: cita.estado,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              onTap: () => Navigator.of(context).pop(estado),
            );
          }).toList(),
        ),
      ),
    );

    if (estadoSeleccionado != null && estadoSeleccionado != cita.estado) {
      final motivoController = TextEditingController();
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Cambio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '¿Cambiar estado a ${estadosFormateados[estadoSeleccionado]}?'),
              const SizedBox(height: 16),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo del cambio (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmar == true) {
        final provider = Provider.of<CitasProvider>(context, listen: false);
        final exito = await provider.cambiarEstadoCita(
          cita.id,
          CitaCambiarEstadoRequest(
            estado: estadoSeleccionado,
            motivoCambio: motivoController.text.trim().isEmpty
                ? null
                : motivoController.text.trim(),
          ),
        );

        if (!mounted) return;

        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estado actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarCita();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarCita(BuildContext context, CitaModel cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta cita?\n\n'
          'Solo se pueden eliminar citas programadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final provider = Provider.of<CitasProvider>(context, listen: false);
      final exito = await provider.eliminarCita(cita.id);

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editarCita(BuildContext context, CitaModel cita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioCita(cita: cita),
      ),
    );

    if (resultado == true) {
      _cargarCita();
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'programada':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'reprogramada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'programada':
        return Icons.schedule;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      case 'reprogramada':
        return Icons.update;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
      ),
      body: Consumer<CitasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cita = provider.citaSeleccionada;

          if (cita == null) {
            return const Center(
              child: Text('No se pudo cargar la información de la cita'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Estado de la cita
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(cita.estado).withAlpha(25),
                    border: Border(
                      bottom: BorderSide(
                        color: _getEstadoColor(cita.estado),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getEstadoIcon(cita.estado),
                        size: 48,
                        color: _getEstadoColor(cita.estado),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cita.estadoFormatted,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getEstadoColor(cita.estado),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Información de fecha y hora
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today,
                              color: Colors.blue),
                          title: const Text('Fecha y Hora'),
                          subtitle: Text(
                            DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'es')
                                .format(cita.fechaHora),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Información del médico
                      Card(
                        child: ListTile(
                          leading:
                              const Icon(Icons.local_hospital, color: Colors.teal),
                          title: const Text('Médico'),
                          subtitle: Text(
                            cita.medicoNombreCompleto,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Información del paciente
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.purple),
                          title: const Text('Paciente'),
                          subtitle: Text(
                            cita.pacienteNombreCompleto,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Hospital
                      if (cita.hospitalNombre != null)
                        Card(
                          child: ListTile(
                            leading:
                                const Icon(Icons.business, color: Colors.indigo),
                            title: const Text('Hospital'),
                            subtitle: Text(
                              cita.hospitalNombre!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      // Motivo
                      if (cita.motivo != null && cita.motivo!.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.notes, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text(
                                      'Motivo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cita.motivo!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Notas
                      if (cita.notas != null && cita.notas!.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.description,
                                        color: Colors.blueGrey),
                                    SizedBox(width: 8),
                                    Text(
                                      'Notas',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cita.notas!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Botones de acción
                      Row(
                        children: [
                          // Editar
                          if (cita.estado == 'programada')
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _editarCita(context, cita),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          if (cita.estado == 'programada')
                            const SizedBox(width: 8),

                          // Cambiar estado
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _cambiarEstado(context, cita),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Estado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Eliminar
                      if (cita.estado == 'programada')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _eliminarCita(context, cita),
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar Cita'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Información de creación/actualización
                      Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Creada: ${DateFormat('dd/MM/yyyy HH:mm').format(cita.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Actualizada: ${DateFormat('dd/MM/yyyy HH:mm').format(cita.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
