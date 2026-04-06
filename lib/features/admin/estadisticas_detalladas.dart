import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/admin_provider.dart';

class EstadisticasDetalladas extends StatefulWidget {
  const EstadisticasDetalladas({super.key});

  @override
  State<EstadisticasDetalladas> createState() => _EstadisticasDetalladasState();
}

class _EstadisticasDetalladasState extends State<EstadisticasDetalladas>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar datos específicos si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosDetallados();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosDetallados() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Cargar datos de diferentes secciones
    await Future.wait([
      adminProvider.cargarDiagnosticosPorClasificacion(),
      adminProvider.cargarCitasPorHospital(),
      adminProvider.cargarTendenciasMensuales(meses: 12),
      adminProvider.cargarActividadReciente(limit: 50),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Detalladas'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Diagnósticos'),
            Tab(icon: Icon(Icons.local_hospital), text: 'Hospitales'),
            Tab(icon: Icon(Icons.timeline), text: 'Tendencias'),
            Tab(icon: Icon(Icons.history), text: 'Actividad'),
          ],
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDiagnosticosTab(provider, colorScheme),
              _buildHospitalesTab(provider, colorScheme),
              _buildTendenciasTab(provider, colorScheme),
              _buildActividadTab(provider, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiagnosticosTab(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.diagnosticosPorClasificacion.isEmpty) {
      return _buildEmptyState('No hay datos de diagnósticos disponibles');
    }

    final total = provider.diagnosticosPorClasificacion
        .fold<int>(0, (sum, item) => sum + (item.cantidad ?? 0));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución de Diagnósticos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total de diagnósticos: $total',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Divider(height: 32),
                ...provider.diagnosticosPorClasificacion.map((diag) {
                  final cantidad = diag.cantidad ?? 0;
                  final porcentaje = total > 0 ? (cantidad / total) : 0.0;
                  final color = _getColorForClasificacion(diag.clasificacion ?? '');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                diag.clasificacion ?? 'Sin clasificación',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '$cantidad casos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: porcentaje,
                            minHeight: 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(porcentaje * 100).toStringAsFixed(1)}% del total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Confianza: ${diag.confianzaPromedio?.toStringAsFixed(1) ?? 0}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${diag.pacientesUnicos ?? 0} pacientes únicos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalesTab(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.citasPorHospital.isEmpty) {
      return _buildEmptyState('No hay datos de hospitales disponibles');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...provider.citasPorHospital.map((hospital) {
          final totalCitas = hospital.totalCitas ?? 0;
          final programadas = hospital.programadas ?? 0;
          final completadas = hospital.completadas ?? 0;
          final canceladas = hospital.canceladas ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.local_hospital,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital.hospital ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              hospital.ciudad ?? 'N/A',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalCitas citas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          'Programadas',
                          programadas,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatChip(
                          'Completadas',
                          completadas,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatChip(
                          'Canceladas',
                          canceladas,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (totalCitas > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: programadas,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        if (completadas > 0)
                          Expanded(
                            flex: completadas,
                            child: Container(
                              height: 8,
                              color: Colors.green,
                            ),
                          ),
                        if (canceladas > 0)
                          Expanded(
                            flex: canceladas,
                            child: Container(
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTendenciasTab(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.tendenciasMensuales.isEmpty) {
      return _buildEmptyState('No hay datos de tendencias disponibles');
    }

    final maxDiagnosticos = provider.tendenciasMensuales
        .map((e) => e.totalDiagnosticos)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tendencias Mensuales',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Diagnósticos por mes (últimos 12 meses)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Divider(height: 32),
                ...provider.tendenciasMensuales.map((mes) {
                  final altura = maxDiagnosticos > 0
                      ? (mes.totalDiagnosticos / maxDiagnosticos)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatearMes(mes.mes),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${mes.totalDiagnosticos} diagnósticos',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: altura,
                                  minHeight: 24,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${mes.pacientesUnicos} pacientes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Confianza: ${mes.confianzaPromedio?.toStringAsFixed(1) ?? "0.0"}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActividadTab(AdminProvider provider, ColorScheme colorScheme) {
    if (provider.actividadReciente.isEmpty) {
      return _buildEmptyState('No hay actividad reciente');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.actividadReciente.length,
      itemBuilder: (context, index) {
        final actividad = provider.actividadReciente[index];
        final color = _getColorForActividad(actividad.tipo ?? '');
        final icon = _getIconForActividad(actividad.tipo ?? '');

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(actividad.descripcion ?? 'Sin descripción'),
            subtitle: Text(_formatearFechaCompleta(actividad.fecha)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                actividad.tipo ?? 'N/A',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getColorForClasificacion(String clasificacion) {
    final lower = clasificacion.toLowerCase();
    if (lower.contains('sin demencia') || lower.contains('non')) {
      return Colors.green;
    }
    if (lower.contains('leve') || lower.contains('mild')) return Colors.orange;
    if (lower.contains('moderada') || lower.contains('moderate')) {
      return Colors.red;
    }
    return Colors.blue;
  }

  Color _getColorForActividad(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'diagnostico':
        return Colors.blue;
      case 'cita':
        return Colors.green;
      case 'usuario':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForActividad(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'diagnostico':
        return Icons.analytics;
      case 'cita':
        return Icons.event;
      case 'usuario':
        return Icons.person_add;
      default:
        return Icons.circle;
    }
  }

  String _formatearMes(DateTime? mes) {
    if (mes == null) return 'Fecha desconocida';
    try {
      return DateFormat('MMMM yyyy', 'es').format(mes);
    } catch (e) {
      return mes.toString();
    }
  }

  String _formatearFechaCompleta(DateTime? fecha) {
    if (fecha == null) return 'Fecha desconocida';

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} horas';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';

    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
}

