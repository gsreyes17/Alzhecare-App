import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/citas_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/cita_model.dart';

class FormularioCita extends StatefulWidget {
  final CitaModel? cita; // Si es null, crear nueva; si no, editar
  final int? pacienteIdPredeterminado;

  const FormularioCita({
    super.key,
    this.cita,
    this.pacienteIdPredeterminado,
  });

  @override
  State<FormularioCita> createState() => _FormularioCitaState();
}

class _FormularioCitaState extends State<FormularioCita> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _notasController = TextEditingController();

  int? _pacienteId;
  int? _medicoId;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  bool _cargandoDisponibilidad = false;

  @override
  void initState() {
    super.initState();
    _cargarMedicos();
    _inicializarPacienteId();

    if (widget.cita != null) {
      // Modo edición
      _pacienteId = widget.cita!.pacienteId;
      _medicoId = widget.cita!.medicoId;
      _fechaSeleccionada = widget.cita!.fechaHora;
      _horaSeleccionada =
          DateFormat('HH:mm').format(widget.cita!.fechaHora);
      _motivoController.text = widget.cita!.motivo ?? '';
      _notasController.text = widget.cita!.notas ?? '';
    } else if (widget.pacienteIdPredeterminado != null) {
      _pacienteId = widget.pacienteIdPredeterminado;
    }
  }

  void _inicializarPacienteId() {
    // Obtener el pacienteId del AuthProvider si no está predeterminado
    if (_pacienteId == null && widget.cita == null) {
      Future.microtask(() {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.pacienteId != null) {
          setState(() {
            _pacienteId = authProvider.pacienteId;
          });
        }
      });
    }
  }

  void _cargarMedicos() {
    Future.microtask(() {
      Provider.of<CitasProvider>(context, listen: false).cargarMedicos();
    });
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _horaSeleccionada = null; // Resetear hora al cambiar fecha
      });

      if (_medicoId != null) {
        _cargarDisponibilidad();
      }
    }
  }

  Future<void> _cargarDisponibilidad() async {
    if (_medicoId == null || _fechaSeleccionada == null) return;

    setState(() => _cargandoDisponibilidad = true);

    final provider = Provider.of<CitasProvider>(context, listen: false);
    await provider.verificarDisponibilidad(
      _medicoId!,
      DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
    );

    setState(() => _cargandoDisponibilidad = false);
  }

  Future<void> _guardarCita() async {
    print('🔍 DEBUG: Iniciando _guardarCita');
    print('🔍 DEBUG: _pacienteId = $_pacienteId');
    print('🔍 DEBUG: _medicoId = $_medicoId');
    print('🔍 DEBUG: _fechaSeleccionada = $_fechaSeleccionada');
    print('🔍 DEBUG: _horaSeleccionada = $_horaSeleccionada');

    if (!_formKey.currentState!.validate()) {
      print('❌ DEBUG: Formulario no válido');
      return;
    }

    if (_pacienteId == null) {
      print('❌ DEBUG: _pacienteId es null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el ID del paciente. Por favor, cierre sesión y vuelva a entrar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_medicoId == null) {
      print('❌ DEBUG: _medicoId es null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un médico')),
      );
      return;
    }

    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      print('❌ DEBUG: Fecha u hora no seleccionada');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona fecha y hora')),
      );
      return;
    }

    // Combinar fecha y hora
    final horaParts = _horaSeleccionada!.split(':');
    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      int.parse(horaParts[0]),
      int.parse(horaParts[1]),
    );

    final provider = Provider.of<CitasProvider>(context, listen: false);

    bool exito = false;

    if (widget.cita == null) {
      // Crear nueva cita
      final citaRequest = CitaCreateRequest(
        pacienteId: _pacienteId!,
        medicoId: _medicoId!,
        fechaHora: fechaHora,
        motivo: _motivoController.text.trim().isEmpty
            ? null
            : _motivoController.text.trim(),
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
      );

      print('✅ DEBUG: CitaRequest creado:');
      print('   - pacienteId: ${citaRequest.pacienteId}');
      print('   - medicoId: ${citaRequest.medicoId}');
      print('   - fechaHora: ${citaRequest.fechaHora}');
      print('   - motivo: ${citaRequest.motivo}');

      print('📤 DEBUG: Enviando solicitud al backend...');
      final resultado = await provider.crearCita(citaRequest);
      print('📥 DEBUG: Respuesta recibida: ${resultado != null ? "Éxito" : "Falló"}');
      if (resultado != null) {
        print('   - Cita ID: ${resultado.id}');
      } else {
        print('   - Error: ${provider.errorMessage}');
      }
      exito = resultado != null;
    } else {
      // Actualizar cita existente
      final citaUpdate = CitaUpdateRequest(
        fechaHora: fechaHora,
        motivo: _motivoController.text.trim().isEmpty
            ? null
            : _motivoController.text.trim(),
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
      );

      exito = await provider.actualizarCita(widget.cita!.id, citaUpdate);
    }

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.cita == null
              ? 'Cita creada exitosamente'
              : 'Cita actualizada exitosamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cita == null ? 'Nueva Cita' : 'Editar Cita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCita,
          ),
        ],
      ),
      body: Consumer<CitasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.medicos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Selector de médico
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Médico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _medicoId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Selecciona un médico',
                          ),
                          items: provider.medicos.map((medico) {
                            return DropdownMenuItem<int>(
                              value: medico.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(medico.nombreCompleto),
                                  if (medico.especialidad != null)
                                    Text(
                                      medico.especialidad!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: widget.cita == null
                              ? (value) {
                                  setState(() {
                                    _medicoId = value;
                                    _horaSeleccionada = null;
                                  });
                                  if (_fechaSeleccionada != null) {
                                    _cargarDisponibilidad();
                                  }
                                }
                              : null, // No permitir cambiar médico al editar
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona un médico';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de fecha
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _fechaSeleccionada == null
                                ? 'Seleccionar fecha'
                                : DateFormat('EEEE, dd MMMM yyyy', 'es')
                                    .format(_fechaSeleccionada!),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _seleccionarFecha,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de hora (disponibilidad)
                if (_fechaSeleccionada != null && _medicoId != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Horario Disponible',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_cargandoDisponibilidad)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (provider.disponibilidad == null)
                            const Text('No hay horarios disponibles')
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: provider.disponibilidad!.horarios
                                  .map((horario) {
                                final isSelected =
                                    _horaSeleccionada == horario.horaInicio;
                                return ChoiceChip(
                                  label: Text(
                                      '${horario.horaInicio} - ${horario.horaFin}'),
                                  selected: isSelected,
                                  onSelected: horario.disponible
                                      ? (selected) {
                                          setState(() {
                                            _horaSeleccionada =
                                                horario.horaInicio;
                                          });
                                        }
                                      : null,
                                  backgroundColor: horario.disponible
                                      ? null
                                      : Colors.grey[300],
                                  selectedColor: Colors.green[100],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Motivo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Motivo de la consulta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _motivoController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Describe el motivo de la cita...',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.trim().length < 10) {
                              return 'El motivo debe tener al menos 10 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notas adicionales',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notasController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Notas opcionales...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón guardar
                ElevatedButton(
                  onPressed: provider.isLoading ? null : _guardarCita,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.cita == null
                              ? 'Crear Cita'
                              : 'Actualizar Cita',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}

