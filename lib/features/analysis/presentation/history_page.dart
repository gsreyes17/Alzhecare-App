import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../patient/presentation/diagnosis_cubit.dart';
import '../../patient/presentation/diagnosis_state.dart';

/// Historial de análisis para cualquier usuario (paciente, doctor, admin)
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.user, this.patientIdToView});

  /// Usuario actual (propietario de la sesión)
  final AppUser user;

  /// Si es doctor/admin, puede ver historial de un paciente específico
  final String? patientIdToView;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    if (widget.patientIdToView != null) {
      context.read<DiagnosisCubit>().loadHistoryForPatient(
        patientId: widget.patientIdToView!,
      );
    } else {
      context.read<DiagnosisCubit>().loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadHistory(),
      child: BlocBuilder<DiagnosisCubit, DiagnosisState>(
        builder: (context, state) {
          if (state.status == DiagnosisStatus.loading &&
              state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin análisis previos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.history.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final record = state.history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.medical_information_outlined,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    record.result,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(record.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(label: 'ID', value: record.id),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'Resultado', value: record.result),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Confianza',
                            value:
                                '${(record.confidence * 100).toStringAsFixed(2)}%',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Estado',
                            value: record.status ?? 'completed',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Fecha',
                            value: DateFormat(
                              'dd/MM/yyyy HH:mm:ss',
                            ).format(record.createdAt),
                          ),
                          if (record.imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Imagen analizada',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Image.network(
                                  record.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'No se pudo cargar la imagen',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (record.modelOutput != null &&
                              record.modelOutput!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Detalles del modelo:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  record.modelOutput.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
