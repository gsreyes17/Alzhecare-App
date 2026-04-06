import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/admin_provider.dart';

class HistorialCompletoAdmin extends StatefulWidget {
  const HistorialCompletoAdmin({super.key});

  @override
  State<HistorialCompletoAdmin> createState() => _HistorialCompletoAdminState();
}

class _HistorialCompletoAdminState extends State<HistorialCompletoAdmin> {
  final TextEditingController _pacienteController = TextEditingController();
  final TextEditingController _fechaDesdeController = TextEditingController();
  final TextEditingController _fechaHastaController = TextEditingController();
  final TextEditingController _resultadoController = TextEditingController();

  int? _pacienteId;
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  void _cargarHistorial() {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    provider.cargarHistorialCompleto(
      pacienteId: _pacienteId,
      fechaDesde: _fechaDesdeController.text.isEmpty
          ? null
          : _fechaDesdeController.text,
      fechaHasta: _fechaHastaController.text.isEmpty
          ? null
          : _fechaHastaController.text,
      resultado: _resultadoController.text.isEmpty
          ? null
          : _resultadoController.text,
      page: _currentPage,
      perPage: _perPage,
    );
  }

  void _aplicarFiltros() {
    _currentPage = 1;
    _cargarHistorial();
  }

  void _limpiarFiltros() {
    _pacienteId = null;
    _pacienteController.clear();
    _fechaDesdeController.clear();
    _fechaHastaController.clear();
    _resultadoController.clear();
    _currentPage = 1;
    _cargarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Completo de Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          _buildFiltros(),
          const SizedBox(height: 8),

          // Estadísticas rápidas
          _buildEstadisticasRapidas(),
          const SizedBox(height: 8),

          // Lista de diagnósticos
          Expanded(child: _buildListaDiagnosticos(adminProvider)),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pacienteController,
                    decoration: const InputDecoration(
                      labelText: 'ID Paciente',
                      hintText: 'Filtrar por ID de paciente',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _resultadoController,
                    decoration: const InputDecoration(
                      labelText: 'Resultado',
                      hintText: 'Ej: Alzheimer, Normal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fechaDesdeController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Desde',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _seleccionarFecha(_fechaDesdeController),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fechaHastaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Hasta',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _seleccionarFecha(_fechaHastaController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _aplicarFiltros,
                    icon: const Icon(Icons.search),
                    label: const Text('Aplicar Filtros'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasRapidas() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.historialCompleto.isEmpty) return const SizedBox();

        final total = provider.historialCompleto.length;
        final conAlzheimer = provider.historialCompleto
            .where(
              (d) => (d['resultado'] as String).toLowerCase().contains(
                'alzheimer',
              ),
            )
            .length;
        final normales = total - conAlzheimer;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _estadisticaItem('Total', total.toString(), Icons.assignment),
                _estadisticaItem(
                  'Alzheimer',
                  conAlzheimer.toString(),
                  Icons.warning,
                ),
                _estadisticaItem(
                  'Normales',
                  normales.toString(),
                  Icons.check_circle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _estadisticaItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildListaDiagnosticos(AdminProvider provider) {
    if (provider.isLoading && provider.historialCompleto.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.historialCompleto.isEmpty) {
      return const Center(child: Text('No se encontraron diagnósticos'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${provider.historialCompleto.length} diagnósticos encontrados',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.historialCompleto.length,
            itemBuilder: (context, index) {
              final diagnostico = provider.historialCompleto[index];
              final pacienteInfo = diagnostico['paciente_info'] ?? {};

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorPorResultado(
                      diagnostico['resultado'],
                    ),
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${pacienteInfo['nombre'] ?? 'N/A'} ${pacienteInfo['apellido'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resultado: ${diagnostico['resultado']}'),
                      Text(
                        'Confianza: ${(diagnostico['confianza'] * 100).toStringAsFixed(1)}%',
                      ),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(diagnostico['created_at']))}',
                      ),
                      if (pacienteInfo['edad'] != null)
                        Text('Edad: ${pacienteInfo['edad']} años'),
                    ],
                  ),
                  trailing: Icon(
                    _getIconPorResultado(diagnostico['resultado']),
                    color: _getColorPorResultado(diagnostico['resultado']),
                  ),
                  onTap: () {
                    // Navegar a detalle del diagnóstico
                  },
                ),
              );
            },
          ),
        ),

        // Paginación
        _buildPaginacion(provider),
      ],
    );
  }

  Widget _buildPaginacion(AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentPage > 1
                ? () {
                    _currentPage--;
                    _cargarHistorial();
                  }
                : null,
          ),
          Text('Página $_currentPage'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: provider.historialCompleto.length == _perPage
                ? () {
                    _currentPage++;
                    _cargarHistorial();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Color _getColorPorResultado(String resultado) {
    switch (resultado.toLowerCase()) {
      case 'alzheimer':
        return Colors.red;
      case 'normal':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconPorResultado(String resultado) {
    switch (resultado.toLowerCase()) {
      case 'alzheimer':
        return Icons.warning;
      case 'normal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
