import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/citas_provider.dart';
import '../../data/models/cita_model.dart';
import 'formulario_cita.dart';
import 'detalle_cita.dart';

class GestionCitas extends StatefulWidget {
  const GestionCitas({super.key});

  @override
  State<GestionCitas> createState() => _GestionCitasState();
}

class _GestionCitasState extends State<GestionCitas> {
  final TextEditingController _fechaController = TextEditingController();
  int? _medicoSeleccionado;
  String _filtroEstado = 'todos';
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    final provider = Provider.of<CitasProvider>(context, listen: false);
    provider.cargarCitas(page: _currentPage, limit: _limit);
    provider.cargarMedicos();
  }

  void _aplicarFiltros() {
    setState(() => _currentPage = 1);
    final provider = Provider.of<CitasProvider>(context, listen: false);
    provider.cargarCitas(
      medicoId: _medicoSeleccionado,
      estado: _filtroEstado == 'todos' ? null : _filtroEstado,
      fechaDesde: _fechaController.text.isEmpty ? null : _fechaController.text,
      page: _currentPage,
      limit: _limit,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _medicoSeleccionado = null;
      _filtroEstado = 'todos';
      _currentPage = 1;
    });
    _fechaController.clear();
    _cargarDatosIniciales();
  }

  void _cambiarPagina(int nuevaPagina) {
    setState(() => _currentPage = nuevaPagina);
    final provider = Provider.of<CitasProvider>(context, listen: false);
    provider.cargarCitas(
      medicoId: _medicoSeleccionado,
      estado: _filtroEstado == 'todos' ? null : _filtroEstado,
      fechaDesde: _fechaController.text.isEmpty ? null : _fechaController.text,
      page: _currentPage,
      limit: _limit,
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _crearCita() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioCita()),
    );

    if (resultado == true) {
      _cargarDatosIniciales();
    }
  }

  Future<void> _verDetalle(CitaModel cita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleCita(citaId: cita.id),
      ),
    );

    if (resultado == true) {
      _cargarDatosIniciales();
    }
  }

  Color _getColorPorEstado(String estado) {
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

  IconData _getIconPorEstado(String estado) {
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
        title: const Text('Gestión de Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosIniciales,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearCita,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
      body: Consumer<CitasProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filtros
              _buildFiltros(provider),
              const Divider(height: 1),

              // Lista de citas
              Expanded(child: _buildListaCitas(provider)),

              // Paginación
              if (provider.totalPages > 1) _buildPaginacion(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltros(CitasProvider provider) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int?>(
                    value: _medicoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Médico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los médicos'),
                      ),
                      ...provider.medicos.map((medico) {
                        return DropdownMenuItem(
                          value: medico.id,
                          child: Text(
                            'Dr. ${medico.nombreCompleto}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _medicoSeleccionado = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroEstado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'programada',
                        child: Text('Programada'),
                      ),
                      DropdownMenuItem(
                        value: 'completada',
                        child: Text('Completada'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelada',
                        child: Text('Cancelada'),
                      ),
                      DropdownMenuItem(
                        value: 'reprogramada',
                        child: Text('Reprogramada'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _filtroEstado = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha desde',
                      hintText: 'Seleccionar fecha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    readOnly: true,
                    onTap: _seleccionarFecha,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _aplicarFiltros,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: provider.isLoading ? null : _limpiarFiltros,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaCitas(CitasProvider provider) {
    if (provider.isLoading && provider.citas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty && provider.citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar citas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(provider.errorMessage),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarDatosIniciales,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron citas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Intenta con otros filtros o crea una nueva cita'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                'Total: ${provider.total} citas',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                'Página $_currentPage de ${provider.totalPages}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.citas.length,
            itemBuilder: (context, index) {
              final cita = provider.citas[index];
              return _buildCitaCard(cita);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCitaCard(CitaModel cita) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetalle(cita),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de estado
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: _getColorPorEstado(cita.estado),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Icono
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    _getColorPorEstado(cita.estado).withAlpha(51),
                child: Icon(
                  _getIconPorEstado(cita.estado),
                  color: _getColorPorEstado(cita.estado),
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paciente
                    Text(
                      cita.pacienteNombreCompleto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Médico
                    Row(
                      children: [
                        Icon(Icons.local_hospital,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Dr. ${cita.medicoNombreCompleto}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Fecha y hora
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm', 'es')
                              .format(cita.fechaHora),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorPorEstado(cita.estado).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getColorPorEstado(cita.estado),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cita.estadoFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getColorPorEstado(cita.estado),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón ver detalle
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginacion(CitasProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 && !provider.isLoading
                ? () => _cambiarPagina(_currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          Text(
            'Página $_currentPage de ${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed:
                _currentPage < provider.totalPages && !provider.isLoading
                    ? () => _cambiarPagina(_currentPage + 1)
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }
}

